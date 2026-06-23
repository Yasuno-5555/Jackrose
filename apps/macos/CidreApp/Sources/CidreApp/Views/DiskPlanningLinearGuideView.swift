import SwiftUI

struct DiskPlanningLinearGuideView: View {
    let step: DiskPlanningGuideStep
    let currentTarget: String
    let candidateTargets: [DiskTarget]
    let startupTargetIdentifier: String?
    let disposableSummary: String?
    let scanSummary: String?
    let requiredConfirmation: String?
    let mutationTestModeEnabled: Bool
    let installerOverrideEnabled: Bool
    let beforeSnapshotAvailable: Bool
    let recoveryPassed: Bool
    let protectedPartitionPassed: Bool
    let installTargetPassed: Bool
    let createPlanEnabled: Bool
    let createPlanBlockers: [String]
    let validatePreviewEnabled: Bool
    let validatePreviewBlockers: [String]
    let executeEnabled: Bool
    let executeBlockers: [String]
    @Binding var confirmation: String
    let isRunning: Bool
    let onRefreshTargets: () -> Void
    let onSelectTarget: (String) -> Void
    let onSelectStartupTarget: () -> Void
    let onEnableMutationTestMode: () -> Void
    let onEnableInstallerOverride: () -> Void
    let onCapturePreSnapshot: () -> Void
    let onResolveCreatePlanBlockers: () -> Void
    let onCreatePlan: () -> Void
    let onValidatePreview: () -> Void
    let onExecute: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("一本道 Guide")
                .font(.headline)

            switch step {
            case .noCandidateTargets:
                NoCandidateTargetsView(
                    isRunning: isRunning,
                    scanSummary: scanSummary,
                    onRefresh: onRefreshTargets
                )

            case .selectTarget:
                Text("Next step: select the current startup physical store for the controlled install.")
                    .foregroundColor(.secondary)
                if let startupTargetIdentifier {
                    primaryButton("Use Current Startup Disk (\(startupTargetIdentifier))", action: onSelectStartupTarget)
                }
                if let disposableSummary {
                    Text(disposableSummary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                ForEach(candidateTargets) { target in
                    Button(action: { onSelectTarget(target.id) }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(target.id)
                                    .font(.system(.body, design: .monospaced))
                                Text(targetSummary(target))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if currentTarget == target.id {
                                Text("Selected")
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding(8)
                        .background(currentTarget == target.id ? Color.accentColor.opacity(0.12) : Color(.windowBackgroundColor))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .disabled(isRunning)
                }

            case .enableMutationTestMode:
                Text("Next step: enable Controlled Mutation Test Mode.")
                    .foregroundColor(.secondary)
                primaryButton("Enable Test Mode", action: onEnableMutationTestMode)

            case .enableInstallerOverride:
                Text("Next step: enable the installer test override after acknowledging DFU risk.")
                    .foregroundColor(.secondary)
                primaryButton("Enable Installer Override", action: onEnableInstallerOverride)

            case .capturePreSnapshot:
                Text("Next step: capture a fresh pre-install disk snapshot.")
                    .foregroundColor(.secondary)
                primaryButton("Capture Pre Snapshot", action: onCapturePreSnapshot)

            case .resolveRecoverySafety:
                Text("Next step: recovery survival checks must pass before continuing.")
                    .foregroundColor(.secondary)
                primaryButton("Recheck Recovery Safety", action: onRefreshTargets)
                commonBlockerActions

            case .resolveProtectedPartitionSafety:
                Text("Next step: protected partition guard must pass before continuing.")
                    .foregroundColor(.secondary)
                primaryButton("Recheck Protected Partitions", action: onRefreshTargets)
                commonBlockerActions

            case .createPlan:
                Text("Next step: create the mutation plan for the selected target.")
                    .foregroundColor(.secondary)
                primaryButton("Resolve Create Plan Blockers", action: onResolveCreatePlanBlockers)
                primaryButton("Create Plan", action: onCreatePlan)
                    .disabled(!createPlanEnabled || isRunning)
                blockerList(createPlanBlockers)
                commonBlockerActions

            case .validatePreview:
                Text("Next step: validate the dry-run preview for the current plan.")
                    .foregroundColor(.secondary)
                primaryButton("Validate Preview", action: onValidatePreview)
                    .disabled(!validatePreviewEnabled || isRunning)
                blockerList(validatePreviewBlockers)

            case .confirmAndExecute:
                Text("Next step: enter the confirmation phrase and run the authenticated execution.")
                    .foregroundColor(.secondary)
                if let requiredConfirmation {
                    Text(requiredConfirmation)
                        .font(.caption)
                        .textSelection(.enabled)
                }
                TextField("Confirmation phrase", text: $confirmation)
                primaryButton("Authenticate and Modify Disk", action: onExecute)
                    .disabled(!executeEnabled || isRunning)
                blockerList(executeBlockers)

            case .reviewExecution:
                Text("Next step: review the latest execution result and continue with post-run verification.")
                    .foregroundColor(.secondary)
            }
        }
        .padding(step == .noCandidateTargets ? 0 : 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(step == .noCandidateTargets ? Color.clear : Color(.controlBackgroundColor))
        .cornerRadius(10)
    }

    private func primaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .disabled(isRunning)
    }

    @ViewBuilder
    private func blockerList(_ blockers: [String]) -> some View {
        if !blockers.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text("Blocked by:")
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

    @ViewBuilder
    private var commonBlockerActions: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !mutationTestModeEnabled {
                primaryButton("Enable Test Mode", action: onEnableMutationTestMode)
            }
            if !installerOverrideEnabled {
                primaryButton("Enable Installer Override", action: onEnableInstallerOverride)
            }
            if !installTargetPassed, let startupTargetIdentifier {
                primaryButton("Use Current Startup Disk (\(startupTargetIdentifier))", action: onSelectStartupTarget)
            }
            if !beforeSnapshotAvailable {
                primaryButton("Capture Pre Snapshot", action: onCapturePreSnapshot)
            }
            if !recoveryPassed || !protectedPartitionPassed || !installTargetPassed {
                primaryButton("Refresh Safety Checks", action: onRefreshTargets)
            }
        }
    }

    private func targetSummary(_ target: DiskTarget) -> String {
        var parts: [String] = [target.name]
        if let mountPoint = target.mountPoint, !mountPoint.isEmpty {
            parts.append(mountPoint)
        }
        if let sizeBytes = target.sizeBytes {
            parts.append(String(format: "%.1f GB", Double(sizeBytes) / 1_000_000_000))
        }
        return parts.joined(separator: " • ")
    }
}
