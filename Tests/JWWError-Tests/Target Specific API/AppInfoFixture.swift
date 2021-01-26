import Foundation
@testable import JWWError

/// Fixture type for generating an `AppInfoProviding` payload.
struct AppInfoFixture: AppInfoProviding, Hashable {
    var marketingVersion: String
    var buildNumber: Int
    var platform: String
    var environment: ServerEnvironment
    var isDevelopmentBuild: Bool
    var network: Network

    /// Create and return a fixture instance with default values set.
    static func fixture() -> AppInfoFixture {
        return AppInfoFixture(marketingVersion: "1.0.0",
                              buildNumber: Int.random(in: 0...1000),
                              platform: "ios",
                              environment: .qa,
                              isDevelopmentBuild: true,
                              network: .wifi)
    }
}
