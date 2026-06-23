import SwiftUI

struct InstallExecutionStepView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @StateObject private var mutation = DiskMutationViewModel()

    var body: some View {
        WizardStepContainerView(
            title: "Install Execution",
            bodyText: "Run the prepared installer stage and monitor payload staging, verification results, and manual boot guidance."
        ) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Cidre installation payload is staged directly on the prepared APFS volume. The boot policy and startup disk configurations remain untouched.")
                    .font(.body)
                    .foregroundColor(.secondary)

                ControlledInstallDashboardView(lastResult: mutation.controlledInstallLastResult)

                if let plan = mutation.controlledInstallPlan {
                    InstallPlanPreviewView(plan: plan)
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("No Active Install Plan")
                            .font(.headline)
                        Text("Please make sure you have successfully completed the Disk Plan stage.")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(8)
                }

                InstallPayloadProgressView(lastResult: mutation.controlledInstallLastResult)
                InstallVerificationView(lastResult: mutation.controlledInstallLastResult)
                NoDefaultBootPolicyView(lastResult: mutation.controlledInstallLastResult)

                if mutation.manualBootGuide != nil {
                    ManualBootGuideView(guide: mutation.manualBootGuide)
                }
            }
        }
        .onAppear {
            mutation.refreshKillSwitch(repositoryPath: appVM.repositoryPath)
            mutation.refreshSafetyStatus(repositoryPath: appVM.repositoryPath)
        }
    }
}

