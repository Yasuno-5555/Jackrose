import Foundation

struct InstallPayload: Codable {
    let schemaVersion: Int
    let status: String
    let summary: String
    let stagedFiles: [String]?

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case status, summary
        case stagedFiles = "staged_files"
    }
}
