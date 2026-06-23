import Foundation

final class DiskScanService {
    static let shared = DiskScanService()

    private init() {}

    func scan(repositoryPath: String) -> DiskScanResult? {
        let result = LiveCommandRunner.shared.run(
            "scripts/cidre-app-disk-scan",
            arguments: ["--json"],
            repositoryPath: repositoryPath,
            isMockMode: false
        )
        guard let data = result.stdout.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(DiskScanResult.self, from: data)
    }
}
