import Foundation

typealias ErrorParser = ErrorReporter.Parser

extension ErrorReporter {
    struct Parser {
        private let error: ReportableError
        private let appInfo: AppInfoProviding

        init(error: ReportableError, appInfo: AppInfoProviding) {
            self.error = error
            self.appInfo = appInfo
        }

        func makeLogstashMessage() throws -> ErrorPayload {
            ErrorPayload(domain: type(of: error).domain,
                         code: error.code,
                         message: error.message,
                         date: Date(),
                         app: ErrorPayload.AppInfo(appInfo))
        }
    }
}
