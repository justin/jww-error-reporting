import Foundation

/**
 Protocol that declares the pieces of information necessary to report an `Error` to
 logstash.
 */
public protocol ReportableError: CustomNSError & LocalizedError {
    /// **Required**. The domain for the error.
    static var domain: String { get }

    /// The error code for the specific error type.
    var code: Int { get }

    /// A non-user facing string describing the error. This **should not** be localized.
    var errorMessage: String { get }

    /// Optional dictionary payload that can be attached to an error.
    var userInfo: [String: AnyHashable]? { get }

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
        return true
    }
}

// MARK: CustomNSError Conformance
// ====================================
// CustomNSError Conformance
// ====================================
extension ReportableError {
    // JWW: 03/09/20
    // This maps the `CustomNSError` values to our `ReportableError` values so that
    // the API is more readable, without losing the upstream protocol implementation.

    public var errorCode: Int {
        return code
    }

    public static var errorDomain: String {
        return domain
    }

    public var errorUserInfo: [String: Any] {
        return userInfo ?? [:]
    }
}
