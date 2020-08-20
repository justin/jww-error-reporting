import XCTest
@testable import JWWError

// Tests to validate our `ReportableError` extension on `DecodingError`
final class DecodingErrorReportingTests: XCTestCase {
    private enum TestCodingKeys: String, CodingKey {
        case key
        case master
    }

    /// Validate a `LocalizedError` that conforms to `ReportableError` defaults its domain to the type name.
    func testDecodingErrorDomain() throws {
        let result = DecodingError.domain
        XCTAssertEqual(result, "com.justinwme.error.json-decoding")
    }

    /// Validate the message generated for a `DecodingError.dataCorrupted` error.
    func testErrorMessageForDataCorruption() throws {
        let expectedMessage = "Data corrupted: Could not parse anything."

        let context = DecodingError.Context(codingPath: [TestCodingKeys.key], debugDescription: "Could not parse anything.")
        let result = DecodingError.dataCorrupted(context)

        XCTAssertEqual(result.message, expectedMessage)
    }

    /// Validate the message generated for a `DecodingError.keyNotFound` error.
    func testErrorMessageForKeyNotFound() throws {
        let expectedMessage = "Key 'master' not found. Could not parse anything."

        let context = DecodingError.Context(codingPath: [TestCodingKeys.key], debugDescription: "Could not parse anything.")
        let result = DecodingError.keyNotFound(TestCodingKeys.master, context)

        XCTAssertEqual(result.message, expectedMessage)
    }

    /// Validate the message generated for a `DecodingError.typeMismatch` error.
    func testErrorMessageForTypeMismatch() throws {
        let expectedMessage = "Type mismatch. String expected. Could not parse anything."

        let context = DecodingError.Context(codingPath: [TestCodingKeys.key], debugDescription: "Could not parse anything.")
        let result = DecodingError.typeMismatch(String.self, context)

        XCTAssertEqual(result.message, expectedMessage)
    }

    /// Validate the message generated for a `DecodingError.valueNotFound` error.
    func testErrorMessageForValueNotFound() throws {
        let expectedMessage = "Value of type Array<String> not found. Could not parse anything."

        let context = DecodingError.Context(codingPath: [TestCodingKeys.key], debugDescription: "Could not parse anything.")
        let result = DecodingError.valueNotFound([String].self, context)

        XCTAssertEqual(result.message, expectedMessage)
    }

    /// Validate the code generated for a `DecodingError.dataCorrupted` error.
    func testErrorCodeForDataCorruption() throws {
        let expectedCode = 0

        let context = DecodingError.Context(codingPath: [TestCodingKeys.key], debugDescription: "Could not parse anything.")
        let result = DecodingError.dataCorrupted(context)

        XCTAssertEqual(result.code, expectedCode)
    }

    /// Validate the code generated for a `DecodingError.keyNotFound` error.
    func testErrorCodeForKeyNotFound() throws {
        let expectedCode = 1

        let context = DecodingError.Context(codingPath: [TestCodingKeys.key], debugDescription: "Could not parse anything.")
        let result = DecodingError.keyNotFound(TestCodingKeys.master, context)

        XCTAssertEqual(result.code, expectedCode)
    }

    /// Validate the code generated for a `DecodingError.typeMismatch` error.
    func testErrorCodeForTypeMismatch() throws {
        let expectedCode = 2

        let context = DecodingError.Context(codingPath: [TestCodingKeys.key], debugDescription: "Could not parse anything.")
        let result = DecodingError.typeMismatch(String.self, context)

        XCTAssertEqual(result.code, expectedCode)
    }

    /// Validate the code generated for a `DecodingError.valueNotFound` error.
    func testErrorCodeForValueNotFound() throws {
        let expectedCode = 3

        let context = DecodingError.Context(codingPath: [TestCodingKeys.key], debugDescription: "Could not parse anything.")
        let result = DecodingError.valueNotFound([String].self, context)

        XCTAssertEqual(result.code, expectedCode)
    }
}
