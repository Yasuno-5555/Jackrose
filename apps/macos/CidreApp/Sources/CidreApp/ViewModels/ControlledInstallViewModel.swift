import Foundation

final class ControlledInstallViewModel: ObservableObject {
    @Published var lastResult: [String: Any]?
    @Published var isEnforced = true

    func refresh(repositoryPath: String) {
        lastResult = ControlledInstallService.shared.lastResult(repositoryPath: repositoryPath)
    }
}
