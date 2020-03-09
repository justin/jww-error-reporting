import Foundation

public struct LogstashKey: Hashable, Equatable, RawRepresentable {
    public typealias RawValue = String
    public var rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

public extension LogstashKey {
    static let domainKey = LogstashKey(rawValue: "domain")
    static let codeKey = LogstashKey(rawValue: "code")
    static let messageKey = LogstashKey(rawValue: "message")
}

