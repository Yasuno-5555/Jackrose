import Foundation

final class WizardEngine {
    static let shared = WizardEngine()

    private init() {}

    func stages(for mode: WizardMode) -> [WizardStage] {
        switch mode {
        case .install:
            return [.welcome, .compatibility, .backupSafety, .diskPlanning, .installPlan, .privilegedPreparation, .seedGeneration, .artifactPreparation, .installExecution, .postInstallVerification, .finish]
        case .uninstall:
            return [.uninstallWelcome, .uninstallExport, .uninstallDiskScan, .uninstallTargetReview, .uninstallPlan, .uninstallConfirmation, .uninstallExecution, .uninstallVerification, .uninstallFinish]
        case .repair:
            return [.repairOverview, .failureScan, .logExport, .rescueStatus, .recoveryAction, .repairReport]
        }
    }

    func operations(for mode: WizardMode) -> [WizardOperation] {
        switch mode {
        case .install:
            return [
                WizardOperation(id: "compatibility-check", title: "Run compatibility checks", category: "setup", stage: .compatibility, privilegeLevel: .none, destructive: false, requiresConfirmation: false, requiresHelper: false, dryRunAvailable: false, command: "scripts/cidre-app-wizard-run --operation compatibility-check --json", rollbackHint: nil),
                WizardOperation(id: "safety-check", title: "Generate backup and safety guidance", category: "setup", stage: .backupSafety, privilegeLevel: .none, destructive: false, requiresConfirmation: false, requiresHelper: false, dryRunAvailable: false, command: "scripts/cidre-app-wizard-run --operation safety-check --json", rollbackHint: nil),
                WizardOperation(id: "disk-scan", title: "Scan disk layout", category: "disk", stage: .diskPlanning, privilegeLevel: .none, destructive: false, requiresConfirmation: false, requiresHelper: false, dryRunAvailable: true, command: "scripts/cidre-app-disk-scan --json", rollbackHint: nil),
                WizardOperation(id: "install-plan", title: "Build install plan", category: "setup", stage: .installPlan, privilegeLevel: .none, destructive: false, requiresConfirmation: false, requiresHelper: false, dryRunAvailable: false, command: "scripts/cidre-app-install-plan-current --json", rollbackHint: nil),
                WizardOperation(id: "helper-status", title: "Check helper readiness", category: "helper", stage: .privilegedPreparation, privilegeLevel: .helper, destructive: false, requiresConfirmation: false, requiresHelper: false, dryRunAvailable: false, command: "scripts/cidre-app-helper-status --json", rollbackHint: nil),
                WizardOperation(id: "seed-generate", title: "Generate seed artifacts", category: "artifacts", stage: .seedGeneration, privilegeLevel: .none, destructive: false, requiresConfirmation: false, requiresHelper: false, dryRunAvailable: false, command: "scripts/cidre-app-wizard-run --operation seed-generate --json", rollbackHint: nil),
                WizardOperation(id: "artifact-prepare", title: "Prepare setup artifacts", category: "artifacts", stage: .artifactPreparation, privilegeLevel: .none, destructive: false, requiresConfirmation: false, requiresHelper: false, dryRunAvailable: false, command: "scripts/cidre-app-wizard-run --operation artifact-prepare --json", rollbackHint: nil),
                WizardOperation(id: "install-execute", title: "Run prepared install stage", category: "setup", stage: .installExecution, privilegeLevel: .external, destructive: false, requiresConfirmation: false, requiresHelper: false, dryRunAvailable: false, command: "scripts/cidre-app-install-wizard --json", rollbackHint: "Review generated artifacts and the restore report in the app." ),
                WizardOperation(id: "post-install-verify", title: "Verify post-install readiness", category: "verify", stage: .postInstallVerification, privilegeLevel: .none, destructive: false, requiresConfirmation: false, requiresHelper: false, dryRunAvailable: false, command: "scripts/cidre-app-wizard-run --operation post-install-verify --json", rollbackHint: nil),
                WizardOperation(id: "setup-report", title: "Write setup report", category: "report", stage: .finish, privilegeLevel: .none, destructive: false, requiresConfirmation: false, requiresHelper: false, dryRunAvailable: false, command: "scripts/cidre-app-wizard-report --mode install --json", rollbackHint: nil)
            ]
        case .uninstall:
            return [
                WizardOperation(id: "export-state", title: "Export state before uninstall", category: "export", stage: .uninstallExport, privilegeLevel: .none, destructive: false, requiresConfirmation: false, requiresHelper: false, dryRunAvailable: false, command: "scripts/cidre-app-uninstall-wizard --json", rollbackHint: nil),
                WizardOperation(id: "uninstall-disk-scan", title: "Scan uninstall targets", category: "disk", stage: .uninstallDiskScan, privilegeLevel: .none, destructive: false, requiresConfirmation: false, requiresHelper: false, dryRunAvailable: true, command: "scripts/cidre-app-disk-scan --json", rollbackHint: nil),
                WizardOperation(id: "target-classify", title: "Classify candidate targets", category: "disk", stage: .uninstallTargetReview, privilegeLevel: .none, destructive: false, requiresConfirmation: false, requiresHelper: false, dryRunAvailable: false, command: "scripts/cidre-app-target-classify --json", rollbackHint: nil),
                WizardOperation(id: "uninstall-plan", title: "Build uninstall plan", category: "setup", stage: .uninstallPlan, privilegeLevel: .none, destructive: false, requiresConfirmation: false, requiresHelper: false, dryRunAvailable: false, command: "scripts/cidre-app-wizard-plan --mode uninstall --json", rollbackHint: nil),
                WizardOperation(id: "helper-delete-check", title: "Prepare authenticated deletion", category: "helper", stage: .uninstallExecution, privilegeLevel: .helper, destructive: true, requiresConfirmation: true, requiresHelper: true, dryRunAvailable: true, command: "scripts/cidre-app-helper-status --json", rollbackHint: "Export state before deleting a selected Cidre target."),
                WizardOperation(id: "post-uninstall-verify", title: "Verify post-uninstall state", category: "verify", stage: .uninstallVerification, privilegeLevel: .none, destructive: false, requiresConfirmation: false, requiresHelper: false, dryRunAvailable: false, command: "scripts/cidre-app-wizard-run --operation post-uninstall-verify --json", rollbackHint: nil),
                WizardOperation(id: "uninstall-report", title: "Write uninstall report", category: "report", stage: .uninstallFinish, privilegeLevel: .none, destructive: false, requiresConfirmation: false, requiresHelper: false, dryRunAvailable: false, command: "scripts/cidre-app-wizard-report --mode uninstall --json", rollbackHint: nil)
            ]
        case .repair:
            return [
                WizardOperation(id: "failure-scan", title: "Scan failure reports", category: "repair", stage: .failureScan, privilegeLevel: .none, destructive: false, requiresConfirmation: false, requiresHelper: false, dryRunAvailable: false, command: "scripts/cidre-app-repair-wizard --json", rollbackHint: nil),
                WizardOperation(id: "log-export", title: "Collect logs", category: "repair", stage: .logExport, privilegeLevel: .none, destructive: false, requiresConfirmation: false, requiresHelper: false, dryRunAvailable: false, command: "scripts/cidre-app-runtime-log-collect --json", rollbackHint: nil),
                WizardOperation(id: "rescue-status", title: "Inspect rescue state", category: "repair", stage: .rescueStatus, privilegeLevel: .none, destructive: false, requiresConfirmation: false, requiresHelper: false, dryRunAvailable: false, command: "scripts/cidre-recovery rescue-status", rollbackHint: nil),
                WizardOperation(id: "repair-report", title: "Write repair report", category: "report", stage: .repairReport, privilegeLevel: .none, destructive: false, requiresConfirmation: false, requiresHelper: false, dryRunAvailable: false, command: "scripts/cidre-app-wizard-report --mode repair --json", rollbackHint: nil)
            ]
        }
    }
}
