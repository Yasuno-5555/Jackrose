import Foundation

struct MutationConfirmation: Codable {
    let schemaVersion: Int
    let status: String
    let summary: String
    let confirmationToken: String?
    let confirmationFile: String?
    let expiresAt: String?
    let requiredPhrase: String?

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case status, summary
        case confirmationToken = "confirmation_token"
        case confirmationFile = "confirmation_file"
        case expiresAt = "expires_at"
        case requiredPhrase = "required_phrase"
    }
}
