import SwiftUI

struct BootSafetyGateEnforcementView: View {
    let gateState: GateState?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Boot Safety Gate")
                .font(.headline)
            Text("Status: \(gateState?.status ?? "unknown")")
                .foregroundColor(color)
            Text(gateState?.summary ?? "Gate state unavailable.")
                .font(.caption)
                .foregroundColor(.secondary)
            GateFailureReasonView(gateState: gateState)
            BootSafetyNextStepsView(gateState: gateState)
        }
    }

    private var color: Color {
        switch gateState?.status {
        case "passed": return .green
        case "failed": return .red
        case "blocked": return .orange
        default: return .secondary
        }
    }
}
