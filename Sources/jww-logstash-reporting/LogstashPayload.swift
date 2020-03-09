import Foundation

/// The JSON payload values that are shipped up to a logstash server for ingestion.
struct LogstashPayload: Codable {
    /// The actual payload of contents that we want to submit to the collector.
    let message: Message

    /// Create and return a new a new `LogstashPayload` instance.
    init(message: Message) {
        self.message = message
    }

    /// Array of "required" values that must be passed with any payload before it can be uploaded.
    static var requiredKeys: [LogstashKey] {
        return [ .domainKey, .codeKey, .messageKey ]
    }

    /// The internal structure of the message that is ingested.
    struct Message: Codable {
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

        /// The server environment that generated the error: staging, production, etc.
        let environment: String

        /// The date this error was generated.
        let date: Date

        /// The type of network connection the user has at the time of the error.
        let network: String
    }
}
