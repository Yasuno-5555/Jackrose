import Foundation

struct NoDefaultBootPolicy: Codable {
    let schemaVersion: Int
    let status: String
    let summary: String

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case status, summary
    }
}
