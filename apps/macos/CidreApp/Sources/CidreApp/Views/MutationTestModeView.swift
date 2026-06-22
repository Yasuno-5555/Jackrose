import SwiftUI

struct MutationTestModeView: View {
    let state: MutationTestMode?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Controlled Mutation Test Mode")
                .font(.headline)
            Text(state?.summary ?? "Controlled mutation test mode status unavailable.")
                .foregroundColor(.secondary)
            if let state {
                Text("Mode: \(state.mode) • Env: \(state.environmentEnabled ? "set" : "unset")")
                    .font(.caption)
                    .foregroundColor(state.enabled ? .orange : .secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(10)
    }
}
