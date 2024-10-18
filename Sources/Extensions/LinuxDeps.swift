import Foundation

let config_filename = "purekfd_v6_config.json"

extension URL {
    static var documents: URL {
        return URL(fileURLWithPath: "\(NSHomeDirectory())/Documents")
    }
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
