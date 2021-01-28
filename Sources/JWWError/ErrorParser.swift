import Foundation

/// Typealias for easier access to the ErrorReporter.Parser type.
typealias ErrorParser = ErrorReporter.Parser

extension ErrorReporter {
    /// Value type that converts a reportable error into a valid JSON payload to send to logstash.
    struct Parser {
        /// The reported error to parse.
        let error: ReportableError

        /// Information about the application that is reporting the error.
        let appInfo: AppInfoProviding

        /// Supplemental key/value pairs that can be associated with the error payload.
        let additionalInfo: [ErrorPayloadKey: AnyHashable]

        /// Creates the logstash message that will be send to the reporting service.
        func makeLogstashMessage() throws -> ErrorPayload {
            let mergedPayload = error.userInfo.merging(additionalInfo) { (left, right) -> AnyHashable in
                return right
            }

            return ErrorPayload(domain: type(of: error).domain,
                         code: error.code,
                         message: error.message,
                         environment: appInfo.environment,
                         date: Date(),
                         app: ErrorPayload.AppInfo(appInfo),
                         metadata: ErrorPayloadMetadata(values: mergedPayload))
        }
    }
}
