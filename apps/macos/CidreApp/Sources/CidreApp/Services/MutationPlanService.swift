import Foundation

final class MutationPlanService {
    static let shared = MutationPlanService()
    private init() {}

    func sign(planFile: String, repositoryPath: String) -> MutationPlanSignature? {
        let result = LiveCommandRunner.shared.run(
            "scripts/cidre-app-mutation-plan-sign",
            arguments: ["--plan", planFile, "--json"],
            repositoryPath: repositoryPath,
            isMockMode: false
        )
        guard let data = result.stdout.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(MutationPlanSignature.self, from: data)
    }

    func confirm(planFile: String, phrase: String, repositoryPath: String) -> MutationConfirmation? {
        let result = LiveCommandRunner.shared.run(
            "scripts/cidre-app-mutation-confirmation",
            arguments: ["--plan", planFile, "--phrase", phrase, "--json"],
            repositoryPath: repositoryPath,
            isMockMode: false
        )
        guard let data = result.stdout.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(MutationConfirmation.self, from: data)
    }
}
