import SwiftUI

struct LiveDrillExecutionView: View {
    let result: LiveDrillResult?

    var body: some View {
        if let result, let checks = result.checks {
            VStack(alignment: .leading, spacing: 6) {
                Text("Live Drill Execution")
                    .font(.headline)
                ForEach(checks) { check in
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
