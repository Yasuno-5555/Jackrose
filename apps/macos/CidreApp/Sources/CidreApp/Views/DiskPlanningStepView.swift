import SwiftUI

struct DiskPlanningStepView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @StateObject private var mutation = DiskMutationViewModel()
    private let autoRefreshTimer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var body: some View {
        WizardStepContainerView(
            title: "Disk Plan",
            bodyText: "Disk-changing install is currently under DFU incident containment. The UI keeps planning visible, but blocks real partition changes until the boot safety gate pack is explicitly enabled for test."
        ) {
            VStack(alignment: .leading, spacing: 16) {

                Label("This installer is in incident containment mode. Disk-changing install is disabled by default after DFU_RESTORE_001.", systemImage: "exclamationmark.octagon.fill")
                    .foregroundColor(.red)
                    .font(.callout)

                Text(mutation.killSwitchState.reason)
                    .font(.callout)
                    .foregroundColor(.secondary)

                DiskPlanningGuidedActionsView(
                    mutationTestModeEnabled: mutation.mutationTestMode?.enabled == true,
                    installerOverrideEnabled: mutation.killSwitchState.destructiveInstallAllowed,
                    beforeSnapshotAvailable: mutation.snapshotAvailability.beforeAvailable,
                    afterSnapshotAvailable: mutation.snapshotAvailability.afterAvailable,
                    bootSafetyStatus: mutation.bootSafetyDisplayStatus,
                    isRunning: mutation.isRunning,
                    lastActionTitle: mutation.guidedActionTitle,
                    lastExecution: mutation.guidedActionExecution,
                    enableMutationTestMode: {
                        mutation.enableMutationTestMode(repositoryPath: appVM.repositoryPath)
                    },
                    enableInstallerTestOverride: {
                        mutation.enableInstallerTestOverride(repositoryPath: appVM.repositoryPath)
                    },
                    captureBeforeSnapshot: {
                        mutation.captureSnapshot(label: "manual-before", repositoryPath: appVM.repositoryPath)
                    },
                    captureAfterSnapshot: {
                        mutation.captureSnapshot(label: "manual-after", repositoryPath: appVM.repositoryPath)
                    },
                    generateRollbackReport: {
                        mutation.generateRollbackReport(repositoryPath: appVM.repositoryPath)
                    },
                    refreshBootSafety: {
                        mutation.refreshBootSafety(repositoryPath: appVM.repositoryPath)
                    }
                )

                Label("Keep a current backup and connect power before continuing.", systemImage: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.callout)

                MutationTestModeView(state: mutation.mutationTestMode)
                LiveDrillDashboardView(state: mutation.liveDrillState, mutationMode: mutation.mutationTestMode, killSwitch: mutation.killSwitchState)
                DiskPlanningLinearGuideView(
                    step: mutation.guideStep,
                    currentTarget: mutation.target,
                    candidateTargets: mutation.candidateTargets,
                    startupTargetIdentifier: mutation.startupTargetIdentifier,
                    disposableSummary: mutation.installTarget?.summary ?? mutation.disposableTarget?.summary,
                    scanSummary: mutation.diskScanResult?.summary,
                    requiredConfirmation: mutation.requiredConfirmation,
                    mutationTestModeEnabled: mutation.mutationTestMode?.enabled == true,
                    installerOverrideEnabled: mutation.killSwitchState.destructiveInstallAllowed,
                    beforeSnapshotAvailable: mutation.snapshotAvailability.beforeAvailable,
                    recoveryPassed: mutation.recoverySurvivalState?.status == "passed",
                    protectedPartitionPassed: mutation.protectedPartitionState?.status == "passed",
                    installTargetPassed: mutation.installTarget?.status == "passed",
                    createPlanEnabled: mutation.canCreatePlan,
                    createPlanBlockers: mutation.createPlanBlockers,
                    validatePreviewEnabled: mutation.canPreview,
                    validatePreviewBlockers: mutation.validatePreviewBlockers,
                    executeEnabled: mutation.canExecute,
                    executeBlockers: mutation.executeBlockers,
                    confirmation: $mutation.confirmation,
                    isRunning: mutation.isRunning,
                    onRefreshTargets: {
                        mutation.refreshSafetyStatus(repositoryPath: appVM.repositoryPath)
                    },
                    onSelectTarget: { selected in
                        mutation.selectTarget(selected, repositoryPath: appVM.repositoryPath)
                    },
                    onSelectStartupTarget: {
                        mutation.selectStartupTarget(repositoryPath: appVM.repositoryPath)
                    },
                    onEnableMutationTestMode: {
                        mutation.enableMutationTestMode(repositoryPath: appVM.repositoryPath)
                    },
                    onEnableInstallerOverride: {
                        mutation.enableInstallerTestOverride(repositoryPath: appVM.repositoryPath)
                    },
                    onCapturePreSnapshot: {
                        mutation.captureSnapshot(label: "manual-before", repositoryPath: appVM.repositoryPath)
                    },
                    onResolveCreatePlanBlockers: {
                        mutation.resolveCreatePlanBlockers(repositoryPath: appVM.repositoryPath)
                    },
                    onCreatePlan: {
                        mutation.createPlan(repositoryPath: appVM.repositoryPath)
                    },
                    onValidatePreview: {
                        mutation.preview(repositoryPath: appVM.repositoryPath)
                    },
                    onExecute: {
                        mutation.execute(repositoryPath: appVM.repositoryPath)
                    }
                )

                // Controlled manual-boot install (v0.35.6)
                ControlledInstallDashboardView(lastResult: mutation.controlledInstallLastResult)
                InstallTargetReviewView(
                    targetCheck: mutation.installTarget,
                    disposableTarget: mutation.disposableTarget,
                    currentTarget: mutation.target
                )
                InstallPlanPreviewView(plan: mutation.controlledInstallPlan)
                InstallPayloadProgressView(lastResult: mutation.controlledInstallLastResult)
                InstallVerificationView(lastResult: mutation.controlledInstallLastResult)
                ManualBootGuideView(guide: mutation.manualBootGuide)
                NoDefaultBootPolicyView(lastResult: mutation.controlledInstallLastResult)

                ProtectedPartitionGuardView(state: mutation.protectedPartitionState)
                RecoverySurvivalView(state: mutation.recoverySurvivalState)
                DiskSnapshotView(availability: mutation.snapshotAvailability)
                DiskDiffSummaryView(state: mutation.diskDiffState)
                BootSafetyGateEnforcementView(gateState: mutation.gateState)
                if mutation.gateState?.status != "passed" {
                    RollbackReportRequiredView()
                }

                Divider()

                // ── Target ───────────────────────────────────────────────
                VStack(alignment: .leading, spacing: 4) {
                    Text("macOS Physical Store")
                        .font(.headline)
                    HStack {
                        TextField("e.g. disk0s2", text: $mutation.target)
                            .frame(maxWidth: 160)
                            .onChange(of: mutation.target) { _ in
                                mutation.purgeStaleTargetState(repositoryPath: appVM.repositoryPath)
                                mutation.fetchLimits()
                                mutation.refreshSafetyStatus(repositoryPath: appVM.repositoryPath)
                            }
                        if let limits = mutation.limitsInfo,
                           let currentBytes = limits["current_bytes"] as? Int {
                            Text("Current: \(formatGB(currentBytes))")
                                .foregroundColor(.secondary)
                                .font(.callout)
                        }
                    }
                }

                DisclosureGroup("Advanced Target Picker") {
                    DiskTargetPickerView(
                        selectedTarget: mutation.target,
                        candidateTargets: mutation.candidateTargets,
                        protectedTargets: mutation.protectedTargets,
                        onSelect: { selected in
                            mutation.selectTarget(selected, repositoryPath: appVM.repositoryPath)
                        }
                    )
                }

                DisposableTargetReviewView(state: mutation.disposableTarget)

                Divider()

                // ── Partition Mode ────────────────────────────────────────
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cidre Partition Size")
                        .font(.headline)

                    HStack(spacing: 8) {
                        ForEach(PartitionMode.allCases, id: \.self) { mode in
                            Button(action: { mutation.partitionMode = mode }) {
                                VStack(spacing: 2) {
                                    Text(mode.label)
                                        .font(.system(.body, design: .rounded).weight(.semibold))
                                    if let badge = modeBadge(mode) {
                                        Text(badge)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(mutation.partitionMode == mode ? Color.accentColor.opacity(0.15) : Color.clear)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(mutation.partitionMode == mode ? Color.accentColor : Color.secondary.opacity(0.4), lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Text(mutation.partitionMode.description)
                        .font(.callout)
                        .foregroundColor(.secondary)
                }

                // ── Custom size inputs ────────────────────────────────────
                if mutation.partitionMode == .custom {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("macOS container size after resize")
                                    .font(.caption).foregroundColor(.secondary)
                                TextField("e.g. 350G", text: $mutation.containerSize)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("New Cidre partition size")
                                    .font(.caption).foregroundColor(.secondary)
                                TextField("e.g. 80G or max", text: $mutation.partitionSize)
                            }
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Volume name")
                                .font(.caption).foregroundColor(.secondary)
                            TextField("Cidre", text: $mutation.volumeName)
                                .frame(maxWidth: 200)
                        }
                    }
                }

                // ── Actions ───────────────────────────────────────────────
                VStack(alignment: .leading, spacing: 8) {
                    Text("Plan Actions")
                        .font(.headline)
                    Text("These buttons stay visible here so you can continue the install without opening an Advanced section.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 8) {
                        Button("Create Plan") {
                            mutation.createPlan(repositoryPath: appVM.repositoryPath)
                        }
                        .disabled(!mutation.canCreatePlan)

                        Button("Validate Preview") {
                            mutation.preview(repositoryPath: appVM.repositoryPath)
                        }
                        .disabled(!mutation.canPreview || mutation.isRunning)
                    }

                    if !mutation.canCreatePlan {
                        Button("Resolve Create Plan Blockers") {
                            mutation.resolveCreatePlanBlockers(repositoryPath: appVM.repositoryPath)
                        }
                        .disabled(mutation.isRunning)
                        blockerSection(title: "Create Plan is blocked because:", blockers: mutation.createPlanBlockers)
                    }

                    if !mutation.canPreview {
                        blockerSection(title: "Validate Preview is blocked because:", blockers: mutation.validatePreviewBlockers)
                    }
                }

                MutationPlanPreviewView(plan: mutation.mutationPlan, signature: mutation.planSignature)

                if mutation.gateState?.status != "passed" {
                    Text("Disk changes: Disabled")
                        .font(.headline)
                    Text("Reason: Installer killswitch is active or Boot Safety Gate has not passed.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // ── Confirmation & Execute ────────────────────────────────
                if mutation.requiredConfirmation != nil {
                    Divider()
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Install Execution")
                            .font(.headline)
                        Text("Enter the confirmation phrase here and run the authenticated disk change when the preview looks correct.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        MutationConfirmationView(requiredPhrase: mutation.requiredConfirmation ?? "", text: $mutation.confirmation)
                        Button("Authenticate and Modify Disk", role: .destructive) {
                            mutation.execute(repositoryPath: appVM.repositoryPath)
                        }
                        .disabled(!mutation.canExecute || mutation.isRunning)
                        if !mutation.canExecute {
                            blockerSection(title: "Execution is blocked because:", blockers: mutation.executeBlockers)
                        }
                    }
                }

                MutationExecutionProgressView(result: mutation.mutationExecutionResult)
                MutationVerificationView(result: mutation.mutationVerification)
                MutationReportView(markdown: mutation.mutationReportMarkdown)
                LiveDrillVerificationView(result: mutation.liveDrillVerification)
                LiveDrillReportView(markdown: mutation.liveDrillReportMarkdown)
                WizardResultView(execution: mutation.execution)
            }
        }
        .onAppear {
            mutation.refreshKillSwitch(repositoryPath: appVM.repositoryPath)
            mutation.refreshSafetyStatus(repositoryPath: appVM.repositoryPath)
            mutation.detectStartupStore(repositoryPath: appVM.repositoryPath)
        }
        .onReceive(autoRefreshTimer) { _ in
            if mutation.guideStep == .noCandidateTargets && !mutation.isRunning {
                mutation.refreshSafetyStatus(repositoryPath: appVM.repositoryPath)
            }
        }
    }

    private func modeBadge(_ mode: PartitionMode) -> String? {
        guard let limits = mutation.limitsInfo else { return nil }
        switch mode {
        case .max:
            if let bytes = limits["max_partition_bytes"] as? Int { return formatGB(bytes) }
        case .auto:
            if let bytes = limits["auto_partition_bytes"] as? Int { return formatGB(bytes) }
        case .min:
            return "20.0 GB"
        case .custom:
            return nil
        }
        return nil
    }

    private func formatGB(_ bytes: Int) -> String {
        String(format: "%.1f GB", Double(bytes) / 1_000_000_000)
    }

    @ViewBuilder
    private func blockerSection(title: String, blockers: [String]) -> some View {
        if !blockers.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                ForEach(blockers, id: \.self) { blocker in
                    Text("• \(blocker)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
