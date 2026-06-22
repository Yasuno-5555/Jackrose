import Foundation

final class MutationTestModeService {
    static let shared = MutationTestModeService()
    private init() {}

    func status(repositoryPath: String) -> MutationTestMode? {
        let result = LiveCommandRunner.shared.run(
            "scripts/cidre-app-mutation-test-mode",
            arguments: ["--status", "--json"],
            repositoryPath: repositoryPath,
            isMockMode: false
        )
        guard let data = result.stdout.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(MutationTestMode.self, from: data)
    }
}
