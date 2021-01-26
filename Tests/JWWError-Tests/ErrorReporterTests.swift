import XCTest
@testable import JWWError

/// Tests to validate our `ErrorReporter` class.
final class ErrorReporterTests: XCTestCase {
    private struct TestReporter: ReportingService {
        let url: URL = URL(staticString: "http://localhost/")
    }

    /// Throwaway test to just get something in here as a starter.
    func testInitialization() throws {
        let service = TestReporter()
        let appInfo = AppInfoFixture.fixture()
        let reporter = ErrorReporter(reportingService: service, appInfo: appInfo)

        XCTAssertNotNil(reporter)
    }
}
