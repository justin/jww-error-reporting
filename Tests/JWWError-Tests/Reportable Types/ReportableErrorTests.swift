import XCTest
@testable import JWWError

// Tests to validate our `ReportableError` protocol.
final class ReportableErrorTests: XCTestCase {
    /// Validate that a type that conforms to ReportableError defaults the value of `isReportable` to true.
    func testErrorsDefaultToReportable() throws {
        let error = TestErrorStruct()
        XCTAssertTrue(error.isReportable)
    }

    /// Validate we can parse the enum based TestError.
    func testRetrievingTestErrorValues() throws {
        let error = TestErrorEnum.reason1

        XCTAssertEqual(error.code, 0)
        XCTAssertEqual(error.message, "Reason 1")
        XCTAssertTrue(error.userInfo.isEmpty)
    }

    /// Validate we can retrieve the associated value as part of an error
    func testParsingAssociatedValue() throws {
        let error = TestErrorEnum.reason2(value: "Associated Value for Reason 3")
        XCTAssertEqual(error.code, 1)
        XCTAssertEqual(error.message, "Associated Value for Reason 3")
        XCTAssertTrue(error.userInfo.isEmpty)
    }
}

/// Custom error type that is build from a value type we can inject values into.
private struct TestErrorStruct: ReportableError {
    static let domain: String = "com.justinwme.tests.reportable-error"
    let code: Int
    let message: String
    let userInfo: [ErrorPayloadKey: AnyHashable]

    init(code: Int = Int.random(in: 0..<100), message: String = UUID().uuidString, userInfo: [ErrorPayloadKey: AnyHashable] = [:]) {
        self.code = code
        self.message = message
        self.userInfo = userInfo
    }
}

/// Enum based error type that has three predefined values.
private enum TestErrorEnum: Swift.Error {
    case reason1
    case reason2(value: String)
}

extension TestErrorEnum: ReportableError {
    static let domain: String = "com.justinwme.tests.test-error"

    var code: Int {
        switch self {
        case .reason1:
            return 0
        case .reason2:
            return 1
        }
    }

    var message: String {
        switch self {
        case .reason1:
            return "Reason 1"
        case .reason2(let value):
            return value
        }
    }

    var userInfo: [ErrorPayloadKey : AnyHashable] {
        [:]
    }
}
