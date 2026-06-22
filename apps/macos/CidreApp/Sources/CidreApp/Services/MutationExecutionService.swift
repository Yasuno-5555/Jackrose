import Foundation

final class MutationExecutionService {
    static let shared = MutationExecutionService()
    private init() {}

    func report(repositoryPath: String) -> MutationExecutionResult? {
        let path = URL(fileURLWithPath: repositoryPath)
            .appendingPathComponent(".local/state/cidre/mutation/current/last-execution.json")
        guard let data = try? Data(contentsOf: path) else { return nil }
        return try? JSONDecoder().decode(MutationExecutionResult.self, from: data)
    }
}
