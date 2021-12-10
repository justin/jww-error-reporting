import Foundation
import Combine
import os

/// Configuration type that defines the reporting service and app info for the
/// error reporter.
public struct ErrorReporterConfiguration {
    public let service: ReportingService
    public let appInfo: AppInfoProviding

    public init(service: ReportingService, appInfo: AppInfoProviding) {
        self.service = service
        self.appInfo = appInfo
    }
}

/// Reporting service that sends error reports and other types of telemetry to a backend reporting service.
public final class ErrorReporter: NSObject {
    /// Optional handler called if uploads are completed by the system in the background.
    public var backgroundHandler: (() -> Void)?

    /// The unique session identifier for uploading error data in the background.
    public static let sessionIdentifier: String = "com.justinwme.jwwerror.error-reporter"

    /// The shared error reporter.
    ///
    /// To get an instance of `ErrorReporter`, always use the shared class property. Creating an instance of the error reporter is not supported.
    public static let shared = ErrorReporter()

    /// The reporting service to send the error data to, if any.
    ///
    /// If this value is nil, the errors will be shot into space (or just /dev/null).
    public private(set) var errorService: ReportingService?

    /// Application information to pass up with each error report.
    public private(set) var appInfo: AppInfoProviding

    /// Boolean that disables sending of data to the reporting service if set to true.
    public var isDebugMode: Bool = false

    /// URLSession instance that is used to send data up to the server.
    private var session: URLSession!

    /// Cancellable observers from Combine.
    private var cancellables: Set<AnyCancellable> = []

    /// Delegate queue we run all of the `session` delegate operations through.
    private lazy var sessionQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        queue.name = "Error reporting queue"

        return queue
    }()

    /// JSON encoder used for converting errors into JSON payloads.
    private lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601milliseconds
        return encoder
    }()

    /// Formatter used for logging metrics from the URLSession delegate.
    private lazy var metricsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .default
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full

        return formatter
    }()

    /// Log used for . . . reporting on the reporter.
    private let log: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "reporting")

    private struct Constants {
        static let contentType: String = "application/json"
        static let postMethod: String = "POST"
    }

    // MARK: Initialization
    // ====================================
    // Initialization
    // ====================================

    /// Create and return a new error reporter with no service set.
    internal override convenience init() {
        self.init(configuration: nil)
    }

    /// Create and return a new error reporter with the reporting service set, if any.
    ///
    /// - Parameter service: Optional. The reporting service configuration to initialize with.
    internal init(configuration: ErrorReporterConfiguration?) {
        self.appInfo = configuration?.appInfo ?? ZeroAppInfo.missing
        self.errorService = configuration?.service

        let configuration = URLSessionConfiguration.background(withIdentifier: Self.sessionIdentifier)
        configuration.networkServiceType = .background
        configuration.isDiscretionary = true
        configuration.allowsCellularAccess = true
        // If this hasn't uploaded within 12 hours, let's just say it's not worth it.
        configuration.timeoutIntervalForResource = 60 * 60 * 12
        configuration.httpAdditionalHeaders = [
            "Content-Type": Constants.contentType
        ]

        super.init()

        assert(sessionQueue.maxConcurrentOperationCount == 1) // Sanity check
        self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: sessionQueue)
        self.session.sessionDescription = "Error Reporter Networking"
    }

    deinit {
        session.invalidateAndCancel()
    }

    // MARK: Public Methods
    // ====================================
    // Public Methods
    // ====================================

    /// Update the reporter configuration with a new reporting service.
    ///
    /// - Parameter configuration: The reporter configuration to apply to the reporter.
    public func configure(configuration: ErrorReporterConfiguration) {
        self.errorService = configuration.service
        self.appInfo = configuration.appInfo
    }

    /// Post an error up to the active reporting service.
    ///
    /// - Parameters:
    ///     - error: The error to upload.
    ///     - function: The function name to post with the error. The default is the file
    ///                 where `post(error:function:file:line:additionalInfo)` is called.
    ///     - file: The file name to post with the error. The default is the file
    ///             where `post(error:function:file:line:additionalInfo)` is called.
    ///     - line: The line number to post with the error. The default is the line number
    ///             where `post(error:function:file:line:additionalInfo)` is called.
    ///     - additionalInfo: Supplemental key/value pairs that can be associated with the error payload.
    public func post(error: ReportableError,
                     function: String = #function,
                     file: String = #fileID,
                     line: UInt = #line,
                     additionalInfo: [ErrorPayloadKey: AnyHashable] = [:]) {
        guard error.isReportable else {
            return
        }

        guard let service = errorService else {
            log.error("Error cannot be sent. No reporting service configured.")
            return
        }

        do {
            let payload = try ErrorPayload(error: error, function: function, file: file, line: line, appInfo: appInfo, additionalInfo: additionalInfo)
            let request = try createRequest(for: service, payload: payload)

            if isDebugMode {
                log.debug("Debug mode enabled. Error of length \(request.httpBody?.count ?? 0) will not be sent.")
                return
            }

            log.debug("Posting error message of length \(request.httpBody?.count ?? 0).")
            let task = session.dataTask(with: request)
            task.taskDescription = error.message
            task.resume()
        } catch let error as EncodingError {
            log.error("Failed to encode error payload. \(error.errorDescription ?? "Unknown Reason")")
        } catch {
            log.error("Failed to create error payload. Error returned was \(error.localizedDescription)")
        }
    }

    // MARK: Private / Convenience
    // ====================================
    // Private / Convenience
    // ====================================

    private func createRequest(for service: ReportingService, payload: ErrorPayload) throws -> URLRequest {
        var request = URLRequest(url: service.url)
        request.httpMethod = Constants.postMethod
        request.httpBody = try encoder.encode(payload)
        request.addValue(Constants.contentType, forHTTPHeaderField: "Content-Type")
        return request
    }
}

// MARK: URLSessionDelegate
// ====================================
// URLSessionDelegate
// ====================================

extension ErrorReporter: URLSessionTaskDelegate {
    #if !os(macOS)
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if let description = session.sessionDescription {
            log.info("\(description.quoted, privacy: .public) completed all background events.")
        }

        defer {
            self.backgroundHandler = nil
        }

        if let handler = backgroundHandler {
            DispatchQueue.main.async {
                handler()
            }
        }
    }
    #endif

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        let description = session.sessionDescription ?? "UNKNOWN ERROR REPORTING SESSION"

        if let error = error as NSError? {
            log.error("\(description.quoted, privacy: .public) was invalidated because of an error: \(error)")
            return
        }

        log.info("\(description.quoted, privacy: .public) was invalidated.")
    }

    public func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {

    }

    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           willBeginDelayedRequest request: URLRequest,
                           completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        log.info("\(String(reflecting: task)) for request \(String(describing: request)) will now begin.")
        completionHandler(.continueLoading, request)

    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            log.error("Error uploading reporting data: \(String(reflecting: error))")
            return
        }

        if let httpResponse = task.response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            log.error("Response status code != \(httpResponse.statusCode)")
            return
        }
    }

    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didFinishCollecting metrics: URLSessionTaskMetrics) {
        // For now we just care about the last URL and not anything from a redirect.
        guard let url = metrics.transactionMetrics.last?.request.url?.absoluteString else {
            return
        }

        if let intervalString = metricsFormatter.string(from: metrics.taskInterval.duration) {
            log.debug("Task took \(intervalString, privacy: .public). url: \(url)")
        }
    }
}


// MARK: Error Payload Extensions
// ====================================
// Error Payload Extensions
// ====================================
private extension ErrorPayload {
    init(error: ReportableError,
         function: String = #function,
         file: String = #fileID,
         line: UInt = #line,
         appInfo: AppInfoProviding,
         additionalInfo: [ErrorPayloadKey: AnyHashable]) throws {
        let parser = ErrorReporter.Parser(error: error, function: function, file: file, line: line, appInfo: appInfo, additionalInfo: additionalInfo)
        let message = try parser.makeLogstashMessage()
        self = message
    }
}

// MARK: Date Formatting Extensions
// ====================================
// Date Formatting Extensions
// ====================================
private extension DateFormatter {
    /// ISO8601 date formatter with support for internet date times and fractional seconds.
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

private extension JSONEncoder.DateEncodingStrategy {
    /// Custom date encoding strategy that will attempt to decode a date formatted with ISO8601+millisecond precision.
    static let iso8601milliseconds = custom {
        var container = $1.singleValueContainer()
        try container.encode(DateFormatter.iso8601.string(from: $0))
    }
}

// MARK: String Formatting Extensions
// ====================================
// String Formatting Extensions
// ====================================

private extension String {
    // Wraps the string value in single quotes.
    var quoted: String {
        "'" + self + "'"
    }
}

extension URLSessionTask {
    open override var debugDescription: String {
        if let `taskDescription` = taskDescription {
            return taskDescription.quoted
        }

        return super.debugDescription
    }
}
