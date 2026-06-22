import Foundation

final class LiveDrillService {
    static let shared = LiveDrillService()
    private init() {}

    func state(repositoryPath: String) -> LiveDrillState? {
        let path = URL(fileURLWithPath: repositoryPath)
            .appendingPathComponent(".local/state/cidre/live-drill/current/last-state.json")
        guard let data = try? Data(contentsOf: path) else { return nil }
        return try? JSONDecoder().decode(LiveDrillState.self, from: data)
    }
}
