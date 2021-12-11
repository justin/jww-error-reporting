import Foundation

/// Protocol to encapsulate useful information about the running application.
public protocol AppInfoProviding {
    /// The semantic version of the app.
    var marketingVersion: String { get }

    /// The build version of the app.
    var buildNumber: Int { get }

    /// The platform the app is running on.
    var platform: String { get }

    /// The server environment you are running and reporting against.
    var environment: ServerEnvironment { get }

    /// Boolean that returns true if this report is for a development build. (ie. via Xcode)
    var isDevelopmentBuild: Bool { get }

    /// The network connection the app is running with.
    var network: Network { get }
}

/// Enum that lists possible network connection types.
public enum Network: String, Codable {
    /// The device is connected via a cellular connection.
    case cellular

    /// The device is connected via a WiFi connection.
    case wifi

    /// The device is not connected to the Internet.
    case offline

    /// The device is connected using a wired connection.
    case ethernet

    /// The device is connected over a local loopback network.
    case loopback

    /// The network information was unavailable or unknown.
    case unknown
}

/// The server environment you are running and reporting against.
public struct ServerEnvironment: Codable, Hashable, RawRepresentable {
    public let rawValue: String

    public init?(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(named value: String) {
        self.init(rawValue: value)!
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = ServerEnvironment(named: rawValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    /// Predefined environment for a "QA" environment.
    static let qa = ServerEnvironment(named: "qa")

    /// Predefined environment for a "Staging" environment.
    static let staging = ServerEnvironment(named: "staging")

    /// Predefined environment for a "Production" environment.
    static let production = ServerEnvironment(named: "production")
}

