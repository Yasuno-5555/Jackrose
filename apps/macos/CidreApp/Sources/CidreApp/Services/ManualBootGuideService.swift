import Foundation

final class ManualBootGuideService {
    static let shared = ManualBootGuideService()
    private init() {}

    func guide(repositoryPath: String) -> ManualBootGuide? {
        let path = URL(fileURLWithPath: repositoryPath)
            .appendingPathComponent(".local/state/cidre/install/current/last-result.json")
        guard let data = try? Data(contentsOf: path) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let guideJSON = json["guide"] as? [String: Any],
              let guideData = try? JSONSerialization.data(withJSONObject: guideJSON, options: []) else { return nil }
        return try? JSONDecoder().decode(ManualBootGuide.self, from: guideData)
    }
}
