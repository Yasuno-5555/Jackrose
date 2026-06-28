import SwiftUI

public struct CidreInstallerFinalReviewView: View {
    let contract: FinalInstallContract
    let plan: DryRunStagingPlan
    let onConfirm: () -> Void
    
    public init(contract: FinalInstallContract, plan: DryRunStagingPlan, onConfirm: @escaping () -> Void) {
        self.contract = contract
        self.plan = plan
        self.onConfirm = onConfirm
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Final Staging Plan Review")
                .font(.title2)
                .bold()
            
            Text("Verify target details before moving to apply confirmation step.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
            
            Group {
                Text("Staging Source (Rootfs Sandbox):")
                    .font(.headline)
                Text(contract.rootfs.rootfs_dir)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.secondary)
                
                Text("Staging Target Partition:")
                    .font(.headline)
                Text("\(contract.target.target_id) (\(contract.target.path))")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.secondary)
                
                Text("Capacity: \(Double(contract.target.size_bytes) / 1_073_741_824, specifier: "%.2f") GiB")
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Staging Constraints & Locks:")
                    .font(.headline)
                
                HStack {
                    Image(systemName: "lock.fill")
                    Text("Preserve boot policy (No-Mutation)")
                }
                .foregroundColor(.green)
                
                HStack {
                    Image(systemName: "lock.fill")
                    Text("Preserve macOS default boot selection")
                }
                .foregroundColor(.green)
                
                HStack {
                    Image(systemName: "lock.fill")
                    Text("No upstream Asahi/ALARM installer executions")
                }
                .foregroundColor(.green)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Button("Proceed to Apply Confirmation", action: onConfirm)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }
        }
        .padding()
    }
}
