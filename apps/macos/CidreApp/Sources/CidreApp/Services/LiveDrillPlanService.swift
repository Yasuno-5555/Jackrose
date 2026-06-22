import Foundation

final class LiveDrillPlanService {
    static let shared = LiveDrillPlanService()
    private init() {}

    func create(level: Int, target: String?, repositoryPath: String) -> LiveDrillPlan? {
        var arguments = ["--plan", "--level", String(level), "--json"]
        if let target, !target.isEmpty {
            arguments.append(contentsOf: ["--target", target])
        }
        let result = LiveCommandRunner.shared.run(
            "scripts/cidre-app-live-drill",
            arguments: arguments,
            repositoryPath: repositoryPath,
            isMockMode: false
        )
        guard let data = result.stdout.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(LiveDrillPlan.self, from: data)
    }
}
