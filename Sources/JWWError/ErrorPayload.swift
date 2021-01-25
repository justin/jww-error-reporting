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
    let environment: ServerEnvironment

    /// The date this error was generated.
    let date: Date

    /// Information about the device / app the error was generated from.
    let app: AppInfo

    /// Custom payload values that are unique to an iOS error.
    let metadata: Metadata

    struct AppInfo: Codable {
        private enum CodingKeys: String, CodingKey {
            case version
            case build
            case platform
            case network
            case isDevelopmentBuild = "development"
        }

        /// The current app version.
        let version: String

        /// The current app build.
        let build: Int

        /// The current app platform: usually 'ios'.
        let platform: String

        /// The network connection the app was using when reporitng the error.
        let network: Network

        /// Boolean that returns true if the error is for a development build. (ie. via Xcode)
        let isDevelopmentBuild: Bool

        init(_ info: AppInfoProviding) {
            self.version = info.marketingVersion
            self.build = info.buildNumber
            self.platform = info.platform
            self.network = info.network
            self.isDevelopmentBuild = info.isDevelopmentBuild
        }

        init(version: String,
             build: Int,
             platform: String = "ios",
             network: Network = .wifi,
             isDevelopmentBuild: Bool = true) {
            self.version = version
            self.build = build
            self.platform = platform
            self.network = network
            self.isDevelopmentBuild = isDevelopmentBuild
        }
    }
}
