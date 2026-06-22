import SwiftUI

struct ControlledInstallDashboardView: View {
    let lastResult: [String: Any]?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Controlled Manual-Boot Install")
                .font(.headline)
            Text("Cidre can place its payload on the selected target. Cidre will not change your default startup disk.")
                .foregroundColor(.secondary)
            Text("No default boot mutation: enforced")
                .font(.caption)
            Text("Manual boot: required")
                .font(.caption)
            if let status = lastResult?["status"] as? String {
                Text("Last result: \(status)")
                    .font(.caption)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(10)
    }
}
