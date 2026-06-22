import SwiftUI

struct InstallPlanPreviewView: View {
    let plan: ControlledInstallPlan?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Install Plan Preview")
                .font(.headline)
            if let p = plan {
                Text("Manual boot only: \(p.manualBootOnly ? "Yes" : "No")")
                Text("Default startup disk change: \(p.defaultBootMutation ? "Yes" : "No")")
                Text("Boot policy change: \(p.bootPolicyMutation ? "Yes" : "No")")
                Text("Automatic restart: \(p.automaticRestart ? "Yes" : "No")")
                Text("Plan Hash: \(p.planHash)")
                    .font(.system(.caption, design: .monospaced))
            } else {
                Text("No plan generated yet.")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(10)
    }
}
