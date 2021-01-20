import Foundation
import JWWCore
import os.log

internal final class ErrorReporter: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    var backgroundHandler: (() -> Void)?

    /// Log used for . . . reporting on the reporter.
    private static let log: OSLog = {
        let category = LoggingProvider.Category(rawValue: "reporting")
        return OSLog(subsystem: "com.justinwme.jwwerror", category: category)
    }()

    private let url: URL
    private let appInfo: AppInfoProviding
    private var session: URLSession!

    static let sessionIdentifier: String = "com.justinwme.jwwerror.error-reporter"

    private struct Constants {
        static let contentType: String = "application/json"
    }

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    // MARK: Initialization
    // ====================================
    // Initialization
    // ====================================

    internal init(reportingService service: ReportingService, appInfo: AppInfoProviding, session: URLSession) {
        self.url = service.url
        self.appInfo = appInfo
        super.init()
        self.session = session
    }

    internal init(reportingService service: ReportingService, appInfo: AppInfoProviding) {
        self.url = service.url
        self.appInfo = appInfo

        let configuration = URLSessionConfiguration.background(withIdentifier: ErrorReporter.sessionIdentifier)
        configuration.networkServiceType = .background
        configuration.isDiscretionary = true
        // If this hasn't uploaded within 12 hours, let's just say it's not worth it, k?
        configuration.timeoutIntervalForResource = 60 * 60 * 12
        configuration.httpAdditionalHeaders = [
            "Content-Type": Constants.contentType
        ]

        super.init()
        self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    deinit {
        session.invalidateAndCancel()
    }

    // MARK: Public Methods
    // ====================================
    // Public Methods
    // ====================================

    func post(error: ReportableError) throws {
        guard error.isReportable else {
            return
        }

        let payload = try ErrorPayload(error: error, appInfo: appInfo)

        let messageData = try encoder.encode(payload)
        os_log("Posting error message of length %d", log: ErrorReporter.log, type: .debug, messageData.count)

        var request = URLRequest(url: url)
        request.httpBody = messageData
        request.httpMethod = "POST"
        request.addValue(Constants.contentType, forHTTPHeaderField: "Content-Type")
        let task = session.dataTask(with: request)
        task.resume()
    }

    // MARK: URLSessionDelegate
    // ====================================
    // URLSessionDelegate
    // ====================================

    #if !os(macOS)
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        os_log("Finished posting error reporting events.", log: ErrorReporter.log, type: .debug)

        if let handler = backgroundHandler {
            backgroundHandler = nil
            DispatchQueue.main.async {
                handler()
            }
        }
    }
    #endif

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let error = error {
            os_log("Error reporter was invalidated because of error: %@.",
                   log: ErrorReporter.log,
                   type: .error,
                   String(reflecting: error))
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            os_log("Error uploading reporting data: %@.", log: ErrorReporter.log, type: .error, String(reflecting: error))
            return
        }

        if let httpResponse = task.response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            os_log("Response status code != %d", log: ErrorReporter.log, type: .error, httpResponse.statusCode)
            return
        }
    }
}

private extension ErrorPayload {
    init(error: ReportableError, appInfo: AppInfoProviding) throws {
        let parser = ErrorReporter.Parser(error: error, appInfo: appInfo)
        let message = try parser.makeLogstashMessage()
        self = message
    }
}
