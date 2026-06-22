import SwiftUI

struct InstallTargetReviewView: View {
    let targetCheck: InstallTarget?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Selected Target Review")
                .font(.headline)
            if let check = targetCheck {
                Text("Target: \(check.target ?? "none")")
                Text("Classification: \(check.classification ?? "unknown")")
                Text("Result: \(check.status)")
                    .foregroundColor(check.status == "passed" ? .green : .red)
            } else {
                Text("No target check status available.")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(10)
    }
}
