import Foundation

struct LiveDrillPlan: Codable {
    let schemaVersion: Int
    let status: String?
    let summary: String?
    let drillID: String
    let level: Int
    let operation: String
    let target: String?
    let planHash: String
    let planFile: String?

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case status, summary, level, operation, target
        case drillID = "drill_id"
        case planHash = "plan_hash"
        case planFile = "plan_file"
    }
}
