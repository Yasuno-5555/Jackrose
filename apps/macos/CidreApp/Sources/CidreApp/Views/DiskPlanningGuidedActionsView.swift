import SwiftUI

struct DiskPlanningGuidedActionsView: View {
    let mutationTestModeEnabled: Bool
    let installerOverrideEnabled: Bool
    let beforeSnapshotAvailable: Bool
    let afterSnapshotAvailable: Bool
    let bootSafetyStatus: String?
    let isRunning: Bool
    let lastActionTitle: String?
    let lastExecution: CommandExecution?
    let enableMutationTestMode: () -> Void
    let enableInstallerTestOverride: () -> Void
    let captureBeforeSnapshot: () -> Void
    let captureAfterSnapshot: () -> Void
    let generateRollbackReport: () -> Void
    let refreshBootSafety: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Boot Safety Actions", systemImage: "checklist")
                .font(.headline)
            Text("Use these buttons here first. They satisfy the required safety steps without leaving the wizard.")
                .font(.caption)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Test Mode: \(mutationTestModeEnabled ? "Enabled" : "Blocked")")
                    .font(.caption)
                    .foregroundColor(mutationTestModeEnabled ? .green : .orange)
                Text("Installer Override: \(installerOverrideEnabled ? "Enabled" : "Blocked")")
                    .font(.caption)
                    .foregroundColor(installerOverrideEnabled ? .green : .orange)
                Text("Boot Safety: \((bootSafetyStatus ?? "unknown").capitalized)")
                    .font(.caption)
                    .foregroundColor((bootSafetyStatus ?? "") == "passed" ? .green : .orange)
            }

            HStack(spacing: 8) {
                Button(mutationTestModeEnabled ? "Test Mode Enabled" : "Enable Test Mode") {
                    enableMutationTestMode()
                }
                .disabled(isRunning)

                Button(installerOverrideEnabled ? "Installer Override Enabled" : "Enable Installer Override") {
                    enableInstallerTestOverride()
                }
                .disabled(isRunning)
            }

            HStack(spacing: 8) {
                Button(beforeSnapshotAvailable ? "Pre Snapshot Captured" : "Capture Pre Snapshot") {
                    captureBeforeSnapshot()
                }
                .disabled(isRunning || beforeSnapshotAvailable)

                Button(afterSnapshotAvailable ? "Post Snapshot Captured" : "Capture Post Snapshot") {
                    captureAfterSnapshot()
                }
                .disabled(isRunning || afterSnapshotAvailable)
            }

            HStack(spacing: 8) {
                Button("Generate Rollback Report") {
                    generateRollbackReport()
                }
                .disabled(isRunning)

                Button("Recheck Boot Safety") {
                    refreshBootSafety()
                }
                .disabled(isRunning)
            }

            if let lastExecution {
                Text("Latest guided action: \((lastActionTitle ?? "Action")) • \(lastExecution.status.uppercased())")
                    .font(.caption)
                    .fontWeight(.semibold)
                if let parsedResult = lastExecution.parsedResult {
                    Text(parsedResult.summary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if !lastExecution.stdout.isEmpty {
                    Text(lastExecution.stdout)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if !lastExecution.stderr.isEmpty {
                    Text(lastExecution.stderr)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.accentColor.opacity(0.35), lineWidth: 1)
        )
    }
}
