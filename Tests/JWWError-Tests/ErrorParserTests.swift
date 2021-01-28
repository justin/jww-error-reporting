import XCTest
@testable import JWWError

/// Tests to validate our `ErrorReporter` class.
final class ErrorParserTests: XCTestCase {

    private struct TestError: ReportableError {        
        static let domain: String = "com.justinwme.jwwerror.test-error"
        let code: Int
        let message: String
        let userInfo: [ErrorPayloadKey: AnyHashable]
    }

    /// Validate we can generate a new error payload from a standard ReportableError.
    func testParsingError() throws {
        let error = TestError(code: Int.random(in: 0..<100),
                              message: UUID().uuidString,
                              userInfo: [:])
        let info = AppInfoFixture.fixture()

        let parser = ErrorReporter.Parser(error: error, appInfo: info, additionalInfo: [:])

        let result = try XCTUnwrap(parser.makeLogstashMessage())

        XCTAssertEqual(result.app.version, info.marketingVersion)
        XCTAssertEqual(result.app.build, info.buildNumber)
        XCTAssertEqual(result.code, error.code)
        XCTAssertEqual(result.domain, TestError.domain)
        XCTAssertEqual(result.message, error.message)
        XCTAssertEqual(result.app.platform, info.platform)
    }

    /// Validate the additional info payload is included in generated message.
    func testAdditionalInfoPayloadIsIncluded() throws {
        let fooKey = ErrorPayloadKey("foo-key")
        let barKey: ErrorPayloadKey = ErrorPayloadKey("bar-key")
        let expectedPayload: [ErrorPayloadKey: AnyHashable] = [
            fooKey: "Foo",
            barKey: "Bar"
        ]

        let error = TestError(code: Int.random(in: 0..<100),
                              message: UUID().uuidString,
                              userInfo: [fooKey: "Foo"])
        let additionalInfo: [ErrorPayloadKey: AnyHashable] = [
            barKey: "Bar"
        ]

        let parser = ErrorReporter.Parser(error: error,
                                          appInfo: AppInfoFixture.fixture(),
                                          additionalInfo: additionalInfo)

        let result = try XCTUnwrap(parser.makeLogstashMessage()).metadata

        XCTAssertEqual(result.values.count, expectedPayload.count)
        for (key, value) in result.values {
            XCTAssertEqual(expectedPayload[key], value)
        }
    }

    /// Validate that we prioritize the additionalInfo payload value over the error value for metadata.
    func testOverridingErrorUserInfoWithAdditonalInfo() throws {
        let fooKey = ErrorPayloadKey("foo-key")
        let barKey: ErrorPayloadKey = ErrorPayloadKey("bar-key")
        let expectedPayload: [ErrorPayloadKey: AnyHashable] = [
            fooKey: "Foo",
            barKey: "Biz"
        ]


        let error = TestError(code: Int.random(in: 0..<100),
                              message: UUID().uuidString,
                              userInfo: [
                                fooKey: "Foo",
                                barKey: "Bar"
                              ])
        let additionalInfo: [ErrorPayloadKey: AnyHashable] = [
            barKey: "Biz"
        ]

        let parser = ErrorReporter.Parser(error: error,
                                          appInfo: AppInfoFixture.fixture(),
                                          additionalInfo: additionalInfo)

        let result = try XCTUnwrap(parser.makeLogstashMessage()).metadata

        XCTAssertEqual(result.values.count, expectedPayload.count)
        for (key, value) in result.values {
            XCTAssertEqual(expectedPayload[key], value)
        }
    }
}
