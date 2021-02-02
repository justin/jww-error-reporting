# JWW Error Reporting

`JWWError` enables the publishing of `Swift.Error` data to an ELK stack. Presently, this is tied exclusively to Logz.io.

### Connecting to the LogzIO service.

`JWWError` uses the [JSON upload API][api] provided by LogzIO to upload data. The `JWWError.LogzIO` type conforms to our `ReportingService`, which allows us to connect and send error data to the backend.

Since the error reporter is a singleton instance that runs globally through the app process, we need to configure it with the connection information after initialization using the `ErrorReporterConfiguration` type.

```swift
let logz: ReportingService = LogzIO(token: "your-token", region: .east, connection: .secure)
let info: AppInfoProviding = AppInfo.shared // This is made up
let configuration = ErrorReporterConfiguration(service: logz, appInfo: info)
ErrorReporter.shared.configure(configuration: logz)
```

### Payload Format.

The logging service expects to receive the payload from 

```json
{
    "code": 666,
    "domain": "com.justinwme.ios.reverse-dns.filtering",
    "message": "The developer-facing message to show in Logz.io's dashboard / console",
    "environment": "qa, production, or staging",
    "reported_at": "2021-01-19T00:00:00.000Z",
    "mobile": {
        "version": "2.0.0",
        "build_number": 2500,
        "platform": "ios",
        "network": "wifi, cellular, or offline",
        "development": true
    },
    "ios.metadata": {
        "unique": "values",
        "that": "are platform or error specific",
        "is_useful": true 
    }
}
```

* **Code**: _Integer_. The code associated with the error. On iOS, this would be the NSError.code. 
* **Domain**: _String_. A reverse DNS key that is unique to each specific error/report type. 
* **Message**: _String_. The non-localized message that will show up in the Kibana Dashboard. 
* **Environment**: _String_. The deployed backend environment we are targeting. Acceptable values include: QA, production, and staging. 
* **Reporting Date**: _Date_. The ISO8601-formatted date when the error was reported. Timezone should be set to UTC.
* **Mobile Info**: _Dictionary_. A set of keys that are unique to the mobile products.
    - Version: _String_. The marketing version of the app reporting an error.
    - Build Number: _Integer_. The build number of the app reporting an error.
    - Platform: _String_. The app platform. The default value is "ios". 
    - Network: _String_. The connection the app has when an error is generated.  Acceptable values are: wifi, cell, or offline.
    - Development: _Boolean_. A boolean that is set to true if the error is reported by a local/development version of the app.
* **Platform Metadata**: _Dictionary_. A set of keys that are unique to a given platform and/or specific error.
    - The underlying keys here are defined by each platform uniquely.
    - But think of a scenario in which you hit an error parsing JSON. You could include the JSON payload here as a key/value pair. 

### Reporting an Error 

The error reporter supports sending any payload that conforms to `ReportableError` up to Kibana for analysis.

```swift
/// Protocol that declares the pieces of information necessary to report an `Error` to logstash.
public protocol ReportableError: Swift.Error {
    /// **Required**. The domain for the error.
    static var domain: String { get }

    /// The error code for the specific error type.
    var code: Int { get }

    /// A non-user-facing string describing the error.
    var message: String { get }

    /// Whether the specific instance of the error should be send to logstash for
    /// analysis. Defaults to `true`
    var isReportable: Bool { get }

    /// An object containing additional information related to the error.
    var userInfo: [ErrorPayloadKey: AnyHashable] { get }
}
```

Note the `isReportable` boolean: if this value is set to false, the error will be sent to the error reporter but will not be passed to Kibana itself. This is useful in scenarios when an error may occur, but reporting on it is not useful (e.g., a cancelled network request).

### User Info Payloads

The `userInfo` dictionary that is associated with a ReportableError allows us to pass any `Codable` type into the error reporter, then up to Kibana. These values will be included in the JSON payload under the `ios.metadata` section. Currently, we are using this for passing up the JSON payload and any underlying errors that may bubble up when reporting a `DecodingError`.

## Using the ErrorReporter. 

The API to send data to Kibana through the ErrorReporter is a single call:

```swift

let additionalPayloadKey = ErrorPayloadKey("additional_payload_key")
let error = OurReportableError()
ErrorReporter.shared.post(error: error, additionalInfo: [AdditionalPayloadKey: "value"])
```

Of note in this API is the `additionalInfo` field: this allows us to affix supplemental information to the error report that may not be included in the error itself. We presently use this in the `PerceptionService` to ensure that we send the assessment ID and perception event data.  The only requirement for the values in `additionalInfo` is that they must use the same signature as `ReportableError.userInfo`; specifically, the key is an `ErrorPayloadKey` with the value `Hashable` and `Encodable`.

In terms of precedence, if the same `ErrorPayloadKey` is included in both `ReportableError.userInfo` and `additionalInfo`, the value in `additionalInfo` will be used.

## Known Issues and Limitations

At present, the `JWWError` library is not a 1.0.0 project, so there will be breaking API changes going forward. There is also plenty of missing functionality. In priority order:

- The `userInfo` and `additionalInfo` payloads only support sending the following data types: `Bool`, `Int`, `Float`, `Double`, `String`, and `URL`. Support **is missing** for types such as `Array`, `Set`, and `Dictionary`, as well as any custom types ([#12][12]).
- There is no API for parsing an `NSError` properly. This is a high priority ([#13][13]).
- Parsing an underlying error in an `NSError` or `URLError` dictionary is not currently as readable as it should be ([#14][14]).
- There is no validation of the keys in terms of overriding a "reserved" key ([#15][15]).
- There is no validation to ensure that the set of "required" keys are included in each payload. This is not as urgent, since we only allow sending a full `ReportableError` right now ([#15][15]).
- Somewhat related, there is no support for sending a non-error payload. We would like to support an API that just sends an arbitrary dictionary: `func post(payload: [ErrorPayloadKey: AnyHashable])` ([#15][15]).
- The LogzIO service presently only supports sending data using the `secure` `LogzIO.Connection` type. Support for `streaming` and `insecure` is pending ([#16][16] and [#17][17]).
- There is no feedback if an error fails to upload outside of the development console ([#18][18]).

## Futher Help

If you need assistance or have questions about Kibana, `ErrorReporter`, or the `ReportableError` type, please talk to @justin.

[logz]: https://app.logz.io
[api]: https://docs.logz.io/shipping/log-sources/json-uploads.html
[tokens]: https://app.logz.io/#/dashboard/settings/manage-tokens/shared
[12]: https://github.com/justin/jww-error-reporting/issues/12
[13]: https://github.com/justin/jww-error-reporting/issues/13
[14]: https://github.com/justin/jww-error-reporting/issues/14
[15]: https://github.com/justin/jww-error-reporting/issues/15
[16]: https://github.com/justin/jww-error-reporting/issues/16
[17]: https://github.com/justin/jww-error-reporting/issues/17
[18]: https://github.com/justin/jww-error-reporting/issues/18

## License

Copyright 2021 Justin Williams. Licensed under the MIT license.
