import XCTest
import JWWCore
@testable import JWWError

/// Tests to validate our `ErrorReporter` class.
final class ErrorReporterTests: XCTestCase {
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

    /// Throwaway test to just get something in here as a starter.
    func testInitialization() throws {
        let service = TestReporter()
        let appInfo = TestAppInfo()
        let reporter = ErrorReporter(reportingService: service, appInfo: appInfo)

        XCTAssertNotNil(reporter)
    }
}
