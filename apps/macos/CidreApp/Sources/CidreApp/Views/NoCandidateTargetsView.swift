import SwiftUI

struct NoCandidateTargetsView: View {
    let isRunning: Bool
    let scanSummary: String?
    let onRefresh: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Disposable Target Setup")
                .font(.headline)
            Text("No safe disposable target is currently available. Connect or prepare a non-startup target, then this wizard will rescan automatically.")
                .foregroundColor(.secondary)

            Text("What to do now")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("1. Attach an external disk or prepare a non-startup APFS target.")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("2. Wait for the automatic rescan, or press Refresh Now.")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("3. When a candidate appears, the guide will switch to target selection.")
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
