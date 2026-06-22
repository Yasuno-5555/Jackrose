import SwiftUI

struct InstallVerificationView: View {
    let lastResult: [String: Any]?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Install Verification")
                .font(.headline)
            if let result = lastResult,
               let verify = result["verify_result"] as? [String: Any] {
                let status = verify["status"] as? String ?? "unknown"
                Text("Verification status: \(status)")
                    .foregroundColor(status == "passed" ? .green : .red)
                if let summary = verify["summary"] as? String {
                    Text(summary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("No verification results recorded.")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(10)
    }
}
