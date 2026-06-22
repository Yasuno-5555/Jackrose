import Foundation

struct InstallTarget: Codable {
    let schemaVersion: Int
    let status: String
    let summary: String
    let target: String?
    let classification: String?

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case status, summary, target, classification
    }
}
