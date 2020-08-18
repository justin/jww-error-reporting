import XCTest
import JWWCore
@testable import JWWError

/// Tests to validate the `LogzIOReporter` reporting service.
final class LogzIOReporterTests: XCTestCase {
    /// Validate we can create a new `LogzIOReporter` with a passed in URL
    func testInitWithURL() throws {
        let url = URL(staticString: "https://localhost/?token=1234&type=foo")

        let result = LogzIOReporter(url: url)

        XCTAssertEqual(result.url, url)
    }

    /// Validate we can create a new `LogzIOReporter` by passing in the URL components
    func testInitWithComponents() throws {
        let url = URL(staticString: "https://listener.logz.io:666?token=1234&type=foo")

        let result = LogzIOReporter(host: "listener.logz.io", port: 666, token: "1234", type: "foo")

        XCTAssertEqual(result?.url, url)
    }
}
