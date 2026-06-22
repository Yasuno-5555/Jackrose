import SwiftUI

struct LiveDrillVerificationView: View {
    let result: LiveDrillResult?

    var body: some View {
        if let result {
            VStack(alignment: .leading, spacing: 6) {
                Text("Live Drill Verification")
                    .font(.headline)
                Text(result.summary)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(10)
        }
    }
}
