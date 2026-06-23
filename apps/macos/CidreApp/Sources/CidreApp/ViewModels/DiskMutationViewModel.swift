import Foundation

enum PartitionMode: String, CaseIterable {
    case max    = "max"
    case auto   = "auto"
    case min    = "min"
    case custom = "custom"

    var label: String {
        switch self {
        case .max:    return "Max"
        case .auto:   return "Auto"
        case .min:    return "Min"
        case .custom: return "Custom"
        }
    }

    var description: String {
        switch self {
        case .max:    return "Largest possible Cidre partition (macOS gets its recommended minimum)"
        case .auto:   return "Balanced split — ~60% of available space for Cidre"
        case .min:    return "Smallest useful Cidre partition (20 GB)"
        case .custom: return "Enter container and partition sizes manually"
        }
    }
}

enum DiskPlanningGuideStep: Equatable {
    case noCandidateTargets
    case selectTarget
    case enableMutationTestMode
    case enableInstallerOverride
    case capturePreSnapshot
    case resolveRecoverySafety
    case resolveProtectedPartitionSafety
    case createPlan
    case validatePreview
    case confirmAndExecute
    case reviewExecution
}

final class DiskMutationViewModel: ObservableObject {
    @Published var killSwitchState: InstallerKillSwitchState = .containmentDefault
    @Published var mutationTestMode: MutationTestMode?
    @Published var disposableTarget: DisposableTarget?
    @Published var installTarget: InstallTarget?
    @Published var diskScanResult: DiskScanResult?
    @Published var snapshotAvailability = DiskSnapshotAvailability(beforeAvailable: false, afterAvailable: false, beforePath: nil, afterPath: nil)
    @Published var protectedPartitionState: ProtectedPartitionGuardState?
    @Published var diskDiffState: DiskDiffState?
    @Published var recoverySurvivalState: RecoverySurvivalState?
    @Published var gateState: GateState?
    @Published var helperGateDecision: GateDecision?
    @Published var target = ""
    @Published var partitionMode: PartitionMode = .auto
    @Published var containerSize = ""
    @Published var partitionSize = ""
    @Published var volumeName = "Cidre"
    @Published var confirmation = ""
    @Published var planID: String?
    @Published var planFile: String?
    @Published var mutationPlan: MutationPlan?
    @Published var planSignature: MutationPlanSignature?
    @Published var mutationConfirmation: MutationConfirmation?
    @Published var mutationVerification: MutationVerificationResult?
    @Published var mutationReportMarkdown = ""
    @Published var liveDrillState: LiveDrillState?
    @Published var liveDrillPlan: LiveDrillPlan?
    @Published var liveDrillVerification: LiveDrillResult?
    @Published var liveDrillReportMarkdown = ""
    @Published var controlledInstallLastResult: [String: Any]?
    @Published var controlledInstallPlan: ControlledInstallPlan?
    @Published var manualBootGuide: ManualBootGuide?
    @Published var mutationExecutionResult: MutationExecutionResult?
    @Published var requiredConfirmation: String?
    @Published var execution: CommandExecution?
    @Published var guidedActionExecution: CommandExecution?
    @Published var guidedActionTitle: String?
    @Published var isRunning = false
    @Published var limitsInfo: [String: Any]?
    private var plannedInputSignature: String?
    private var refreshGeneration = 0

    var canPreview: Bool {
        let isSafeVolume = installTarget?.classification == "cidre-volume"
        let killSwitchPassed = isSafeVolume || killSwitchState.destructiveInstallAllowed
        return killSwitchPassed
            && planID != nil
            && planFile != nil
            && plannedInputSignature == inputSignature
            && !target.isEmpty
    }

    var canExecute: Bool {
        let isSafeVolume = installTarget?.classification == "cidre-volume"
        let killSwitchPassed = isSafeVolume || killSwitchState.destructiveInstallAllowed
        return killSwitchPassed
            && canPreview
            && helperGateDecision?.status == "passed"
            && requiredConfirmation?.trimmingCharacters(in: .whitespacesAndNewlines) == confirmation.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canCreatePlan: Bool {
        let isSafeVolume = installTarget?.classification == "cidre-volume"
        let killSwitchPassed = isSafeVolume || killSwitchState.destructiveInstallAllowed
        let mutationTestPassed = isSafeVolume || mutationTestMode?.enabled == true
        return killSwitchPassed
            && mutationTestPassed
            && snapshotAvailability.beforeAvailable
            && recoverySurvivalState?.status == "passed"
            && protectedPartitionState?.status == "passed"
            && installTarget?.status == "passed"
            && !target.isEmpty
            && !isRunning
    }

    var createPlanBlockers: [String] {
        var blockers: [String] = []
        let isSafeVolume = installTarget?.classification == "cidre-volume"
        if !isSafeVolume && !killSwitchState.destructiveInstallAllowed {
            blockers.append("Installer test override is still disabled by DFU containment.")
        }
        if !isSafeVolume && mutationTestMode?.enabled != true {
            blockers.append("Controlled Mutation Test Mode is disabled.")
        }
        if target.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            blockers.append("Select a target before creating a plan.")
        }
        if snapshotAvailability.beforeAvailable == false {
            blockers.append("Capture a fresh pre-install disk snapshot first.")
        }
        if recoverySurvivalState?.status != "passed" {
            blockers.append("Recovery survival checks must pass first.")
        }
        if protectedPartitionState?.status != "passed" {
            blockers.append("Protected partition guard must pass first.")
        }
        if installTarget?.status != "passed" {
            blockers.append(installTarget?.summary ?? "The selected target is not approved as an install target.")
        }
        if isRunning {
            blockers.append("Another disk action is already running.")
        }
        return blockers
    }

    var validatePreviewBlockers: [String] {
        var blockers: [String] = []
        let isSafeVolume = installTarget?.classification == "cidre-volume"
        if !isSafeVolume && !killSwitchState.destructiveInstallAllowed {
            blockers.append("Installer test override is still disabled by DFU containment.")
        }
        if planID == nil || planFile == nil {
            blockers.append("Create a plan before validating the preview.")
        }
        if plannedInputSignature != inputSignature {
            blockers.append("The target or size inputs changed, so the plan must be recreated.")
        }
        if target.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            blockers.append("Select a target before validating the preview.")
        }
        return blockers
    }

    var executeBlockers: [String] {
        var blockers: [String] = []
        let isSafeVolume = installTarget?.classification == "cidre-volume"
        if !isSafeVolume && !killSwitchState.destructiveInstallAllowed {
            blockers.append("Installer test override is still disabled by DFU containment.")
        }
        if !canPreview {
            blockers.append("Validate the current preview before running the authenticated disk change.")
        }
        if helperGateDecision?.status != "passed" {
            blockers.append(helperGateDecision?.summary ?? "The helper gate has not approved disk execution yet.")
        }
        if let requiredConfirmation,
           requiredConfirmation.trimmingCharacters(in: .whitespacesAndNewlines) != confirmation.trimmingCharacters(in: .whitespacesAndNewlines) {
            blockers.append("Enter the exact confirmation phrase before executing the disk change.")
        }
        if isRunning {
            blockers.append("Another disk action is already running.")
        }
        return blockers
    }

    var maxPartitionHuman: String {
        guard let limits = limitsInfo,
              let bytes = limits["max_partition_bytes"] as? Int else { return "—" }
        return formatHuman(bytes)
    }

    var candidateTargets: [DiskTarget] {
        let startupIDs = Set(diskScanResult?.startupIdentifiers ?? [])
        return (diskScanResult?.targets ?? []).filter { target in
            if !target.protected {
                return true
            }
            return startupIDs.contains(target.id)
        }
    }

    var protectedTargets: [DiskTarget] {
        (diskScanResult?.targets ?? []).filter { $0.protected }
    }

    var startupTargetIdentifier: String? {
        if let selected = installTarget?.target, !selected.isEmpty {
            return selected
        }
        return diskScanResult?.startupIdentifiers.first
    }

    var hasPreviewResult: Bool {
        execution?.command == "scripts/cidre-app-helper-command"
    }

    var hasMutationExecutionResult: Bool {
        execution?.command == "scripts/cidre-app-mutation-execute-test"
    }

    var guideStep: DiskPlanningGuideStep {
        if candidateTargets.isEmpty {
            return .noCandidateTargets
        }
        if installTarget?.status != "passed" {
            return .selectTarget
        }
        if mutationTestMode?.enabled != true {
            return .enableMutationTestMode
        }
        if !killSwitchState.destructiveInstallAllowed {
            return .enableInstallerOverride
        }
        if !snapshotAvailability.beforeAvailable {
            return .capturePreSnapshot
        }
        if recoverySurvivalState?.status != "passed" {
            return .resolveRecoverySafety
        }
        if protectedPartitionState?.status != "passed" {
            return .resolveProtectedPartitionSafety
        }
        if planID == nil || planFile == nil {
            return .createPlan
        }
        if !hasPreviewResult {
            return .validatePreview
        }
        if requiredConfirmation != nil && !hasMutationExecutionResult {
            return .confirmAndExecute
        }
        return .reviewExecution
    }

    var autoPartitionHuman: String {
        guard let limits = limitsInfo,
              let bytes = limits["auto_partition_bytes"] as? Int else { return "—" }
        return formatHuman(bytes)
    }

    var bootSafetyDisplayStatus: String {
        if let status = gateState?.status, !status.isEmpty {
            return status
        }
        if guidedActionTitle == "Recheck Boot Safety",
           let status = guidedActionExecution?.parsedResult?.status,
           !status.isEmpty {
            return status
        }
        return "unknown"
    }

    private func formatHuman(_ bytes: Int) -> String {
        let gb = Double(bytes) / 1_000_000_000
        return String(format: "%.1f GB", gb)
    }

    func detectStartupStore(repositoryPath: String) {
        guard target.isEmpty else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let process = Process()
            let pipe = Pipe()
            process.executableURL = URL(fileURLWithPath: "/usr/sbin/diskutil")
            process.arguments = ["info", "-plist", "/"]
            process.standardOutput = pipe
            process.standardError = Pipe()
            do {
                try process.run()
                process.waitUntilExit()
                guard process.terminationStatus == 0,
                      let plist = try PropertyListSerialization.propertyList(from: pipe.fileHandleForReading.readDataToEndOfFile(), options: [], format: nil) as? [String: Any],
                      let stores = plist["APFSPhysicalStores"] as? [[String: Any]],
                      let identifier = stores.first?["APFSPhysicalStore"] as? String else { return }
                DispatchQueue.main.async {
                    guard let self, self.target.isEmpty else { return }
                    self.target = identifier
                    TargetBoundStateCleanupService.shared.purgeStaleState(repositoryPath: repositoryPath, currentTarget: identifier)
                    self.fetchLimits()
                    self.refreshSafetyStatus(repositoryPath: repositoryPath)
                }
            } catch {
                return
            }
        }
    }

    func purgeStaleTargetState(repositoryPath: String) {
        TargetBoundStateCleanupService.shared.purgeStaleState(repositoryPath: repositoryPath, currentTarget: target)
    }

    func enableMutationTestMode(repositoryPath: String) {
        runGuidedAction(
            repositoryPath: repositoryPath,
            title: "Enable Test Mode",
            command: "scripts/cidre-app-mutation-test-mode",
            arguments: ["--enable", "--phrase", "I understand this can destroy the selected disposable target.", "--json"],
            refreshKillSwitchState: true
        )
    }

    func enableInstallerTestOverride(repositoryPath: String) {
        runGuidedAction(
            repositoryPath: repositoryPath,
            title: "Enable Installer Override",
            command: "scripts/cidre-app-installer-killswitch",
            arguments: ["--enable-for-test", "--i-understand-dfu-risk", "--json"],
            refreshKillSwitchState: true
        )
    }

    func captureSnapshot(label: String, repositoryPath: String) {
        runGuidedAction(
            repositoryPath: repositoryPath,
            title: label == "manual-before" ? "Capture Pre Snapshot" : "Capture Post Snapshot",
            command: "scripts/cidre-app-disk-snapshot",
            arguments: ["--label", label, "--json"]
        )
    }

    func generateRollbackReport(repositoryPath: String) {
        runGuidedAction(
            repositoryPath: repositoryPath,
            title: "Generate Rollback Report",
            command: "scripts/cidre-app-gate-report",
            arguments: ["--json"]
        )
    }

    func refreshBootSafety(repositoryPath: String) {
        runGuidedAction(
            repositoryPath: repositoryPath,
            title: "Recheck Boot Safety",
            command: "scripts/cidre-app-boot-safety-gate",
            arguments: ["--json"]
        )
    }

    func refreshKillSwitch(repositoryPath: String) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let execution = LiveCommandRunner.shared.run(
                "scripts/cidre-app-installer-killswitch",
                arguments: ["--status", "--json"],
                repositoryPath: repositoryPath,
                isMockMode: false
            )
            let state: InstallerKillSwitchState
            if let data = execution.stdout.data(using: .utf8),
               let decoded = try? JSONDecoder().decode(InstallerKillSwitchState.self, from: data) {
                state = decoded
            } else {
                state = .containmentDefault
            }
            let mutationMode = MutationTestModeService.shared.status(repositoryPath: repositoryPath)
            DispatchQueue.main.async {
                self?.killSwitchState = state
                self?.mutationTestMode = mutationMode
            }
        }
    }

    func refreshSafetyStatus(repositoryPath: String) {
        refreshGeneration += 1
        let generation = refreshGeneration
        let currentTarget = target
        let hasExecution = execution != nil
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let killSwitchExecution = LiveCommandRunner.shared.run(
                "scripts/cidre-app-installer-killswitch",
                arguments: ["--status", "--json"],
                repositoryPath: repositoryPath,
                isMockMode: false
            )
            let killSwitchState: InstallerKillSwitchState
            if let data = killSwitchExecution.stdout.data(using: .utf8),
               let decoded = try? JSONDecoder().decode(InstallerKillSwitchState.self, from: data) {
                killSwitchState = decoded
            } else {
                killSwitchState = .containmentDefault
            }
            let mutationTestMode = MutationTestModeService.shared.status(repositoryPath: repositoryPath)
            let diskScanResult = DiskScanService.shared.scan(repositoryPath: repositoryPath)
            let snapshotAvailability = DiskSnapshotService.shared.availability(repositoryPath: repositoryPath)
            let protectedPartitionState = ProtectedPartitionGuardService.shared.evaluate(repositoryPath: repositoryPath, snapshots: snapshotAvailability)
            let diskDiffState = DiskDiffService.shared.evaluate(repositoryPath: repositoryPath, snapshots: snapshotAvailability)
            let recoverySurvivalState = RecoverySurvivalService.shared.evaluate(repositoryPath: repositoryPath)
            let gateState = GateEvaluationService.shared.evaluate(scope: "install", repositoryPath: repositoryPath)
            let disposableTarget = DisposableTargetCheckService.shared.evaluate(target: currentTarget, repositoryPath: repositoryPath)
            let installTarget = InstallTargetCheckService.shared.check(repositoryPath: repositoryPath, currentTarget: currentTarget)
            let helperGateDecision = HelperGateService.shared.evaluate(operation: "partition-create", repositoryPath: repositoryPath)
            let mutationVerification = MutationVerificationService.shared.report(repositoryPath: repositoryPath)
            let mutationReportMarkdown = MutationReportService.shared.markdown(repositoryPath: repositoryPath)
            let liveDrillState = LiveDrillService.shared.state(repositoryPath: repositoryPath)
            let liveDrillVerification = LiveDrillVerificationService.shared.result(repositoryPath: repositoryPath)
            let liveDrillReportMarkdown = LiveDrillReportService.shared.markdown(repositoryPath: repositoryPath)
            let controlledInstallLastResult = ControlledInstallService.shared.lastResult(repositoryPath: repositoryPath)
            let controlledInstallPlan = InstallPlanService.shared.lastPlan(repositoryPath: repositoryPath)
            let manualBootGuide = ManualBootGuideService.shared.guide(repositoryPath: repositoryPath)
            let mutationExecutionResult = hasExecution ? MutationExecutionService.shared.report(repositoryPath: repositoryPath) : nil

            DispatchQueue.main.async {
                guard let self, generation == self.refreshGeneration else { return }
                self.killSwitchState = killSwitchState
                self.mutationTestMode = mutationTestMode
                self.diskScanResult = diskScanResult
                self.snapshotAvailability = snapshotAvailability
                self.protectedPartitionState = protectedPartitionState
                self.diskDiffState = diskDiffState
                self.recoverySurvivalState = recoverySurvivalState
                self.gateState = gateState
                self.disposableTarget = disposableTarget
                self.installTarget = installTarget
                self.helperGateDecision = helperGateDecision
                self.mutationVerification = mutationVerification
                self.mutationReportMarkdown = mutationReportMarkdown
                self.liveDrillState = liveDrillState
                self.liveDrillVerification = liveDrillVerification
                self.liveDrillReportMarkdown = liveDrillReportMarkdown
                self.controlledInstallLastResult = controlledInstallLastResult
                self.controlledInstallPlan = controlledInstallPlan
                self.manualBootGuide = manualBootGuide
                self.mutationExecutionResult = mutationExecutionResult
            }
        }
    }

    func refreshSafetyStatusNow(repositoryPath: String) {
        let currentTarget = target
        let hasExecution = execution != nil

        let killSwitchExecution = LiveCommandRunner.shared.run(
            "scripts/cidre-app-installer-killswitch",
            arguments: ["--status", "--json"],
            repositoryPath: repositoryPath,
            isMockMode: false
        )
        let killSwitchState: InstallerKillSwitchState
        if let data = killSwitchExecution.stdout.data(using: .utf8),
           let decoded = try? JSONDecoder().decode(InstallerKillSwitchState.self, from: data) {
            killSwitchState = decoded
        } else {
            killSwitchState = .containmentDefault
        }

        let mutationTestMode = MutationTestModeService.shared.status(repositoryPath: repositoryPath)
        let diskScanResult = DiskScanService.shared.scan(repositoryPath: repositoryPath)
        let snapshotAvailability = DiskSnapshotService.shared.availability(repositoryPath: repositoryPath)
        let protectedPartitionState = ProtectedPartitionGuardService.shared.evaluate(repositoryPath: repositoryPath, snapshots: snapshotAvailability)
        let diskDiffState = DiskDiffService.shared.evaluate(repositoryPath: repositoryPath, snapshots: snapshotAvailability)
        let recoverySurvivalState = RecoverySurvivalService.shared.evaluate(repositoryPath: repositoryPath)
        let gateState = GateEvaluationService.shared.evaluate(scope: "install", repositoryPath: repositoryPath)
        let disposableTarget = DisposableTargetCheckService.shared.evaluate(target: currentTarget, repositoryPath: repositoryPath)
        let installTarget = InstallTargetCheckService.shared.check(repositoryPath: repositoryPath, currentTarget: currentTarget)
        let helperGateDecision = HelperGateService.shared.evaluate(operation: "partition-create", repositoryPath: repositoryPath)
        let mutationVerification = MutationVerificationService.shared.report(repositoryPath: repositoryPath)
        let mutationReportMarkdown = MutationReportService.shared.markdown(repositoryPath: repositoryPath)
        let liveDrillState = LiveDrillService.shared.state(repositoryPath: repositoryPath)
        let liveDrillVerification = LiveDrillVerificationService.shared.result(repositoryPath: repositoryPath)
        let liveDrillReportMarkdown = LiveDrillReportService.shared.markdown(repositoryPath: repositoryPath)
        let controlledInstallLastResult = ControlledInstallService.shared.lastResult(repositoryPath: repositoryPath)
        let controlledInstallPlan = InstallPlanService.shared.lastPlan(repositoryPath: repositoryPath)
        let manualBootGuide = ManualBootGuideService.shared.guide(repositoryPath: repositoryPath)
        let mutationExecutionResult = hasExecution ? MutationExecutionService.shared.report(repositoryPath: repositoryPath) : nil

        self.killSwitchState = killSwitchState
        self.mutationTestMode = mutationTestMode
        self.diskScanResult = diskScanResult
        self.snapshotAvailability = snapshotAvailability
        self.protectedPartitionState = protectedPartitionState
        self.diskDiffState = diskDiffState
        self.recoverySurvivalState = recoverySurvivalState
        self.gateState = gateState
        self.disposableTarget = disposableTarget
        self.installTarget = installTarget
        self.helperGateDecision = helperGateDecision
        self.mutationVerification = mutationVerification
        self.mutationReportMarkdown = mutationReportMarkdown
        self.liveDrillState = liveDrillState
        self.liveDrillVerification = liveDrillVerification
        self.liveDrillReportMarkdown = liveDrillReportMarkdown
        self.controlledInstallLastResult = controlledInstallLastResult
        self.controlledInstallPlan = controlledInstallPlan
        self.manualBootGuide = manualBootGuide
        self.mutationExecutionResult = mutationExecutionResult
    }

    func selectTarget(_ targetID: String, repositoryPath: String) {
        target = targetID
        purgeStaleTargetState(repositoryPath: repositoryPath)
        fetchLimits()
        refreshSafetyStatus(repositoryPath: repositoryPath)
    }

    func selectStartupTarget(repositoryPath: String) {
        guard let startupTargetIdentifier else { return }
        selectTarget(startupTargetIdentifier, repositoryPath: repositoryPath)
    }

    func resolveCreatePlanBlockers(repositoryPath: String) {
        isRunning = true
        let latestScan = DiskScanService.shared.scan(repositoryPath: repositoryPath)
        if let latestScan {
            diskScanResult = latestScan
        }
        if target.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            target = latestScan?.startupIdentifiers.first ?? target
        }
        if !target.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            purgeStaleTargetState(repositoryPath: repositoryPath)
            fetchLimits()
        }
        let isSafeVolume = installTarget?.classification == "cidre-volume"
        if !isSafeVolume && mutationTestMode?.enabled != true {
            guidedActionTitle = "Enable Test Mode"
            guidedActionExecution = LiveCommandRunner.shared.run(
                "scripts/cidre-app-mutation-test-mode",
                arguments: ["--enable", "--phrase", "I understand this can destroy the selected disposable target.", "--json"],
                repositoryPath: repositoryPath,
                isMockMode: false
            )
            mutationTestMode = MutationTestModeService.shared.status(repositoryPath: repositoryPath)
        }
        if !isSafeVolume && !killSwitchState.destructiveInstallAllowed {
            guidedActionTitle = "Enable Installer Override"
            guidedActionExecution = LiveCommandRunner.shared.run(
                "scripts/cidre-app-installer-killswitch",
                arguments: ["--enable-for-test", "--i-understand-dfu-risk", "--json"],
                repositoryPath: repositoryPath,
                isMockMode: false
            )
            if let data = guidedActionExecution?.stdout.data(using: .utf8),
               let decoded = try? JSONDecoder().decode(InstallerKillSwitchState.self, from: data) {
                killSwitchState = decoded
            }
        }
        if snapshotAvailability.beforeAvailable == false {
            guidedActionTitle = "Capture Pre Snapshot"
            guidedActionExecution = LiveCommandRunner.shared.run(
                "scripts/cidre-app-disk-snapshot",
                arguments: ["--label", "manual-before", "--json"],
                repositoryPath: repositoryPath,
                isMockMode: false
            )
            snapshotAvailability = DiskSnapshotService.shared.availability(repositoryPath: repositoryPath)
        }
        refreshSafetyStatusNow(repositoryPath: repositoryPath)
        isRunning = false
    }

    func fetchLimits() {
        guard !target.isEmpty else { return }
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let process = Process()
            let pipe = Pipe()
            process.executableURL = URL(fileURLWithPath: "/usr/sbin/diskutil")
            process.arguments = ["apfs", "resizeContainer", target, "limits", "-plist"]
            process.standardOutput = pipe
            process.standardError = Pipe()
            try? process.run()
            process.waitUntilExit()
            guard process.terminationStatus == 0,
                  let plist = try? PropertyListSerialization.propertyList(from: pipe.fileHandleForReading.readDataToEndOfFile(), options: [], format: nil) as? [String: Any],
                  let current = (plist["CurrentSize"] as? NSNumber)?.intValue,
                  let minPref = (plist["MinimumSizePreferred"] as? NSNumber)?.intValue else { return }
            let maxPartition = current - minPref
            let autoPartition = max(10_000_000_000, Int((Double(maxPartition) * 0.6 / 10_000_000_000).rounded()) * 10_000_000_000)
            let info: [String: Any] = [
                "current_bytes": current,
                "min_preferred_bytes": minPref,
                "max_partition_bytes": maxPartition,
                "auto_partition_bytes": min(autoPartition, maxPartition),
            ]
            DispatchQueue.main.async { self.limitsInfo = info }
        }
    }

    func createPlan(repositoryPath: String) {
        run(repositoryPath: repositoryPath, command: "scripts/cidre-app-disk-plan", arguments: planArguments)
        // Parse returned plan_id from JSON output
        guard let data = execution?.stdout.data(using: .utf8),
              let object = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
              execution?.status == "pass" else {
            planID = nil
            requiredConfirmation = nil
            return
        }
        planID = object["plan_id"] as? String
        planFile = object["plan_file"] as? String
        requiredConfirmation = object["required_confirmation"] as? String
        plannedInputSignature = inputSignature
        // Persist resolved sizes from non-custom modes so Validate Preview stays in sync
        if partitionMode != .custom {
            containerSize = object["container_size"] as? String ?? containerSize
            partitionSize = object["partition_size"] as? String ?? partitionSize
        }
        confirmation = ""
        if let data = execution?.stdout.data(using: .utf8) {
            mutationPlan = try? JSONDecoder().decode(MutationPlan.self, from: data)
        }
        if let planFile {
            planSignature = MutationPlanService.shared.sign(planFile: planFile, repositoryPath: repositoryPath)
        }
    }

    func preview(repositoryPath: String) {
        guard let planID else { return }
        run(repositoryPath: repositoryPath, command: "scripts/cidre-app-helper-command", arguments: helperArguments(planID: planID, dryRun: true))
    }

    func execute(repositoryPath: String) {
        guard let planID, let planFile else { return }
        mutationConfirmation = MutationPlanService.shared.confirm(
            planFile: planFile,
            phrase: confirmation.trimmingCharacters(in: .whitespacesAndNewlines),
            requiredPhrase: requiredConfirmation,
            repositoryPath: repositoryPath
        )
        guard mutationConfirmation?.status == "passed" else { return }
        run(repositoryPath: repositoryPath, command: "scripts/cidre-app-mutation-execute-test", arguments: executionArguments(planID: planID))
        refreshSafetyStatus(repositoryPath: repositoryPath)
    }

    private var planArguments: [String] {
        var args = ["--mode", "install", "--target", target,
                    "--partition-mode", partitionMode.rawValue,
                    "--volume-name", volumeName, "--json"]
        if partitionMode == .custom {
            args += ["--container-size", containerSize, "--partition-size", partitionSize]
        }
        return args
    }

    private var inputSignature: String {
        [target, partitionMode.rawValue, containerSize, partitionSize, volumeName].joined(separator: "\n")
    }

    private func helperArguments(planID: String, dryRun: Bool) -> [String] {
        guard let planFile else { return [] }
        var arguments = [
            "--operation", "partition-create",
            "--target", target,
            "--container-size", containerSize,
            "--partition-size", partitionSize,
            "--volume-name", volumeName,
            "--plan-id", planID,
            "--plan", planFile,
            "--signature", "\(planFile).sig.json",
            "--confirmation-file", "\(planFile).confirmation.json",
        ]
        if dryRun {
            arguments.append("--dry-run")
        } else {
            arguments.append(contentsOf: ["--confirm", mutationConfirmation?.confirmationToken ?? ""])
        }
        arguments.append("--json")
        return arguments
    }

    private func executionArguments(planID: String) -> [String] {
        guard let planFile else { return [] }
        return [
            "--plan", planFile,
            "--signature", "\(planFile).sig.json",
            "--confirmation", "\(planFile).confirmation.json",
            "--json",
        ]
    }

    private func run(repositoryPath: String, command: String, arguments: [String]) {
        isRunning = true
        execution = LiveCommandRunner.shared.run(command, arguments: arguments, repositoryPath: repositoryPath, isMockMode: false)
        isRunning = false
    }

    private func runGuidedAction(repositoryPath: String, title: String, command: String, arguments: [String], refreshKillSwitchState: Bool = false) {
        isRunning = true
        guidedActionTitle = title
        guidedActionExecution = LiveCommandRunner.shared.run(command, arguments: arguments, repositoryPath: repositoryPath, isMockMode: false)
        if refreshKillSwitchState {
            refreshKillSwitch(repositoryPath: repositoryPath)
        }
        refreshSafetyStatus(repositoryPath: repositoryPath)
        isRunning = false
    }
}
