import SwiftUI

struct LiveDrillDashboardView: View {
    let state: LiveDrillState?
    let mutationMode: MutationTestMode?
    let killSwitch: InstallerKillSwitchState

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Controlled Live Drill")
                .font(.headline)
            Text("Normal install remains disabled. Live drills are for Cidre development only.")
                .foregroundColor(.secondary)
            Text("Mutation test mode: \(mutationMode?.enabled == true ? "enabled" : "disabled")")
                .font(.caption)
            Text("Killswitch: \(killSwitch.installerStatus)")
                .font(.caption)
            Text("Last drill: \(state?.status ?? "none")")
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(10)
    }
}
