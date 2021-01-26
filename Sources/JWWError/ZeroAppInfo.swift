import Foundation

/// App info provider that sets each value to MISSING.
struct ZeroAppInfo: AppInfoProviding, Hashable {
    /// Convenience accessor for returning zero app info.
    static let missing = ZeroAppInfo()

    let marketingVersion: String = "MISSING"
    let buildNumber: Int = -1
    let platform: String = "MISSING"
    let environment: ServerEnvironment = ServerEnvironment(named: "MISSING")
    let isDevelopmentBuild: Bool = false
    let network: Network = .unknown
}
