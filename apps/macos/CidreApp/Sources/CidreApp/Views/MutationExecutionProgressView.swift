import SwiftUI

struct MutationExecutionProgressView: View {
    let result: MutationExecutionResult?

    var body: some View {
        if let result {
            VStack(alignment: .leading, spacing: 6) {
                Text("Mutation Execution Progress")
                    .font(.headline)
                ForEach(result.checks) { check in
                    Text("\(check.id): \(check.status)")
                        .font(.caption)
                        .foregroundColor(check.status == "passed" ? .green : .orange)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(10)
        }
    }
}
