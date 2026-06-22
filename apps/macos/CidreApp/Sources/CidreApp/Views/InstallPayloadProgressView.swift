import SwiftUI

struct InstallPayloadProgressView: View {
    let lastResult: [String: Any]?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Payload Staging Progress")
                .font(.headline)
            if let result = lastResult {
                let status = result["status"] as? String ?? "blocked"
                Text("Staging result: \(status)")
                if let files = result["stage_result"] as? [String: Any],
                   let staged = files["staged_files"] as? [String] {
                    ForEach(staged, id: \.self) { file in
                        Text("Staged: \(file)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                Text("Install staging has not run.")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(10)
    }
}
