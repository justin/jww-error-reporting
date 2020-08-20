import Foundation

public struct ErrorPayloadKey: Hashable, Equatable, RawRepresentable {
    public typealias RawValue = String
    public var rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

public extension ErrorPayloadKey {
    static let domainKey = ErrorPayloadKey(rawValue: "domain")
    static let codeKey = ErrorPayloadKey(rawValue: "code")
    static let messageKey = ErrorPayloadKey(rawValue: "message")
}
