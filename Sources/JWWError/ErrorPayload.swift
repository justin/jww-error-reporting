import Foundation

/// The JSON payload values that are shipped up to a logstash server for ingestion.
struct ErrorPayload: Codable {
    private enum CodingKeys: String, CodingKey {
        case domain
        case code
        case message
        case environment
        case date = "reported_at"
        case app = "mobile"
        case metadata = "ios.metadata"
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

    /// The server environment you are running and reporting against.
    let environment: Environment

    /// The date this error was generated.
    let date: Date

    /// Information about the device / app the error was generated from.
    let app: AppInfo

    /// Custom payload values that are unique to an iOS error.
    let metadata: [String: String]

    struct AppInfo: Codable {
        private enum CodingKeys: String, CodingKey {
            case version
            case build
            case platform
        }

        /// The current app version.
        let version: String

        /// The current app build.
        let build: Int

        /// The current app platform: usually 'iOS'.
        let platform: String

        init(_ info: AppInfoProviding) {
            self.version = info.marketingVersion
            self.build = info.buildNumber
            self.platform = info.platform
        }

        init(version: String, build: Int, platform: String = "ios") {
            self.version = version
            self.build = build
            self.platform = platform
        }
    }

    /// The server environment you are running and reporting against.
    struct Environment: RawRepresentable, Codable {
        let rawValue: String

        init?(rawValue: String) {
            self.rawValue = rawValue
        }

        init(named value: String) {
            self.init(rawValue: value)!
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = Environment(named: rawValue)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }

        /// Predefined environment for a "QA" environment.
        static let qa = Environment(named: "qa")

        /// Predefined environment for a "Staging" environment.
        static let staging = Environment(named: "staging")

        /// Predefined environment for a "Production" environment.
        static let production = Environment(named: "production")
    }
}
