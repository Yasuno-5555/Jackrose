import SwiftUI

struct MutationVerificationView: View {
    let result: MutationVerificationResult?

    var body: some View {
        if let result {
            VStack(alignment: .leading, spacing: 6) {
                Text("Mutation Verification")
                    .font(.headline)
                Text(result.summary)
                    .foregroundColor(.secondary)
                ForEach(result.checks) { check in
                    Text("\(check.id): \(check.status)")
                        .font(.caption)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(10)
        }
    }
}
