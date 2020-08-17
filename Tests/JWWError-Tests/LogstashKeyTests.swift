import XCTest
@testable import JWWError

/// Tests to validate the `LogstashKey` type.
final class LogstashKeyTests: XCTestCase {
    /// Validate we can create a new `LogstashKey` with a given `rawValue`.
    func testInit() throws {
        let rawValue = UUID().uuidString
        let key = LogstashKey(rawValue: rawValue)

        XCTAssertEqual(key.rawValue, rawValue)
    }

    /// Validate we can create a new `LogstashKey` with using the convenience initializer.
    func testConvenienceInit() throws {
        let rawValue = UUID().uuidString
        let key = LogstashKey(rawValue)

        XCTAssertEqual(key.rawValue, rawValue)
    }
}
