import Foundation

final class ProtectedPartitionGuardService {
    static let shared = ProtectedPartitionGuardService()
    private init() {}

    func evaluate(repositoryPath: String, snapshots: DiskSnapshotAvailability) -> ProtectedPartitionGuardState? {
        let snapshotPath = snapshots.beforePath ?? snapshots.afterPath
        guard let snapshotPath else { return nil }
        let result = LiveCommandRunner.shared.run(
            "scripts/cidre-app-protected-partition-guard",
            arguments: ["--snapshot", snapshotPath, "--json"],
            repositoryPath: repositoryPath,
            isMockMode: false
        )
        guard let data = result.stdout.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(ProtectedPartitionGuardState.self, from: data)
    }
}
