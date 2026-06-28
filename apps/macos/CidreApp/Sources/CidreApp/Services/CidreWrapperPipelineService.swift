import Foundation

public class CidreWrapperPipelineService {
    private let runner: CidreWrapperScriptRunner
    private let decoder: JSONDecoder
    private let repoRoot: URL
    
    public init(runner: CidreWrapperScriptRunner = CidreWrapperScriptRunner(), repoRoot: URL = URL(fileURLWithPath: "/Users/yasuno/Projects/Cidre")) {
        self.runner = runner
        self.repoRoot = repoRoot
        self.decoder = JSONDecoder()
    }
    
    private func getWrapperPath(_ path: String) -> URL {
        return repoRoot.appendingPathComponent("installer/wrapper").appendingPathComponent(path)
    }
    
    private func loadJSON<T: Codable>(_ type: T.Type, from file: String) throws -> T {
        let fileURL = getWrapperPath(file)
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(type, from: data)
    }
    
    public func selectImage() async throws -> SelectedImage {
        let res = try await runner.runScript(name: "cidre-wrapper-select-image", arguments: [
            "--metadata", repoRoot.appendingPathComponent("installer/fixtures/cidre-seed-v0.local.json").path,
            "--id", "cidre-seed-aarch64",
            "--output", getWrapperPath("selected-image.json").path
        ])
        guard res.exitCode == 0 else { throw NSError(domain: "selectImage", code: Int(res.exitCode), userInfo: [NSLocalizedDescriptionKey: res.stderr]) }
        return try loadJSON(SelectedImage.self, from: "selected-image.json")
    }
    
    public func fetchArtifact() async throws -> VerifiedArtifact {
        let res = try await runner.runScript(name: "cidre-wrapper-fetch-artifact", arguments: [
            "--selection", getWrapperPath("selected-image.json").path,
            "--download-dir", getWrapperPath("").path,
            "--output", getWrapperPath("verified-artifact.json").path
        ])
        guard res.exitCode == 0 else { throw NSError(domain: "fetchArtifact", code: Int(res.exitCode), userInfo: [NSLocalizedDescriptionKey: res.stderr]) }
        return try loadJSON(VerifiedArtifact.self, from: "verified-artifact.json")
    }
    
    public func inspectArtifact() async throws -> ArtifactStructure {
        let res = try await runner.runScript(name: "cidre-wrapper-inspect-artifact", arguments: [
            "--artifact", getWrapperPath("verified-artifact.json").path,
            "--output", getWrapperPath("artifact-structure.json").path
        ])
        guard res.exitCode == 0 else { throw NSError(domain: "inspectArtifact", code: Int(res.exitCode), userInfo: [NSLocalizedDescriptionKey: res.stderr]) }
        return try loadJSON(ArtifactStructure.self, from: "artifact-structure.json")
    }
    
    public func extractSandbox() async throws -> ExtractedRootfs {
        let args = [
            "--artifact", getWrapperPath("verified-artifact.json").path,
            "--structure", getWrapperPath("artifact-structure.json").path,
            "--output", getWrapperPath("extracted-rootfs.json").path,
            "--sandbox-dir", "/tmp/cidre-wrapper-extract"
        ]
        let res = try await runner.runScript(name: "cidre-wrapper-extract-sandbox", arguments: args)
        guard res.exitCode == 0 else { throw NSError(domain: "extractSandbox", code: Int(res.exitCode), userInfo: [NSLocalizedDescriptionKey: res.stderr]) }
        return try loadJSON(ExtractedRootfs.self, from: "extracted-rootfs.json")
    }
    
    public func validateRootfs() async throws -> RootfsValidation {
        let res = try await runner.runScript(name: "validate-cidre-extracted-rootfs-content", arguments: [
            "--extracted", getWrapperPath("extracted-rootfs.json").path,
            "--output", getWrapperPath("rootfs-validation.json").path
        ])
        guard res.exitCode == 0 else { throw NSError(domain: "validateRootfs", code: Int(res.exitCode), userInfo: [NSLocalizedDescriptionKey: res.stderr]) }
        return try loadJSON(RootfsValidation.self, from: "rootfs-validation.json")
    }
    
    public func generateInstallPlan() async throws -> CidreInstallPlan {
        let res = try await runner.runScript(name: "generate-cidre-install-plan", arguments: [
            "--rootfs-validation", getWrapperPath("rootfs-validation.json").path,
            "--output", getWrapperPath("install-plan.json").path
        ])
        guard res.exitCode == 0 else { throw NSError(domain: "generateInstallPlan", code: Int(res.exitCode), userInfo: [NSLocalizedDescriptionKey: res.stderr]) }
        return try loadJSON(CidreInstallPlan.self, from: "install-plan.json")
    }
    
    public func discoverTargets(fixture: String? = nil) async throws -> TargetCandidates {
        var args = [
            "--install-plan", getWrapperPath("install-plan.json").path,
            "--output", getWrapperPath("target-candidates.json").path
        ]
        if let f = fixture {
            args.append(contentsOf: ["--fixture", f])
        }
        let res = try await runner.runScript(name: "cidre-wrapper-discover-targets", arguments: args)
        guard res.exitCode == 0 else { throw NSError(domain: "discoverTargets", code: Int(res.exitCode), userInfo: [NSLocalizedDescriptionKey: res.stderr]) }
        return try loadJSON(TargetCandidates.self, from: "target-candidates.json")
    }
    
    public func selectTarget(targetID: String, confirm: String) async throws -> SelectedTarget {
        let res = try await runner.runScript(name: "cidre-wrapper-select-target", arguments: [
            "--candidates", getWrapperPath("target-candidates.json").path,
            "--target-id", targetID,
            "--confirm", confirm,
            "--output", getWrapperPath("selected-target.json").path
        ])
        guard res.exitCode == 0 else { throw NSError(domain: "selectTarget", code: Int(res.exitCode), userInfo: [NSLocalizedDescriptionKey: res.stderr]) }
        return try loadJSON(SelectedTarget.self, from: "selected-target.json")
    }
    
    public func bindFinalContract() async throws -> FinalInstallContract {
        let res = try await runner.runScript(name: "bind-cidre-final-install-contract", arguments: [
            "--rootfs-validation", getWrapperPath("rootfs-validation.json").path,
            "--install-plan", getWrapperPath("install-plan.json").path,
            "--selected-target", getWrapperPath("selected-target.json").path,
            "--output", getWrapperPath("final-install-contract.json").path
        ])
        guard res.exitCode == 0 else { throw NSError(domain: "bindFinalContract", code: Int(res.exitCode), userInfo: [NSLocalizedDescriptionKey: res.stderr]) }
        return try loadJSON(FinalInstallContract.self, from: "final-install-contract.json")
    }
    
    public func generateDryRunPlan() async throws -> DryRunStagingPlan {
        let res = try await runner.runScript(name: "generate-cidre-dryrun-staging-plan", arguments: [
            "--contract", getWrapperPath("final-install-contract.json").path,
            "--output", getWrapperPath("dry-run-staging-plan.json").path
        ])
        guard res.exitCode == 0 else { throw NSError(domain: "generateDryRunPlan", code: Int(res.exitCode), userInfo: [NSLocalizedDescriptionKey: res.stderr]) }
        return try loadJSON(DryRunStagingPlan.self, from: "dry-run-staging-plan.json")
    }
    
    public func stageTargetWithApply(confirm: String, fixtureMode: Bool = false) async throws -> StagingResult {
        var args = [
            "--contract", getWrapperPath("final-install-contract.json").path,
            "--dryrun-plan", getWrapperPath("dry-run-staging-plan.json").path,
            "--confirm", confirm,
            "--output", getWrapperPath("staging-result.json").path,
            "--apply"
        ]
        if fixtureMode {
            args.append(contentsOf: ["--fixture-mode", "--mount-root", "/tmp/cidre-target-mount"])
        }
        let res = try await runner.runScript(name: "cidre-wrapper-stage-target", arguments: args)
        guard res.exitCode == 0 else { throw NSError(domain: "stageTargetWithApply", code: Int(res.exitCode), userInfo: [NSLocalizedDescriptionKey: res.stderr]) }
        return try loadJSON(StagingResult.self, from: "staging-result.json")
    }
    
    public func validateStagedTarget(fixtureMode: Bool = false) async throws -> StagedTargetValidation {
        var args = [
            "--staging-result", getWrapperPath("staging-result.json").path,
            "--output", getWrapperPath("staged-target-validation.json").path
        ]
        if fixtureMode {
            args.append("--fixture-mode")
        }
        let res = try await runner.runScript(name: "validate-cidre-staged-target", arguments: args)
        guard res.exitCode == 0 else { throw NSError(domain: "validateStagedTarget", code: Int(res.exitCode), userInfo: [NSLocalizedDescriptionKey: res.stderr]) }
        return try loadJSON(StagedTargetValidation.self, from: "staged-target-validation.json")
    }
    
    public func generateFirstBootHandoff() async throws -> FirstBootHandoff {
        let res = try await runner.runScript(name: "generate-cidre-firstboot-handoff", arguments: [
            "--staged-validation", getWrapperPath("staged-target-validation.json").path,
            "--output", getWrapperPath("firstboot-handoff.json").path
        ])
        guard res.exitCode == 0 else { throw NSError(domain: "generateFirstBootHandoff", code: Int(res.exitCode), userInfo: [NSLocalizedDescriptionKey: res.stderr]) }
        return try loadJSON(FirstBootHandoff.self, from: "firstboot-handoff.json")
    }
    
    public func freezeInstallerMVP() async throws -> InstallerMVPFreeze {
        let res = try await runner.runScript(name: "freeze-cidre-installer-mvp", arguments: [
            "--staging-result", getWrapperPath("staging-result.json").path,
            "--staged-validation", getWrapperPath("staged-target-validation.json").path,
            "--firstboot-handoff", getWrapperPath("firstboot-handoff.json").path,
            "--output", getWrapperPath("installer-mvp-freeze.json").path
        ])
        guard res.exitCode == 0 else { throw NSError(domain: "freezeInstallerMVP", code: Int(res.exitCode), userInfo: [NSLocalizedDescriptionKey: res.stderr]) }
        return try loadJSON(InstallerMVPFreeze.self, from: "installer-mvp-freeze.json")
    }
}
