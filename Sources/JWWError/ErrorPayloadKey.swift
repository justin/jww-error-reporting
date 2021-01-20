import Foundation

struct ErrorPayloadKey: Hashable, Equatable, RawRepresentable {
    typealias RawValue = String
    var rawValue: RawValue

    init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension ErrorPayloadKey {
    static let domainKey = ErrorPayloadKey(rawValue: "domain")
    static let codeKey = ErrorPayloadKey(rawValue: "code")
    static let messageKey = ErrorPayloadKey(rawValue: "message")
}
