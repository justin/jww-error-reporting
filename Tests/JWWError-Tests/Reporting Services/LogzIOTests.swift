import XCTest
@testable import JWWError

/// Tests to validate the `LogzIOReporter` reporting service.
final class LogzIOTests: XCTestCase {
    /// Validate we can create a new `LogzIOReporter` by passing in the URL components
    func testInitWithComponents() throws {
        let url = URL(staticString: "https://listener.logz.io:5052?token=1234&type=foo")

        let result = try LogzIO(token: "1234",
                                region: .east,
                                connection: .streaming,
                                type: "foo")

        XCTAssertEqual(result.url, url)
    }
}
