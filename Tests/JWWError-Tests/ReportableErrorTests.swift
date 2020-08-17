import XCTest
@testable import JWWError

// Tests to validate our `ReportableError` protocol.
final class ReportableErrorTests: XCTestCase {
    private struct TestReportableError: ReportableError {
        static let domain: String = UUID().uuidString
        let code: Int
        let message: String

        init(code: Int = Int.random(in: 0..<100), message: String = UUID().uuidString) {
            self.code = code
            self.message = message
        }
    }

    /// Validate that a type that conforms to ReportableError defaults the value of `isReportable` to true.
    func testErrorsDefaultToReportble() throws {
        let error = TestReportableError()
        XCTAssertTrue(error.isReportable)
    }
}
