import Foundation

final class DisposableTargetReviewViewModel: ObservableObject {
    @Published var state: DisposableTarget?

    func refresh(target: String, repositoryPath: String) {
        state = DisposableTargetCheckService.shared.evaluate(target: target, repositoryPath: repositoryPath)
    }
}
