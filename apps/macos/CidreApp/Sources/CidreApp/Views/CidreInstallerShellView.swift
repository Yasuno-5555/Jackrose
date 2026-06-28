import SwiftUI

public struct CidreInstallerShellView: View {
    @StateObject private var viewModel = CidreInstallerShellViewModel()
    
    public init(fixtureMode: Bool = false, fakeMount: Bool = false) {
        // We defer assigning properties to VM since Swift initialized StateObjects
        // differently depending on SwiftUI contexts
        let service = CidreWrapperPipelineService()
        let vm = CidreInstallerShellViewModel(service: service)
        vm.fixtureMode = fixtureMode
        vm.fakeMount = fakeMount
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    public var body: some View {
        VStack {
            switch viewModel.currentStep {
            case .welcome:
                welcomeScreen
            case .artifactVerification:
                CidreInstallerProgressView(statusText: getStatusText())
            case .diskPlanning:
                diskPlanningScreen
            case .finalReview:
                if let contract = viewModel.finalContract, let plan = viewModel.dryRunPlan {
                    CidreInstallerFinalReviewView(contract: contract, plan: plan) {
                        viewModel.confirmReview()
                    }
                } else {
                    CidreInstallerProgressView(statusText: "Analyzing staging contracts...")
                }
            case .applyConfirmation:
                CidreInstallerApplyConfirmationView { confirmation in
                    viewModel.currentStep = .installing
                    Task {
                        await viewModel.applyStaging(confirmation: confirmation)
                    }
                }
            case .installing:
                CidreInstallerProgressView(statusText: getStatusText())
            case .firstBootHandoff:
                if let handoff = viewModel.firstBootHandoff {
                    CidreFirstBootHandoffView(handoff: handoff) {
                        viewModel.currentStep = .complete
                    }
                } else {
                    CidreInstallerProgressView(statusText: "Aggregating freeze metadata...")
                }
            case .complete:
                completionScreen
            case .failed(let msg):
                failureScreen(msg: msg)
            }
        }
        .frame(width: 600, height: 480)
        .background(Color(.windowBackgroundColor))
    }
    
    private func getStatusText() -> String {
        switch viewModel.status {
        case .idle:
            return "Ready."
        case .running(let msg):
            return msg
        case .succeeded(let msg):
            return msg
        case .failed(let msg):
            return "Failed: \(msg)"
        }
    }
    
    private var welcomeScreen: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.and.arrow.down.on.square.fill")
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundColor(.accentColor)
            
            Text("Cidre Installer Shell")
                .font(.largeTitle)
                .bold()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Preserves target boot policy modifications.")
                Text("• Does not change macOS default boot selection.")
                Text("• Controlled apply writes only to target partition.")
                Text("• Manual boot options selection required on first startup.")
            }
            .font(.body)
            .foregroundColor(.secondary)
            .padding()
            
            Spacer()
            
            Button("Start Installer Pipeline", action: {
                viewModel.startInstaller()
            })
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
    
    private var diskPlanningScreen: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Target Partition")
                .font(.title2)
                .bold()
            
            Text("Only partitions classified as safe_candidate can be selected.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
            
            if let candidates = viewModel.targetCandidates?.candidates {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(candidates) { candidate in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(candidate.target_id) (\(candidate.path))")
                                        .font(.headline)
                                    Text("Class: \(candidate.classification)")
                                        .font(.caption)
                                        .foregroundColor(candidate.eligible ? .green : .red)
                                    Text("Size: \(Double(candidate.size_bytes) / 1_073_741_824, specifier: "%.2f") GiB")
                                        .font(.caption)
                                }
                                
                                Spacer()
                                
                                Button("Select") {
                                    Task {
                                        await viewModel.selectCandidateTarget(candidate)
                                    }
                                }
                                .disabled(!candidate.eligible)
                            }
                            .padding(8)
                            .background(Color(.controlBackgroundColor))
                            .cornerRadius(6)
                        }
                    }
                }
            } else {
                ProgressView()
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var completionScreen: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundColor(.green)
            
            Text("Cidre Installation Done")
                .font(.title)
                .bold()
            
            Text("All staging steps have been executed and the pipeline frozen.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
    }
    
    private func failureScreen(msg: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "xmark.octagon.fill")
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundColor(.red)
            
            Text("Pipeline Execution Failed")
                .font(.title)
                .bold()
            
            Text(msg)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .padding()
    }
}
