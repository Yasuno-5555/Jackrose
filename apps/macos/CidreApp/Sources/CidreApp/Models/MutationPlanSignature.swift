import Foundation

struct MutationPlanSignature: Codable {
    let schemaVersion: Int
    let status: String
    let summary: String
    let planHash: String
    let signatureFile: String?

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case status, summary
        case planHash = "plan_hash"
        case signatureFile = "signature_file"
    }
}
