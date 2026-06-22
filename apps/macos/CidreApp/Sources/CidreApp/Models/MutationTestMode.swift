import Foundation

struct MutationTestMode: Codable {
    let schemaVersion: Int
    let status: String
    let summary: String
    let mode: String
    let enabled: Bool
    let requiredPhrase: String
    let environmentEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case status, summary, mode, enabled
        case requiredPhrase = "required_phrase"
        case environmentEnabled = "environment_enabled"
    }
}
