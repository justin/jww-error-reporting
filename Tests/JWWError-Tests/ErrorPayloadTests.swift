import XCTest
@testable import JWWError

/// Tests to validate the payload type for any message passed up to the ErrorReporter.
final class ErrorPayloadTests: XCTestCase {
    /// Validate the list of required keys for a payload.
    func testRequiredKeys() throws {
        let expected: Set<ErrorPayloadKey> = [.codeKey, .messageKey, .domainKey ]
        let keys = ErrorPayload.requiredKeys
        XCTAssertEqual(keys, expected)
    }

    /// Validate that encoded structure sets the proper timestamp key.
    func testDateReturnsTimestampKey() throws {
        let metadata = ErrorPayload.Metadata(values: [:])
        let payload = ErrorPayload(domain: UUID().uuidString,
                                   code: 0,
                                   message: UUID().uuidString,
                                   environment: .qa,
                                   date: Date(),
                                   app: ErrorPayload.AppInfo(version: UUID().uuidString,
                                                             build: 666,
                                                             platform: UUID().uuidString),
                                   metadata: metadata)

        let dataPayload = try JSONEncoder().encode(payload)

        let result = try XCTUnwrap(JSONSerialization.jsonObject(with: dataPayload, options: []) as? [String: AnyHashable])

        XCTAssertTrue(result.keys.contains("reported_at"))
    }
}

