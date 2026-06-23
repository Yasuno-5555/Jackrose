import SwiftUI

struct CommandResultView: View {
    let result: CommandResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(result.command)
                    .font(.headline)
                    .bold()
                Spacer()
                Text(result.status.uppercased())
                    .font(.caption)
                    .bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(4)
            }
            
            Text(result.summary)
                .font(.body)
            
            if !result.errors.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Errors:")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.red)
                    ForEach(result.errors, id: \.code) { err in
                        Text("• [\(err.code)] \(err.message)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            
            if let actions = result.nextActions, !actions.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Suggested actions:")
                        .font(.caption)
                        .bold()
                    ForEach(actions, id: \.command) { a in
                        Text("• \(a.label) (`\(a.command)`)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(statusColor.opacity(0.5), lineWidth: 1)
        )
    }
    
    private var statusColor: Color {
        switch result.status.lowercased() {
        case "pass", "passed": return .green
        case "warn": return .yellow
        case "blocked": return .orange
        case "fail", "failed": return .red
        default: return .secondary
        }
    }
}
