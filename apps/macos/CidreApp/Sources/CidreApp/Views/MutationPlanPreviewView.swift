import SwiftUI

struct MutationPlanPreviewView: View {
    let plan: MutationPlan?
    let signature: MutationPlanSignature?

    var body: some View {
        if let plan {
            VStack(alignment: .leading, spacing: 6) {
                Text("Mutation Plan Preview")
                    .font(.headline)
                Text("Operation: \(plan.operation)")
                Text("Target: \(plan.target)")
                Text("Plan hash: \(signature?.planHash ?? plan.planHash)")
                    .font(.caption)
                    .textSelection(.enabled)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(10)
        }
    }
}
