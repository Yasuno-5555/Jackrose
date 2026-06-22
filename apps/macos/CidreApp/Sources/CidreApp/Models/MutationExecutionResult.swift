import Foundation

struct MutationExecutionResult: Codable {
    let schemaVersion: Int
    let status: String
    let summary: String
    let exitCode: Int
    let checks: [GateCheck]

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case status, summary, checks
        case exitCode = "exit_code"
    }
}
