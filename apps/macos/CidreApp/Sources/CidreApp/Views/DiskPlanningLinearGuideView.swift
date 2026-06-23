import SwiftUI

struct DiskPlanningLinearGuideView: View {
    let step: DiskPlanningGuideStep
    let currentTarget: String
    let candidateTargets: [DiskTarget]
    let disposableSummary: String?
    let scanSummary: String?
    let requiredConfirmation: String?
    @Binding var confirmation: String
    let isRunning: Bool
    let onRefreshTargets: () -> Void
    let onSelectTarget: (String) -> Void
    let onEnableMutationTestMode: () -> Void
    let onEnableInstallerOverride: () -> Void
    let onCapturePreSnapshot: () -> Void
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
                Text("Next step: select one disposable target.")
                    .foregroundColor(.secondary)
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

            case .resolveProtectedPartitionSafety:
                Text("Next step: protected partition guard must pass before continuing.")
                    .foregroundColor(.secondary)

            case .createPlan:
                Text("Next step: create the mutation plan for the selected target.")
                    .foregroundColor(.secondary)
                primaryButton("Create Plan", action: onCreatePlan)

            case .validatePreview:
                Text("Next step: validate the dry-run preview for the current plan.")
                    .foregroundColor(.secondary)
                primaryButton("Validate Preview", action: onValidatePreview)

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
                    .disabled(isRunning || requiredConfirmation?.trimmingCharacters(in: .whitespacesAndNewlines) != confirmation.trimmingCharacters(in: .whitespacesAndNewlines))

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
