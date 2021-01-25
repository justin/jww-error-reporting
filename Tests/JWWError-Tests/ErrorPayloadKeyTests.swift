import XCTest
@testable import JWWError

/// Tests to validate the `ErrorPayloadKey` type.
final class ErrorPayloadKeyTests: XCTestCase {
    /// Validate we can create a new `ErrorPayloadKey` with a given `rawValue`.
    func testInit() throws {
        let rawValue = UUID().uuidString
        let key = ErrorPayloadKey(rawValue: rawValue)

        XCTAssertEqual(key.rawValue, rawValue)
    }

    /// Validate we can create a new `ErrorPayloadKey` with using the convenience initializer.
    func testConvenienceInit() throws {
        let rawValue = UUID().uuidString
        let key = ErrorPayloadKey(rawValue)

        XCTAssertEqual(key.rawValue, rawValue)
    }

    /// Validate we can encode and decode an error payload key.
    func testEncodingAndDecoding() throws {
        let key = ErrorPayloadKey("test-key")
        let encoded = try JSONEncoder().encode(key)

        let result = try JSONDecoder().decode(ErrorPayloadKey.self, from: encoded)
        XCTAssertEqual(result.rawValue, "test-key")
    }
}
