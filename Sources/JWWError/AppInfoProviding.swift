import Foundation

/// Protocol to encapsulate useful information about the running application.
public protocol AppInfoProviding {
    /// The semantic version of the app.
    var appVersion: String { get }

    /// The build version of the app.
    var buildNumber: String { get }

    /// The platform the app is running on.
    var currentPlatform: String { get }

    /// Bundle identifier of the app, i.e "com.justinwme.ios.app"
    var bundleIdentifier: String { get }
}
