import Foundation

struct ControlledInstallPlan: Codable {
    let schemaVersion: Int
    let planID: String
    let mode: String
    let target: String
    let profile: String
    let manualBootOnly: Bool
    let defaultBootMutation: Bool
    let startupDiskMutation: Bool
    let bootPolicyMutation: Bool
    let automaticRestart: Bool
    let planHash: String
    let planFile: String?

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case planID = "plan_id"
        case mode, target, profile
        case manualBootOnly = "manual_boot_only"
        case defaultBootMutation = "default_boot_mutation"
        case startupDiskMutation = "startup_disk_mutation"
        case bootPolicyMutation = "boot_policy_mutation"
        case automaticRestart = "automatic_restart"
        case planHash = "plan_hash"
        case planFile = "plan_file"
    }
}
