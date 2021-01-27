import XCTest
@testable import JWWError

/// Tests to validate our `ErrorReporter` class.
final class ErrorReporterTests: XCTestCase {
    /// Throwaway reporting service we can use for tests.
    private struct TestReporter: ReportingService {
        let url: URL = URL(staticString: "http://localhost/")
    }

    /// The error reporter instance under test.
    private var sut: ErrorReporter!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = ErrorReporter()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
    }

    /// Validate that the shared singleton initializes without a service set.
    func testSharedSingletonInit() throws {
        XCTAssertNil(ErrorReporter.shared.errorService)
    }

    /// Validate we can configure the reporting reporter with a new service.
    func testConfiguringReportingService() throws {
        let expectedService = TestReporter()
        let info = AppInfoFixture.fixture()
        let config = ErrorReporterConfiguration(service: expectedService, appInfo: info)

        sut.configure(configuration: config)

        let result = try XCTUnwrap(sut.errorService?.url)

        XCTAssertEqual(result, expectedService.url)
    }
}
