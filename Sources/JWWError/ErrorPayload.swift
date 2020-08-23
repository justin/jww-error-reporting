import Foundation

/// The JSON payload values that are shipped up to a logstash server for ingestion.
struct ErrorPayload: Codable {
    private enum CodingKeys: String, CodingKey {
        case domain
        case code
        case message
        case app
        case date = "@timestamp"
    }

    /// Array of "required" values that must be passed with any payload before it can be uploaded.
    static var requiredKeys: Set<ErrorPayloadKey> {
        return [ .domainKey, .codeKey, .messageKey ]
    }

    /// The domain of the logged error.
    let domain: String

    /// The numeric code associated with the logged error.
    let code: Int

    /// The non-localized message to display for the logged error.
    let message: String

    /// The date this error was generated.
    let date: Date

    /// Information about the device / app the error was generated from.
    let app: AppInfo

    struct AppInfo: Codable {
        private enum CodingKeys: String, CodingKey {
            case version
            case build
            case platform
        }

        /// The current app version.
        let version: String

        /// The current app build.
        let build: String

        /// The current app platform: usually 'iOS'.
        let platform: String

        init(_ info: AppInfoProviding) {
            self.version = info.appVersion
            self.build = info.buildNumber
            self.platform = info.currentPlatform
        }

        init(version: String, build: String, platform: String) {
            self.version = version
            self.build = build
            self.platform = platform
        }
    }
}
