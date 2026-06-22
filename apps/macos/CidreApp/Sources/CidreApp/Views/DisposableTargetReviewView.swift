import SwiftUI

struct DisposableTargetReviewView: View {
    let state: DisposableTarget?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Disposable Target Review")
                .font(.headline)
            Text(state?.summary ?? "Select a target to evaluate whether it is disposable.")
                .foregroundColor(.secondary)
            if let state {
                Text("Target: \(state.target) • Classification: \(state.classification)")
                    .font(.caption)
                    .foregroundColor(state.status == "passed" ? .green : .orange)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(10)
    }
}
