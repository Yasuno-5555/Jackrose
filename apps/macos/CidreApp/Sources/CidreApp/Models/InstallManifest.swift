import Foundation

struct InstallManifest: Codable {
    let schemaVersion: Int
    let files: [ManifestFile]

    struct ManifestFile: Codable {
        let path: String
        let sha256: String
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case files
    }
}
