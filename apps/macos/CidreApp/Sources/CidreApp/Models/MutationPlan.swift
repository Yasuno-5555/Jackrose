import Foundation

struct MutationPlan: Codable {
    let schemaVersion: Int
    let status: String?
    let summary: String?
    let planID: String
    let operation: String
    let target: String
    let planHash: String
    let planFile: String?
    let containerSize: String?
    let partitionSize: String?
    let volumeName: String?

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case status, summary, operation, target
        case planID = "plan_id"
        case planHash = "plan_hash"
        case planFile = "plan_file"
        case containerSize = "container_size"
        case partitionSize = "partition_size"
        case volumeName = "volume_name"
    }
}
