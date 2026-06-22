import Foundation

final class InstallTargetReviewViewModel: ObservableObject {
    @Published var targetCheck: InstallTarget?

    func refresh(repositoryPath: String) {
        targetCheck = InstallTargetCheckService.shared.check(repositoryPath: repositoryPath)
    }
}
