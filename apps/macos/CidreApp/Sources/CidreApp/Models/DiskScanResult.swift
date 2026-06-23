import Foundation

struct DiskScanResult: Codable {
    let schemaVersion: Int
    let command: String
    let status: String
    let summary: String
    let startupIdentifiers: [String]
    let targets: [DiskTarget]

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case command, status, summary, targets
        case startupIdentifiers = "startup_identifiers"
    }
}
