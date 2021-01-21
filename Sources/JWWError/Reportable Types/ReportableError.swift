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

    /// An object containing additional information related to the error.
    var userInfo: [ErrorPayloadKey: AnyHashable] { get }
}

// MARK: Default Implementations
// ====================================
// Default Implementations
// ====================================
extension ReportableError {
    var isReportable: Bool {
        /// Default to returning true
        return true
    }
}
