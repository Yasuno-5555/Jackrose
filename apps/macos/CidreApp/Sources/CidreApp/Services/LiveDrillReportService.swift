import Foundation

final class LiveDrillReportService {
    static let shared = LiveDrillReportService()
    private init() {}

    func markdown(repositoryPath: String) -> String {
        LiveCommandRunner.shared.run(
            "scripts/cidre-app-live-drill-report",
            arguments: ["--markdown"],
            repositoryPath: repositoryPath,
            isMockMode: false
        ).stdout
    }
}
