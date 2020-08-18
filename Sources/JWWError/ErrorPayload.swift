import Foundation

/// The JSON payload values that are shipped up to a logstash server for ingestion.
struct ErrorPayload: Codable {
    /// Array of "required" values that must be passed with any payload before it can be uploaded.
    static var requiredKeys: Set<LogstashKey> {
        return [ .domainKey, .codeKey, .messageKey ]
    }

    /// The domain of the logged error.
    let domain: String

    /// The numeric code associated with the logged error.
    let code: Int

    /// The non-localized message to display for the logged error.
    let message: String

    /// The current app version.
    let appVersion: String

    /// The current app build.
    let buildNumber: String

    /// The current app platform: usually 'iOS'.
    let platform: String

    /// The date this error was generated.
    let date: Date
}
