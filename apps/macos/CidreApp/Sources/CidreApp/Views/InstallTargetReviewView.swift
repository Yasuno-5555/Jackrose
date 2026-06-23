import SwiftUI

struct InstallTargetReviewView: View {
    let targetCheck: InstallTarget?
    let disposableTarget: DisposableTarget?
    let currentTarget: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Selected Target Review")
                .font(.headline)
            if let check = targetCheck {
                Text("Target: \(check.target ?? "none")")
                Text("Classification: \(check.classification ?? "unknown")")
                Text("Result: \(check.status)")
                    .foregroundColor(check.status == "passed" ? .green : .red)
                Text(check.summary)
                    .font(.callout)
                    .foregroundColor(.secondary)
            } else if let disposableTarget, disposableTarget.target == currentTarget {
                Text("Target: \(disposableTarget.target)")
                Text("Classification: \(disposableTarget.classification)")
                Text("Result: \(disposableTarget.status)")
                    .foregroundColor(disposableTarget.status == "passed" ? .green : .red)
                Text(disposableTarget.summary)
                    .font(.callout)
                    .foregroundColor(.secondary)
            } else {
                Text(currentTarget.isEmpty ? "No target selected yet." : "No review has been recorded for the currently selected target yet.")
                    .foregroundColor(.secondary)
                if !currentTarget.isEmpty {
                    Text("Current target: \(currentTarget)")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                Text("A previous failed review for a different disk will not be reused here.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(10)
    }
}
