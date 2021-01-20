import XCTest
import JWWCore
@testable import JWWError

/// Tests to validate our `ErrorReporter` class.
final class ErrorParserTests: XCTestCase {
    /// Test application info implementation
    private struct TestAppInfo: AppInfoProviding, Equatable {
        let marketingVersion: String = UUID().uuidString
        let buildNumber: Int = Int.random(in: 0..<1000)
        let platform: String = UUID().uuidString
        let bundleIdentifier: String = UUID().uuidString
        let appIdentifier: String = UUID().uuidString
        let isDevelopmentBuild: Bool = Bool.random()
        let network: Network = .wifi
    }

    private struct TestReporter: ReportingService {
        let url: URL = URL(staticString: "http://localhost/")
    }

    private struct TestError: ReportableError {        
        static let domain: String = "TestError"
        let code: Int
        let message: String
        let userInfo: [ErrorPayloadKey: AnyHashable]
    }

    /// Validate we can generate a new error payload from a standard ReportableError.
    func testParsingError() throws {
        let error = TestError(code: Int.random(in: 0..<100), message: UUID().uuidString, userInfo: [:])
        let info = TestAppInfo()

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
