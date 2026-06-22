import Foundation

final class InstallPlanViewModel: ObservableObject {
    @Published var plan: ControlledInstallPlan?

    func refresh(repositoryPath: String) {
        plan = InstallPlanService.shared.lastPlan(repositoryPath: repositoryPath)
    }
}
