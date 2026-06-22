import SwiftUI

struct LiveDrillPlanView: View {
    let plan: LiveDrillPlan?

    var body: some View {
        if let plan {
            VStack(alignment: .leading, spacing: 6) {
                Text("Live Drill Plan")
                    .font(.headline)
                Text("Level: \(plan.level)")
                Text("Operation: \(plan.operation)")
                Text("Plan hash: \(plan.planHash)")
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
