import Foundation

final class MutationReportService {
    static let shared = MutationReportService()
    private init() {}

    func markdown(repositoryPath: String) -> String {
        LiveCommandRunner.shared.run(
            "scripts/cidre-app-mutation-report",
            arguments: ["--markdown"],
            repositoryPath: repositoryPath,
            isMockMode: false
        ).stdout
    }
}
