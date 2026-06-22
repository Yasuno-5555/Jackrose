import Foundation

final class LiveDrillViewModel: ObservableObject {
    @Published var state: LiveDrillState?
    @Published var plan: LiveDrillPlan?
    @Published var result: LiveDrillResult?
    @Published var reportMarkdown = ""
    @Published var selectedLevel: LiveDrillLevel = .noop

    func refresh(repositoryPath: String) {
        state = LiveDrillService.shared.state(repositoryPath: repositoryPath)
        result = LiveDrillVerificationService.shared.result(repositoryPath: repositoryPath)
        reportMarkdown = LiveDrillReportService.shared.markdown(repositoryPath: repositoryPath)
    }
}
