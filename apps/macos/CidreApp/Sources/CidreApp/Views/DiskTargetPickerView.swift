import SwiftUI

struct DiskTargetPickerView: View {
    let selectedTarget: String
    let candidateTargets: [DiskTarget]
    let protectedTargets: [DiskTarget]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Target Picker")
                .font(.headline)

            if candidateTargets.isEmpty {
                Text("No disposable candidate targets were discovered from the current disk scan.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Candidate targets")
                    .font(.caption)
                    .foregroundColor(.secondary)
                ForEach(candidateTargets) { target in
                    Button(action: { onSelect(target.id) }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(target.id)
                                    .font(.system(.body, design: .monospaced))
                                Text(candidateSummary(target))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if selectedTarget == target.id {
                                Text("Selected")
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding(8)
                        .background(selectedTarget == target.id ? Color.accentColor.opacity(0.12) : Color(.windowBackgroundColor))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }

            if !protectedTargets.isEmpty {
                Text("Protected / unavailable targets")
                    .font(.caption)
                    .foregroundColor(.secondary)
                ForEach(protectedTargets.prefix(6)) { target in
                    Text("\(target.id) • \(candidateSummary(target))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(10)
    }

    private func candidateSummary(_ target: DiskTarget) -> String {
        var parts: [String] = [target.name]
        if let mountPoint = target.mountPoint, !mountPoint.isEmpty {
            parts.append(mountPoint)
        }
        if let sizeBytes = target.sizeBytes {
            parts.append(String(format: "%.1f GB", Double(sizeBytes) / 1_000_000_000))
        }
        return parts.joined(separator: " • ")
    }
}
