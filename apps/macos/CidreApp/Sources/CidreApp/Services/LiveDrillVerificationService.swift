import Foundation

final class LiveDrillVerificationService {
    static let shared = LiveDrillVerificationService()
    private init() {}

    func result(repositoryPath: String) -> LiveDrillResult? {
        let path = URL(fileURLWithPath: repositoryPath)
            .appendingPathComponent(".local/state/cidre/live-drill/current/last-verification.json")
        guard let data = try? Data(contentsOf: path) else { return nil }
        return try? JSONDecoder().decode(LiveDrillResult.self, from: data)
    }
}
