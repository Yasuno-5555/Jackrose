import Foundation

final class InstallPlanService {
    static let shared = InstallPlanService()
    private init() {}

    func lastPlan(repositoryPath: String) -> ControlledInstallPlan? {
        let path = URL(fileURLWithPath: repositoryPath)
            .appendingPathComponent(".local/state/cidre/install/current/last-plan.json")
        guard let data = try? Data(contentsOf: path) else { return nil }
        return try? JSONDecoder().decode(ControlledInstallPlan.self, from: data)
    }
}
