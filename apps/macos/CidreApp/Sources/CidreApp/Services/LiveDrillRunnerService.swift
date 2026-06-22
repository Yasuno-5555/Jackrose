import Foundation

final class LiveDrillRunnerService {
    static let shared = LiveDrillRunnerService()
    private init() {}

    func run(level: Int, target: String?, repositoryPath: String, dryRun: Bool) -> CommandExecution {
        var arguments = ["--run", "--level", String(level)]
        if let target, !target.isEmpty {
            arguments.append(contentsOf: ["--target", target])
        }
        if dryRun {
            arguments.append("--dry-run")
        }
        arguments.append("--json")
        return LiveCommandRunner.shared.run(
            "scripts/cidre-app-live-drill",
            arguments: arguments,
            repositoryPath: repositoryPath,
            isMockMode: false
        )
    }
}
