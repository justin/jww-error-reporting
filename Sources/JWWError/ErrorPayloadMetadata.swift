import Foundation

typealias ErrorPayloadMetadata = ErrorPayload.Metadata

extension ErrorPayload {
    struct Metadata: Hashable, Codable {
        let values: [ErrorPayloadKey: AnyHashable]

        private struct MetadataKeys: CodingKey {
            let stringValue: String

            var intValue: Int? {
                Int(stringValue)
            }

            init(_ key: String) {
                self.init(stringValue: key)
            }

            init(stringValue key: String) {
                self.stringValue = key
            }

            init?(intValue: Int) {
                self.stringValue = "\(intValue)"
            }
        }

        init(values: [ErrorPayloadKey: AnyHashable]) {
            self.values = values
        }

        // JWW: 01/24/21
        // This is probably pretty buggy, but it doesn't matter since we
        // aren't really decoding these values anywhere in production.
        // If anywhere, its in tests only.
        init(from decoder: Decoder) throws {
            var parsedValues: [ErrorPayloadKey: AnyHashable] = [:]

            let container = try decoder.container(keyedBy: MetadataKeys.self)

            for key in container.allKeys {
                if let bool = try? container.decode(Bool.self, forKey: key) {
                    parsedValues[ErrorPayloadKey(key.stringValue)] = bool
                } else if let int = try? container.decode(Int.self, forKey: key) {
                    parsedValues[ErrorPayloadKey(key.stringValue)] = int
                } else if let float = try? container.decode(Float.self, forKey: key) {
                    parsedValues[ErrorPayloadKey(key.stringValue)] = float
                } else if let double = try? container.decode(Double.self, forKey: key) {
                    parsedValues[ErrorPayloadKey(key.stringValue)] = double
                } else if let string = try? container.decode(String.self, forKey: key) {
                    parsedValues[ErrorPayloadKey(key.stringValue)] = string
                } else if let url = try? container.decode(URL.self, forKey: key) {
                    parsedValues[ErrorPayloadKey(key.stringValue)] = url
                } else {
                    let message = "Unable to decode value for key \(key.stringValue)"
                    throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: message)
                }
            }

            self.values = parsedValues
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: MetadataKeys.self)

            for (key, value) in values {
                let dynamicKey = MetadataKeys(key.rawValue)
                switch value {
                case let bool as Bool:
                    try container.encode(bool, forKey: dynamicKey)
                case let int as Int:
                    try container.encode(int, forKey: dynamicKey)
                case let float as Float: // Also Float32
                    try container.encode(float, forKey: dynamicKey)
                case let double as Double: // Also Float64
                    try container.encode(double, forKey: dynamicKey)
                case let string as String:
                    try container.encode(string, forKey: dynamicKey)
                case let url as URL:
                    try container.encode(url, forKey: dynamicKey)
                default:
                    let message = "Unable to encode value of type \(type(of: value))"
                    throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [dynamicKey], debugDescription: message))
                }
            }
        }
    }
}
