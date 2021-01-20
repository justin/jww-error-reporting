import Foundation

protocol ReportingService {
    var url: URL { get }
}

struct LogzIOReporter: ReportingService {
    let url: URL

    init?(host: String, port: Int, token: String, type: String = "error") {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.port = port
        components.queryItems = [
            URLQueryItem(name: "token", value: token),
            URLQueryItem(name: "type", value: type)
        ]

        guard let url = components.url else {
            return nil
        }
        self.url = url
    }

    init(url: URL) {
        self.url = url
    }
}
