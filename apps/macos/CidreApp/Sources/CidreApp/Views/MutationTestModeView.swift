import SwiftUI

struct MutationTestModeView: View {
    let state: MutationTestMode?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Controlled Mutation Test Mode")
                .font(.headline)
            Text(state?.summary ?? "Controlled mutation test mode status unavailable.")
                .foregroundColor(summaryColor)
            if let state {
                Text("Mode: \(state.mode) • Env: \(state.environmentEnabled ? "set" : "unset")")
                    .font(.caption)
                    .foregroundColor(state.environmentEnabled ? .green : (state.enabled ? .orange : .secondary))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(10)
    }

    private var summaryColor: Color {
        guard let state else { return .secondary }
        if state.environmentEnabled {
            return .green
        }
        if state.enabled {
            return .orange
        }
        return .secondary
    }
}
