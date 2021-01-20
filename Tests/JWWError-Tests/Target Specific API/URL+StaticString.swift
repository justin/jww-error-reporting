import Foundation

extension URL {
    /// Initialize a non-optional `URL` instance from a static string that converts to known URL.
    init(staticString string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }

        self = url
    }
}
