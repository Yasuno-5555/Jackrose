import SwiftUI

struct NoCandidateTargetsView: View {
    let isRunning: Bool
    let scanSummary: String?
    let onRefresh: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Install Target Setup")
                .font(.headline)
            Text("No installable startup target is currently visible. Refresh the disk scan and this wizard will offer the current startup physical store when it can classify it safely.")
                .foregroundColor(.secondary)

            Text("What to do now")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("1. Make sure the current macOS startup disk is mounted and readable.")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("2. Wait for the automatic rescan, or press Refresh Now.")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("3. When the startup physical store is classified, the guide will switch to target selection.")
                .font(.caption)
                .foregroundColor(.secondary)

            if let scanSummary {
                Text(scanSummary)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Button("Refresh Now") {
                onRefresh()
            }
            .disabled(isRunning)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(10)
    }
}
