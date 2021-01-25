import XCTest
@testable import JWWError

final class ErrorPayloadMetadataTests: XCTestCase {
    private let payload = ErrorPayload.Metadata(values: [
        .domainKey: "domain",
        .codeKey: 666,
        .messageKey: "Something is broken",
        ErrorPayloadKey("int8"): Int8(0),
        ErrorPayloadKey("int16"): Int16(0),
        ErrorPayloadKey("int32"): Int32(0),
        ErrorPayloadKey("int64"): Int64(0),
        ErrorPayloadKey("bool"): true,
        ErrorPayloadKey("double"): Double(0.6),
        ErrorPayloadKey("float"): Float(0.6),
        ErrorPayloadKey("url"): URL(staticString: "https://justinw.me")
    ])

    /// Validate we can encode a payload of supported values.
    func testEncoding() throws {
        let encoder = JSONEncoder()
        XCTAssertNoThrow(try encoder.encode(payload))
    }

    /// Validate we throw an encoding error when we are unable to encode a specific type of value.
    func testUnsupportedEncodingTypes() throws {
        let unsupportedPayload = ErrorPayload.Metadata(values: [
            .domainKey: ["foo", "bar", "biz"]
        ])

        let encoder = JSONEncoder()
        XCTAssertThrowsError(try encoder.encode(unsupportedPayload)) { error in
            guard case EncodingError.invalidValue(_, _) = error else {
                XCTFail("Unexpected error type returned")
                return
            }
        }
    }
}
