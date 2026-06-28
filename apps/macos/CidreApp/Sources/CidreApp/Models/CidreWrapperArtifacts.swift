import Foundation

public struct SelectedImage: Codable {
    public let selected_id: String
    public let name: String
    public let version: String
    public let arch: String
    public let platform: String
    public let package: String
    public let url: String
    public let manifest: String
    public let sha256: String
    public let first_boot_mode: String
    public let asset_layout: String
    public let install_allowed: Bool
}

public struct VerifiedArtifact: Codable {
    public let verified: Bool
    public let artifact_path: String
    public let manifest_path: String
    public let expected_sha256: String
    public let actual_sha256: String
    public let extract_allowed: Bool
    public let install_allowed: Bool
}

public struct ArtifactStructure: Codable {
    public let archive_path: String
    public let files_count: Int
    public let rootfs_like: Bool
    public let path_traversal_safe: Bool
    public let firstboot_marker_absent: Bool
}

public struct ExtractedRootfs: Codable {
    public let extracted: Bool
    public let sandbox_dir: String
    public let files_extracted: Int
    public let target_staging_allowed: Bool
    public let install_allowed: Bool
}

public struct RootfsValidation: Codable {
    public let rootfs_valid: Bool
    public let sandbox_valid: Bool
    public let target_discovery_allowed: Bool
    public let target_mutation_allowed: Bool
    public let install_allowed: Bool
}

public struct CidreInstallPlan: Codable {
    public let plan_version: String
    public let phase: String
    public let plan_kind: String
    public let selected_id: String
    public let rootfs_dir: String
    public let rootfs_valid: Bool
    public let target: String?
    public let target_selected: Bool
    public let target_discovery_allowed: Bool
    public let target_mutation_allowed: Bool
    public let staging_allowed: Bool
    public let install_allowed: Bool
}

public struct TargetCandidate: Codable, Identifiable {
    public var id: String { target_id }
    public let target_id: String
    public let path: String
    public let parent: String?
    public let type: String
    public let size_bytes: Int64
    public let fstype: String?
    public let label: String?
    public let partlabel: String?
    public let mountpoints: [String]
    public let readonly: Bool
    public let classification: String
    public let eligible: Bool
    public let reasons: [String]
}

public struct TargetCandidates: Codable {
    public let discovery_version: String
    public let phase: String
    public let source_plan: String
    public let readonly_discovery: Bool
    public let target_selected: Bool
    public let target_selection_allowed: Bool
    public let target_mutation_allowed: Bool
    public let staging_allowed: Bool
    public let install_allowed: Bool
    public let minimum_target_size_bytes: Int64
    public let candidates: [TargetCandidate]
}

public struct SelectedTarget: Codable {
    public let selection_version: String
    public let phase: String
    public let source_candidates: String
    public let selected: Bool
    public let target_id: String
    public let path: String
    public let parent: String?
    public let type: String
    public let size_bytes: Int64
    public let fstype: String?
    public let label: String?
    public let partlabel: String?
    public let mountpoints: [String]
    public let readonly: Bool
    public let classification: String
    public let eligible: Bool
    public let confirmation_required: Bool
    public let confirmation_string: String
    public let confirmation_matched: Bool
    public let mount_allowed: Bool
    public let format_allowed: Bool
    public let target_mutation_allowed: Bool
    public let staging_allowed: Bool
    public let install_allowed: Bool
}

public struct FinalInstallContract: Codable {
    public struct RootfsInfo: Codable {
        public let selected_id: String
        public let rootfs_dir: String
        public let rootfs_valid: Bool
    }
    
    public struct TargetInfo: Codable {
        public let target_id: String
        public let path: String
        public let parent: String?
        public let type: String
        public let size_bytes: Int64
        public let classification: String
        public let eligible: Bool
    }
    
    public struct ConfirmationInfo: Codable {
        public let target_selection_confirmed: Bool
        public let confirmation_string: String
    }
    
    public struct PermissionsInfo: Codable {
        public let mount_allowed: Bool
        public let format_allowed: Bool
        public let target_mutation_allowed: Bool
        public let staging_allowed: Bool
        public let boot_policy_mutation_allowed: Bool
        public let install_allowed: Bool
    }

    public let contract_version: String
    public let phase: String
    public let contract_kind: String
    public let rootfs: RootfsInfo
    public let target: TargetInfo
    public let confirmation: ConfirmationInfo
    public let permissions: PermissionsInfo
    public let blocked_operations: [String]
    public let reason: String
}

public struct DryRunStagingPlan: Codable {
    public struct PlannedStep: Codable, Identifiable {
        public var id: Int { step }
        public let step: Int
        public let name: String
        public let action: String
        public let execution_allowed: Bool
    }

    public let dryrun_version: String
    public let phase: String
    public let source_contract: String
    public let dryrun_only: Bool
    public let rootfs_dir: String
    public let target_path: String
    public let planned_steps: [PlannedStep]
    public let blocked_commands: [String]
    public let mount_allowed: Bool
    public let format_allowed: Bool
    public let staging_allowed: Bool
    public let target_mutation_allowed: Bool
    public let boot_policy_mutation_allowed: Bool
    public let install_allowed: Bool
    public let reason: String
}

public struct StagingResult: Codable {
    public struct TargetInfo: Codable {
        public let target_id: String
        public let path: String
        public let classification: String
        public let eligible: Bool
    }
    
    public struct MountInfo: Codable {
        public let mount_performed: Bool
        public let mountpoint: String
        public let unmounted: Bool
    }
    
    public struct StagingInfo: Codable {
        public let method: String
        public let performed: Bool
        public let sync_performed: Bool
    }

    public let staging_version: String
    public let phase: String
    public let source_contract: String
    public let source_dryrun_plan: String
    public let apply_requested: Bool
    public let confirmation_required: Bool
    public let confirmation_string: String
    public let confirmation_matched: Bool
    public let rootfs_dir: String
    public let target: TargetInfo
    public let mount: MountInfo
    public let staging: StagingInfo
    public let post_staging_validation_required: Bool
    public let boot_policy_mutation_performed: Bool
    public let default_boot_changed: Bool
    public let installer_executed: Bool
    public let staging_complete: Bool
    public let install_complete: Bool
    public let reason: String
}

public struct StagedTargetValidation: Codable {
    public struct RootfsPaths: Codable {
        public let usr: Bool
        public let etc: Bool
        public let `var`: Bool
        public let usr_share_cidre_defaults: Bool
    }
    
    public struct CidreComponents: Codable {
        public let cidre_welcome: Bool
        public let cidre_doctor: Bool
        public let cidre_session: Bool
    }

    public let validation_version: String
    public let phase: String
    public let source_staging_result: String
    public let staged_target_valid: Bool
    public let target_path: String
    public let rootfs_paths: RootfsPaths
    public let cidre_components: CidreComponents
    public let forbidden_markers_present: Bool
    public let boot_policy_mutation_detected: Bool
    public let default_boot_changed: Bool
    public let firstboot_handoff_required: Bool
    public let reason: String
}

public struct FirstBootHandoff: Codable {
    public struct ExpectedFirstRun: Codable {
        public let cidre_welcome: Bool
        public let welcome_mode: String
        public let tty_oobe_primary: Bool
    }
    
    public struct OptimizedUpgrade: Codable {
        public let ghostty: Bool
        public let fish: Bool
        public let niri_cidre: Bool
    }
    
    public struct RecoveryContract: Codable {
        public let macos_default_boot_preserved: Bool
        public let manual_startup_options_recovery: Bool
        public let automatic_reboot_performed: Bool
    }

    public let handoff_version: String
    public let phase: String
    public let source_staged_validation: String
    public let firstboot_handoff_complete: Bool
    public let manual_boot_required: Bool
    public let manual_boot_mode: String
    public let desktop_first_expected: Bool
    public let expected_first_run: ExpectedFirstRun
    public let optimized_upgrade_optional: OptimizedUpgrade
    public let boot_policy_mutation_allowed: Bool
    public let boot_policy_mutation_performed: Bool
    public let default_boot_changed: Bool
    public let recovery_contract: RecoveryContract
    public let reason: String
}

public struct InstallerMVPFreeze: Codable {
    public struct PipelineInfo: Codable {
        public let metadata_selection_complete: Bool
        public let artifact_verification_complete: Bool
        public let sandbox_extraction_complete: Bool
        public let rootfs_validation_complete: Bool
        public let target_discovery_complete: Bool
        public let target_selection_complete: Bool
        public let final_contract_complete: Bool
        public let controlled_staging_complete: Bool
        public let post_staging_validation_complete: Bool
        public let firstboot_handoff_complete: Bool
    }
    
    public struct SafetyInfo: Codable {
        public let upstream_installer_executed: Bool
        public let boot_policy_mutation_performed: Bool
        public let default_boot_changed: Bool
        public let automatic_reboot_performed: Bool
        public let partition_table_modified: Bool
    }

    public let mvp_version: String
    public let phase: String
    public let installer_mvp_complete: Bool
    public let pipeline: PipelineInfo
    public let safety: SafetyInfo
    public let reason: String
}
