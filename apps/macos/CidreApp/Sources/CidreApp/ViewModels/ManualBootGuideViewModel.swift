import Foundation

final class ManualBootGuideViewModel: ObservableObject {
    @Published var guide: ManualBootGuide?

    func refresh(repositoryPath: String) {
        guide = ManualBootGuideService.shared.guide(repositoryPath: repositoryPath)
    }
}
