import SwiftUI

struct LiveDrillReportView: View {
    let markdown: String

    var body: some View {
        if !markdown.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text("Live Drill Report")
                    .font(.headline)
                Text(markdown)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(10)
        }
    }
}
