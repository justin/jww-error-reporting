import Foundation

/// Typealias for easier access to the ErrorReporter.Parser type.
typealias ErrorParser = ErrorReporter.Parser

extension ErrorReporter {
    /// Value type that converts a reportable error into a valid JSON payload to send to logstash.
    struct Parser {
        /// The reported error to parse.
        let error: ReportableError

        /// Information about the application that is reporting the error.
        let appInfo: AppInfoProviding

        /// Creates the logstash message that will be send to the reporting service.
        func makeLogstashMessage() throws -> ErrorPayload {
            ErrorPayload(domain: type(of: error).domain,
                         code: error.code,
                         message: error.message,
                         environment: appInfo.environment,
                         date: Date(),
                         app: ErrorPayload.AppInfo(appInfo),
                         metadata: ErrorPayloadMetadata(values: error.userInfo))
        }
    }
}
