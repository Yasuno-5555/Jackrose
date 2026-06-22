import Foundation

final class InstallTargetCheckService {
    static let shared = InstallTargetCheckService()
    private init() {}

    func check(repositoryPath: String) -> InstallTarget? {
        let path = URL(fileURLWithPath: repositoryPath)
            .appendingPathComponent(".local/state/cidre/install/current/install-target.json")
        guard let data = try? Data(contentsOf: path) else { return nil }
        return try? JSONDecoder().decode(InstallTarget.self, from: data)
    }
}
