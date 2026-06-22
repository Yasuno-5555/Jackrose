import Foundation

final class MutationTestViewModel: ObservableObject {
    @Published var state: MutationTestMode?

    func refresh(repositoryPath: String) {
        state = MutationTestModeService.shared.status(repositoryPath: repositoryPath)
    }
}
