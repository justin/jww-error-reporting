import XCTest
@testable import JWWError

// Tests to validate our `ReportableError` extension on `CustomNSError`
final class CustomNSErrorReportingTests: XCTestCase {
    private var error: TestError!

    private struct GenericError: Error {
        let localizedDescription: String
    }

    private struct TestError: CustomNSError, ReportableError {
        static let errorDomain: String = "test-error"
        var errorCode: Int
        var errorUserInfo: [String : Any]
        var message: String
    }

    override func setUpWithError() throws {
        try super.setUpWithError()

        error = TestError(errorCode: Int.random(in: 0...1000), errorUserInfo: [:], message: UUID().uuidString)
    }

    override func tearDownWithError() throws {
        error = nil
        try super.tearDownWithError()
    }

    /// Validate `CustomNSError.errorDomain` is set to `ReportableError.domain`.
    func testErrorDomainMapsToReportableDomain() throws {
        XCTAssertEqual(TestError.errorDomain, TestError.domain)
    }

    /// Validate `CustomNSError.errorCode` is set to `ReportableError.code`.
    func testErrorCodeMapsToReportableCode() throws {
        XCTAssertEqual(error.errorCode, error.code)
    }

    /// Validate `CustomNSError.localizedDescription` is NOT set to `ReportableError.message`.
    ///
    /// The localized description is user facing and could return in an unexpected language.
    func testErrorDescriptionIsNotSetToReportableMessage() throws {
        XCTAssertNotEqual(error.localizedDescription, error.message)
    }

    /// Validate `CustomNSError.errorUserInfo` payload is mapped to `ReportableError.userInfo`, when possible.
    func testMappingErrorUserInfoToReportableUserInfo() throws {
        let barValue = UUID()
        let bizValue = URL(staticString: "https://github.com/justin")
        let booValue = Int.random(in: 0...10000)
        error.errorUserInfo = [
            // Since Foo isn't Hashable, we don't pull it in.
            "foo": GenericError(localizedDescription: UUID().uuidString),
            "bar": barValue,
            "biz": bizValue,
            "boo": booValue
        ]

        let expectedPayload: [ErrorPayloadKey: AnyHashable] = [
            ErrorPayloadKey(rawValue: "bar"): barValue,
            ErrorPayloadKey(rawValue: "biz"): bizValue,
            ErrorPayloadKey(rawValue: "boo"): booValue
        ]

        XCTAssertEqual(error.userInfo, expectedPayload)
    }
}
