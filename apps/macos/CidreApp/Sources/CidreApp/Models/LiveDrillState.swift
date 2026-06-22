import Foundation

struct LiveDrillState: Codable {
    let schemaVersion: Int
    let status: String
    let summary: String
    let drillID: String?
    let level: Int?

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case status, summary
        case drillID = "drill_id"
        case level
    }
}
