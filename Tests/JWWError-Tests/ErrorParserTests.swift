import XCTest
@testable import JWWError

/// Tests to validate our `ErrorReporter` class.
final class ErrorParserTests: XCTestCase {
    private struct TestError: ReportableError {        
        static let domain: String = "com.justinwme.jwwerror.test-error"
        let code: Int
        let message: String
        let userInfo: [ErrorPayloadKey: AnyHashable]
    }

    /// Validate we can generate a new error payload from a standard ReportableError.
    func testParsingError() throws {
        let error = TestError(code: Int.random(in: 0..<100),
                              message: UUID().uuidString,
                              userInfo: [:])
        let info = AppInfoFixture.fixture()

        let parser = ErrorReporter.Parser(error: error, appInfo: info)

        let result = try XCTUnwrap(parser.makeLogstashMessage())

        XCTAssertEqual(result.app.version, info.marketingVersion)
        XCTAssertEqual(result.app.build, info.buildNumber)
        XCTAssertEqual(result.code, error.code)
        XCTAssertEqual(result.domain, TestError.domain)
        XCTAssertEqual(result.message, error.message)
        XCTAssertEqual(result.app.platform, info.platform)
    }
}
