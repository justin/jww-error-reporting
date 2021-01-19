import Foundation

/// Enum that lists possible network connection types.
public enum Network: String, Codable {
    /// The device is connected via a cellular connection.
    case cellular

    /// The device is connected via a WiFi connection.
    case wifi

    /// The device is not connected to the Internet.
    case offline
}

/// Protocol to encapsulate useful information about the running application.
public protocol AppInfoProviding {
    /// The semantic version of the app.
    var marketingVersion: String { get }

    /// The build version of the app.
    var buildNumber: Int { get }

    /// The platform the app is running on.
    var platform: String { get }

    /// Bundle identifier of the app, i.e "com.justinwme.ios.app"
    var bundleIdentifier: String { get }

    /// Boolean that returns true if this report is for a development build. (ie. via Xcode)
    var isDevelopmentBuild: Bool { get }

    /// The network connection the app is running with.
    var network: Network { get }
}
