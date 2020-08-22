import Foundation

// MARK: CustomNSError Conformance
// ====================================
// CustomNSError Conformance
// ====================================
extension ReportableError where Self:CustomNSError {
    /// **Required**. The domain for the error.
    public static var domain: String {
        errorDomain
    }

    /// The error code for the specific error type.
    var code: Int {
        errorCode
    }

    /// An object containing additional information related to the error.
    var userInfo: [ErrorPayloadKey: AnyHashable] {
        var payload: [ErrorPayloadKey: AnyHashable] = [:]
        for (key, value) in errorUserInfo {
            payload[ErrorPayloadKey(rawValue: key)] = value as? AnyHashable
        }

        return payload
    }
}
