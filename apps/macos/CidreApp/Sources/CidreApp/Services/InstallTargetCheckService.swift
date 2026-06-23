import Foundation

final class InstallTargetCheckService {
    static let shared = InstallTargetCheckService()
    private init() {}

    func check(repositoryPath: String, currentTarget: String? = nil) -> InstallTarget? {
        let normalizedCurrentTarget = currentTarget?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let normalizedCurrentTarget, !normalizedCurrentTarget.isEmpty {
            let liveResult = LiveCommandRunner.shared.run(
                "scripts/cidre-app-install-target-check",
                arguments: ["--target", normalizedCurrentTarget, "--json"],
                repositoryPath: repositoryPath,
                isMockMode: false
            )
            if let data = liveResult.stdout.data(using: .utf8),
               let result = try? JSONDecoder().decode(InstallTarget.self, from: data) {
                return result
            }
        }

        let path = URL(fileURLWithPath: repositoryPath)
            .appendingPathComponent(".local/state/cidre/install/current/install-target.json")
        guard let data = try? Data(contentsOf: path),
              let result = try? JSONDecoder().decode(InstallTarget.self, from: data) else { return nil }
        if let normalizedCurrentTarget, !normalizedCurrentTarget.isEmpty,
           let savedTarget = result.target,
           savedTarget != normalizedCurrentTarget {
            return nil
        }
        return result
    }
}
