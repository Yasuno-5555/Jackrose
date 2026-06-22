import SwiftUI

struct NoDefaultBootPolicyView: View {
    let lastResult: [String: Any]?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("No Default Boot Policy Check")
                .font(.headline)
            if let result = lastResult,
               let bootCheck = result["boot_check"] as? [String: Any] {
                let status = bootCheck["status"] as? String ?? "unknown"
                Text("Policy Verification: \(status)")
                    .foregroundColor(status == "passed" ? .green : .red)
                if let summary = bootCheck["summary"] as? String {
                    Text(summary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Boot policy check has not run.")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(10)
    }
}
