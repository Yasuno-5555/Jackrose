import Foundation
import Combine

@MainActor
public class CidreInstallerShellViewModel: ObservableObject {
    @Published public var currentStep: InstallerStep = .welcome
    @Published public var status: PipelineStatus = .idle
    @Published public var errorMessage: String? = nil
    
    // Decoded configurations
    @Published public var selectedImage: SelectedImage? = nil
    @Published public var verifiedArtifact: VerifiedArtifact? = nil
    @Published public var rootfsValidation: RootfsValidation? = nil
    @Published public var installPlan: CidreInstallPlan? = nil
    @Published public var targetCandidates: TargetCandidates? = nil
    @Published public var selectedTarget: SelectedTarget? = nil
    @Published public var finalContract: FinalInstallContract? = nil
    @Published public var dryRunPlan: DryRunStagingPlan? = nil
    @Published public var stagingResult: StagingResult? = nil
    @Published public var stagedValidation: StagedTargetValidation? = nil
    @Published public var firstBootHandoff: FirstBootHandoff? = nil
    @Published public var mvpFreeze: InstallerMVPFreeze? = nil
    
    // Testing options
    public var fixtureMode = false
    public var fakeMount = false
    
    private let service: CidreWrapperPipelineService
    
    public init(service: CidreWrapperPipelineService = CidreWrapperPipelineService()) {
        self.service = service
    }
    
    public func startInstaller() {
        currentStep = .artifactVerification
        Task {
            await verifyArtifacts()
        }
    }
    
    public func verifyArtifacts() async {
        status = .running("Selecting installer metadata...")
        errorMessage = nil
        
        do {
            selectedImage = try await service.selectImage()
            
            status = .running("Downloading and validating release seed artifact...")
            verifiedArtifact = try await service.fetchArtifact()
            
            status = .running("Inspecting archive structures...")
            _ = try await service.inspectArtifact()
            
            status = .running("Extracting rootfs inside safe sandbox...")
            _ = try await service.extractSandbox()
            
            status = .running("Validating rootfs baseline configurations...")
            rootfsValidation = try await service.validateRootfs()
            
            status = .running("Generating installation plan...")
            installPlan = try await service.generateInstallPlan()
            
            status = .succeeded("Artifact verification complete.")
            currentStep = .diskPlanning
            await discoverTargets()
        } catch {
            status = .failed(error.localizedDescription)
            errorMessage = error.localizedDescription
            currentStep = .failed(error.localizedDescription)
        }
    }
    
    public func discoverTargets() async {
        status = .running("Scanning partition tables for candidates...")
        errorMessage = nil
        
        do {
            let fixturePath = fixtureMode ? "/Users/yasuno/Projects/Cidre/installer/fixtures/target-discovery/lsblk.sample.json" : nil
            targetCandidates = try await service.discoverTargets(fixture: fixturePath)
            status = .idle
        } catch {
            status = .failed(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }
    
    public func selectCandidateTarget(_ candidate: TargetCandidate) async {
        status = .running("Securing target selection contract...")
        errorMessage = nil
        
        do {
            selectedTarget = try await service.selectTarget(targetID: candidate.target_id, confirm: "SELECT CIDRE TARGET ONLY - NO INSTALL")
            
            status = .running("Binding final install contract...")
            finalContract = try await service.bindFinalContract()
            
            status = .running("Generating staging dry-run configurations...")
            dryRunPlan = try await service.generateDryRunPlan()
            
            status = .succeeded("Staging preview ready.")
            currentStep = .finalReview
        } catch {
            status = .failed(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }
    
    public func confirmReview() {
        currentStep = .applyConfirmation
    }
    
    public func applyStaging(confirmation: String) async {
        status = .running("Applying staging modifications...")
        errorMessage = nil
        
        do {
            stagingResult = try await service.stageTargetWithApply(confirm: confirmation, fixtureMode: fakeMount)
            
            status = .running("Validating staged target rootfs...")
            stagedValidation = try await service.validateStagedTarget(fixtureMode: fakeMount)
            
            status = .running("Configuring first boot handoff instructions...")
            firstBootHandoff = try await service.generateFirstBootHandoff()
            
            status = .running("Finalizing MVP pipeline freeze...")
            mvpFreeze = try await service.freezeInstallerMVP()
            
            status = .succeeded("Installer MVP Complete!")
            currentStep = .firstBootHandoff
        } catch {
            status = .failed(error.localizedDescription)
            errorMessage = error.localizedDescription
            currentStep = .failed(error.localizedDescription)
        }
    }
}
