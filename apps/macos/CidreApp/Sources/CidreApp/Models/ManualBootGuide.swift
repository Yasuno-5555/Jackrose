import Foundation

struct ManualBootGuide: Codable {
    let schemaVersion: Int
    let status: String
    let summary: String
    let guide: String

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case status, summary, guide
    }
}
