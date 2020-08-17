import XCTest
@testable import JWWError

/// Tests to validate the payload type for any message passed up to the ErrorReporter.
final class LogstashPayloadTests: XCTestCase {
    /// Validate the list of required keys for a payload.
    func testRequiredKeys() throws {
        let expected: Set<LogstashKey> = [LogstashKey.codeKey, LogstashKey.messageKey, LogstashKey.domainKey ]
        let keys = LogstashPayload.requiredKeys
        XCTAssertEqual(keys, expected)
    }
}

