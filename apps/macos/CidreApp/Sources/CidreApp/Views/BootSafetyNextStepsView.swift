import SwiftUI

struct BootSafetyNextStepsView: View {
    let gateState: GateState?

    private var steps: [String] {
        guard let gateState else { return [] }

        var items: [String] = []
        let blockedChecks = gateState.checks.filter { $0.status != "passed" }

        for check in blockedChecks {
            switch check.id {
            case "installer-killswitch":
                items.append("Enable installer test override only when you are ready to run a controlled hardware test.")
            case "mutation-test-mode":
                items.append("Enable Controlled Mutation Test Mode before trying mutation or live-drill flows.")
            case "rollback-report":
                items.append("Generate a rollback or failure report so the gate has an exit path record.")
            case "before-snapshot":
                items.append("Capture a fresh pre-install disk snapshot from this machine.")
            case "after-snapshot":
                items.append("Capture a fresh post-install disk snapshot from this machine.")
            case "protected-partition-guard":
                items.append("Re-run protected partition review and confirm Apple-managed partitions stay unchanged.")
            case "prepost-disk-diff":
                items.append("Re-run disk diff verification and resolve any unexpected protected partition changes.")
            case "mutation-report":
                items.append("Clear stale mutation state or rerun mutation checks with the current disposable target.")
            case "live-drill-report":
                items.append("Rerun the live drill with the current target so the latest state is no longer blocked.")
            case "install-report":
                items.append("Rerun controlled install reporting after the current target and safety state are valid.")
            default:
                if let reason = check.reason, !reason.isEmpty {
                    items.append(reason)
                } else {
                    items.append("Resolve \(check.id).")
                }
            }
        }

        var deduplicated: [String] = []
        for item in items where !deduplicated.contains(item) {
            deduplicated.append(item)
        }
        return deduplicated
    }

    var body: some View {
        if !steps.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text("Next Steps")
                    .font(.headline)
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    Text("\(index + 1). \(step)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
