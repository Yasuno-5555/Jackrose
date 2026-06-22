import Foundation

final class ControlledInstallService {
    static let shared = ControlledInstallService()
    private init() {}

    func lastResult(repositoryPath: String) -> [String: Any]? {
        let path = URL(fileURLWithPath: repositoryPath)
            .appendingPathComponent(".local/state/cidre/install/current/last-result.json")
        guard let data = try? Data(contentsOf: path) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    }
}
