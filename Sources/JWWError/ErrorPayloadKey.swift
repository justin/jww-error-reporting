import Foundation

/// Value type that declares the different payload keys that can be used in a `ReportableError.userInfo` payload.
public struct ErrorPayloadKey: Hashable, Codable, RawRepresentable {
    public let rawValue: String

    /// Creates a new instance with the specified raw value.
    ///
    /// - Parameter rawValue: The raw value to use for the new instance.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

public extension ErrorPayloadKey {
    /// A key that declares the error domain, as an `String`.
    static let domainKey = ErrorPayloadKey(rawValue: "domain")

    /// A key that declares the error code, as an `Int`.
    static let codeKey = ErrorPayloadKey(rawValue: "code")

    /// A key that declares the error message, as a `String`.
    static let messageKey = ErrorPayloadKey(rawValue: "message")
}
