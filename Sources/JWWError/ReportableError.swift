import Foundation

/// Protocol that declares the pieces of information necessary to report an `Error` to logstash.
public protocol ReportableError: Swift.Error {
    /// **Required**. The domain for the error.
    static var domain: String { get }

    /// The error code for the specific error type.
    var code: Int { get }

    /// A non-user facing string describing the error.
    var message: String { get }

    /// Whether the specific instance of the error should be send to logstash for
    /// analysis. Defaults to `true`
    var isReportable: Bool { get }
}

// MARK: Default Implementations
// ====================================
// Default Implementations
// ====================================
extension ReportableError {
    public var isReportable: Bool {
        /// Default to returning true
        return true
    }
}

// MARK: DecodingError Helpers
// ====================================
// DecodingError Helpers
// ====================================

extension DecodingError: ReportableError {
    public static var domain: String {
        "com.justinwme.error.json-decoding"
    }

    public var code: Int {
        let result: Int
        switch self {
        case .dataCorrupted:
            result = 0
        case .keyNotFound:
            result = 1
        case .typeMismatch:
            result = 2
        case .valueNotFound:
            result = 3
        @unknown default:
            result = -1
        }

        return result
    }

    public var message: String {
        let result: String
        switch self {
        case .dataCorrupted(let context):
            result = "Data corrupted: \(context.debugDescription)"
        case .keyNotFound(let key, let context):
            result = "Key '\(key.stringValue)' not found. \(context.debugDescription)"
        case .typeMismatch(let type, let context):
            result = "Type mismatch. \(type) expected. \(context.debugDescription)"
        case .valueNotFound(let type, let context):
            result = "Value of type \(type) not found. \(context.debugDescription)"
        @unknown default:
            result = "JSONDecoding Error of unknown type \(self)"
        }

        return result
    }
}
