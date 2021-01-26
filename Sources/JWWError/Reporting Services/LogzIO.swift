import Foundation

/// Reporting service implementation that connects to logz.io's backend.
public struct LogzIO: ReportingService {
    public enum Connection {
        /// An HTTP connection.
        case insecure

        /// An HTTPS connection.
        case secure

        /// A TCP / Streaming connection.
        case streaming

        /// The port number to use for the selected connection type.
        ///
        /// via: https://docs.logz.io/shipping/log-sources/json-uploads.html
        public var port: Int {
            let port: Int
            switch self {
            case .insecure:
                port = 8070
            case .secure:
                port = 8071
            case .streaming:
                port = 5052
            }

            return port
        }
    }

    /// Supported regions
    ///
    /// https://docs.logz.io/user-guide/accounts/account-region.html
    public enum Region: String {
        /// The US East (Northern Virginia) / AWS region.
        case east = "listener.logz.io"

        /// The West US 2 (Washington) / Azure region.
        case west = "listener-wa.logz.io"

        /// The host address for the selection region.
        public var host: String {
            rawValue
        }
    }

    public let url: URL


    /// Create and return a new Logz.io reporting service.
    ///
    /// - Parameters:
    ///   - token: The Logz.io token to use for the connection.
    ///   - region: The region that your Logz.io instance is hosted.
    ///   - connection: The type of connection to use to send logging data.
    ///   - type: THe type of data to send. Defaults to "error"
    public init(token: String, region: Region = .east, connection: Connection = .secure, type: String = "error") throws {
        var components = URLComponents()
        components.scheme = "https"
        components.host = region.host

        components.port = connection.port
        components.queryItems = [
            URLQueryItem(name: "token", value: token),
            URLQueryItem(name: "type", value: type)
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        self.url = url
    }
}
