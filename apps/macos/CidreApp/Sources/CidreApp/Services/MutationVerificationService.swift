import Foundation

final class MutationVerificationService {
    static let shared = MutationVerificationService()
    private init() {}

    func report(repositoryPath: String) -> MutationVerificationResult? {
        let path = URL(fileURLWithPath: repositoryPath)
            .appendingPathComponent(".local/state/cidre/mutation/current/last-verification.json")
        guard let data = try? Data(contentsOf: path) else { return nil }
        return try? JSONDecoder().decode(MutationVerificationResult.self, from: data)
    }
}
