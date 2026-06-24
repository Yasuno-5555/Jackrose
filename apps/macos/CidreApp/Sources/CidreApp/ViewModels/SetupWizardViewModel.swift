import SwiftUI

final class SetupWizardViewModel: ObservableObject {
    @Published var stages: [WizardStage] = WizardEngine.shared.stages(for: .install)
    @Published var currentIndex = 0
    @Published var state: WizardState = .initial(mode: .install)
    @Published var lastExecution: CommandExecution?
    @Published var isRunning = false
    @Published var gateDecision: WizardGateState?

    /// Owner credentials for bless/bputil operations. Held in memory only.
    @Published var ownerCredentials: OwnerCredentials?

    /// Boot policy state tracking
    @Published var bootPolicyVM = BootPolicyViewModel()

    /// Install target device (e.g. disk3s1), set during disk planning
    @Published var installTarget: String?

    /// Find the System volume mount point for the APFS container containing the given device.
    /// Uses diskutil to look up the System role volume in the same container.
    static func findSystemVolumeMount(for targetDevice: String?) -> String? {
        guard let target = targetDevice, !target.isEmpty else { return nil }
        // Try common mount points for Cidre System volume
        let candidates = ["/Volumes/Cidre 1", "/Volumes/Cidre"]
        for mount in candidates {
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: "\(mount)/System/Library/CoreServices", isDirectory: &isDir), isDir.boolValue {
                return mount
            }
        }
        return nil
    }

    func load(repositoryPath: String) {
        state = WizardStateStore.shared.load(repositoryPath: repositoryPath, mode: .install)
        if let found = stages.firstIndex(of: state.stage) {
            currentIndex = found
        }
        // Load install target from saved plan so it's available for boot-chain/boot-policy stages
        if installTarget == nil {
            loadInstallTarget(repositoryPath: repositoryPath)
        }
        // Restore boot-policy SSU state from disk (survives app restart after Recovery)
        if let bpState = BootPolicyStateStore.shared.load(repositoryPath: repositoryPath) {
            bootPolicyVM.ssuRequired = bpState.ssuRequired
            bootPolicyVM.ssuCompleted = bpState.ssuCompleted
            // If SSU was completed but we're still at bootPolicy, auto-advance
            if bpState.ssuCompleted, state.stage == .bootPolicy,
               let nextIdx = stages.firstIndex(of: .postRecoveryRestore) {
                currentIndex = nextIdx
                state.stage = stages[currentIndex]
                state.nextAction = stages.indices.contains(currentIndex + 1) ? stages[currentIndex + 1].title : nil
            }
        }
    }

    /// Load the install target device from the saved install plan.
    private func loadInstallTarget(repositoryPath: String) {
        let planPath = "\(repositoryPath)/.local/state/cidre/install/current/last-plan.json"
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: planPath)),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let target = json["target"] as? String, !target.isEmpty else {
            return
        }
        installTarget = target
    }

    func advance(repositoryPath: String) {
        guard currentIndex + 1 < stages.count else { return }
        let from = stages[currentIndex]
        let to = stages[currentIndex + 1]
        if let decision = WizardGateService.shared.evaluate(from: from, to: to, repositoryPath: repositoryPath),
           decision.status != "passed" {
            gateDecision = decision
            lastExecution = CommandExecution(
                id: UUID(),
                command: "scripts/cidre-app-wizard-gate",
                arguments: ["--from", from.rawValue, "--to", to.rawValue, "--json"],
                workingDirectory: repositoryPath,
                startedAt: Date(),
                finishedAt: Date(),
                exitCode: decision.exitCode,
                status: "blocked",
                stdout: decision.summary,
                stderr: "",
                parsedResult: nil,
                parseError: nil
            )
            return
        }
        currentIndex += 1
        state.stage = stages[currentIndex]
        state.nextAction = stages.indices.contains(currentIndex + 1) ? stages[currentIndex + 1].title : nil
        WizardStateStore.shared.save(state, repositoryPath: repositoryPath)
    }

    func goBack(repositoryPath: String) {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        state.stage = stages[currentIndex]
        WizardStateStore.shared.save(state, repositoryPath: repositoryPath)
    }

    /// Mark SSU as completed and advance to the post-recovery restore stage.
    func markSsuCompleted(repositoryPath: String) {
        bootPolicyVM.ssuCompleted = true
        // Persist SSU completion state for app restart survival
        BootPolicyStateStore.shared.save(
            BootPolicyPersistedState(
                ssuRequired: bootPolicyVM.ssuRequired,
                ssuCompleted: true
            ),
            repositoryPath: repositoryPath
        )
        // Advance to post-recovery restore stage
        guard currentIndex + 1 < stages.count else { return }
        currentIndex += 1
        state.stage = stages[currentIndex]
        state.nextAction = stages.indices.contains(currentIndex + 1) ? stages[currentIndex + 1].title : nil
        WizardStateStore.shared.save(state, repositoryPath: repositoryPath)
    }

    func operationForCurrentStage() -> WizardOperation? {
        WizardEngine.shared.operations(for: .install).first { $0.stage == stages[currentIndex] }
    }

    func runCurrent(repositoryPath: String, isMockMode: Bool, logStore: ExecutionLogStore) {
        guard var operation = operationForCurrentStage() else { return }

        // Require owner credentials for boot-policy-create (bless/bputil needs them)
        if operation.id == "boot-policy-create", ownerCredentials == nil {
            let blockedStdout = "{\"status\":\"blocked\",\"summary\":\"Owner credentials required. Please enter your macOS username and password in the Privileged Preparation step before creating the boot policy.\",\"reduced_security_status\":\"manual-recovery-required\"}"
            lastExecution = CommandExecution(
                id: UUID(),
                command: operation.command, arguments: [],
                workingDirectory: repositoryPath,
                startedAt: Date(), finishedAt: Date(),
                exitCode: 4, status: "blocked",
                stdout: blockedStdout, stderr: ""
            )
            bootPolicyVM.updateFromResult(
                (try? JSONSerialization.jsonObject(with: blockedStdout.data(using: .utf8) ?? Data())) as? [String: Any]
            )
            return
        }

        // Append owner credentials and target for boot-policy-create operation
        if operation.id == "boot-policy-create" {
            var cmd = operation.command
            if let installTarget = installTarget, !installTarget.isEmpty {
                cmd += " --target \(installTarget)"
            }
            if let creds = ownerCredentials {
                cmd += " --owner-user \(creds.username) --owner-password \(creds.password)"
            }
            cmd += " --json"
            operation = WizardOperation(
                id: operation.id, title: operation.title, category: operation.category,
                stage: operation.stage, privilegeLevel: operation.privilegeLevel,
                destructive: operation.destructive, requiresConfirmation: operation.requiresConfirmation,
                requiresHelper: operation.requiresHelper, dryRunAvailable: operation.dryRunAvailable,
                command: cmd, rollbackHint: operation.rollbackHint
            )
        }

        // Inject paths for boot-chain-stage
        if operation.id == "boot-chain-stage" {
            var cmd = operation.command
            // Find m1n1.macho
            let m1n1Candidates = [
                "\(repositoryPath)/libexec/m1n1.macho",
                "\(repositoryPath)/m1n1/build/m1n1.macho"
            ]
            if let m1n1Path = m1n1Candidates.first(where: { FileManager.default.isReadableFile(atPath: $0) }) {
                cmd += " --m1n1-path \(m1n1Path)"
            }
            // Discover System volume mount point from installTarget device
            let sysMount = Self.findSystemVolumeMount(for: installTarget)
            if let mount = sysMount, !mount.isEmpty {
                cmd += " --target-mount \(mount)"
            }
            cmd += " --json"
            operation = WizardOperation(
                id: operation.id, title: operation.title, category: operation.category,
                stage: operation.stage, privilegeLevel: operation.privilegeLevel,
                destructive: operation.destructive, requiresConfirmation: operation.requiresConfirmation,
                requiresHelper: operation.requiresHelper, dryRunAvailable: operation.dryRunAvailable,
                command: cmd, rollbackHint: operation.rollbackHint
            )
        }

        // boot-policy-verify: inject target for VG discovery
        if operation.id == "boot-policy-verify" {
            var cmd = operation.command
            if let installTarget = installTarget, !installTarget.isEmpty {
                cmd += " --target \(installTarget)"
            }
            cmd += " --json"
            operation = WizardOperation(
                id: operation.id, title: operation.title, category: operation.category,
                stage: operation.stage, privilegeLevel: operation.privilegeLevel,
                destructive: operation.destructive, requiresConfirmation: operation.requiresConfirmation,
                requiresHelper: operation.requiresHelper, dryRunAvailable: operation.dryRunAvailable,
                command: cmd, rollbackHint: operation.rollbackHint
            )
        }

        // m1n1-build builds from source - just ensure --json
        if operation.id == "m1n1-build" {
            var cmd = operation.command
            cmd += " --json"
            operation = WizardOperation(
                id: operation.id, title: operation.title, category: operation.category,
                stage: operation.stage, privilegeLevel: operation.privilegeLevel,
                destructive: operation.destructive, requiresConfirmation: operation.requiresConfirmation,
                requiresHelper: operation.requiresHelper, dryRunAvailable: operation.dryRunAvailable,
                command: cmd, rollbackHint: operation.rollbackHint
            )
        }

        isRunning = true
        state.status = "running"
        state.lastOperation = operation.id
        WizardStateStore.shared.save(state, repositoryPath: repositoryPath)
        let start = Date()
        let execution = WizardOperationRunner.shared.run(operation: operation, repositoryPath: repositoryPath, isMockMode: isMockMode)
        lastExecution = execution
        state.status = execution.status
        state.helperRequired = operation.requiresHelper
        WizardStateStore.shared.save(state, repositoryPath: repositoryPath)
        logStore.append(command: execution.command, arguments: execution.arguments, exitCode: execution.exitCode ?? 0, status: execution.status, summary: execution.parsedResult?.summary ?? execution.stdout, duration: Date().timeIntervalSince(start))

        // Update boot policy view model from result
        if operation.id == "boot-policy-create" || operation.id == "boot-chain-stage" || operation.id == "boot-policy-verify" {
            bootPolicyVM.updateFromResult(execution.parsedResult.map { _ in
                (try? JSONSerialization.jsonObject(with: execution.stdout.data(using: .utf8) ?? Data())) as? [String: Any]
            } ?? nil)
        }

        isRunning = false
    }
}
