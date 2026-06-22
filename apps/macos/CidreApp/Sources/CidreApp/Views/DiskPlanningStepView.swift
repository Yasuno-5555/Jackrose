import SwiftUI

struct DiskPlanningStepView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @StateObject private var mutation = DiskMutationViewModel()

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

                Label("Keep a current backup and connect power before continuing.", systemImage: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.callout)

                MutationTestModeView(state: mutation.mutationTestMode)
                LiveDrillDashboardView(state: mutation.liveDrillState, mutationMode: mutation.mutationTestMode, killSwitch: mutation.killSwitchState)
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
                                TextField("e.g. 80G", text: $mutation.partitionSize)
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
                    MutationConfirmationView(requiredPhrase: "I understand this can destroy the selected disposable target.", text: $mutation.confirmation)
                    Button("Authenticate and Modify Disk", role: .destructive) {
                        mutation.execute(repositoryPath: appVM.repositoryPath)
                    }
                    .disabled(!mutation.canExecute || mutation.isRunning)
                }

                MutationExecutionProgressView(result: mutation.execution == nil ? nil : MutationExecutionService.shared.report(repositoryPath: appVM.repositoryPath))
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
            mutation.detectStartupStore()
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
}
