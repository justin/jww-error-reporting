import Foundation

/// Protocol that declares the required components for connecting a reporting service to the `ErrorReporter`.
public protocol ReportingService {
    /// The URL the service should send data to.
    var url: URL { get }
}
