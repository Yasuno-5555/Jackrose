import Foundation

final class DisposableTargetCheckService {
    static let shared = DisposableTargetCheckService()
    private init() {}

    func evaluate(target: String, repositoryPath: String) -> DisposableTarget? {
        guard !target.isEmpty else { return nil }
        let result = LiveCommandRunner.shared.run(
            "scripts/cidre-app-disposable-target-check",
            arguments: ["--target", target, "--json"],
            repositoryPath: repositoryPath,
            isMockMode: false
        )
        guard let data = result.stdout.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(DisposableTarget.self, from: data)
    }
}
