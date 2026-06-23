import Foundation

final class TargetBoundStateCleanupService {
    static let shared = TargetBoundStateCleanupService()

    private init() {}

    func purgeStaleState(repositoryPath: String, currentTarget: String) {
        let normalizedTarget = currentTarget.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTarget.isEmpty else { return }

        let fileManager = FileManager.default
        let root = URL(fileURLWithPath: repositoryPath)
        let candidatePaths = [
            ".local/state/cidre/install/current/install-target.json",
            ".local/state/cidre/install/current/last-plan.json",
            ".local/state/cidre/install/current/last-result.json",
            ".local/state/cidre/mutation/current/disposable-target.json",
            ".local/state/cidre/mutation/current/last-plan.json",
            ".local/state/cidre/mutation/current/last-execution.json",
            ".local/state/cidre/mutation/current/last-verification.json",
            ".local/state/cidre/boot-safety/current/gate-evaluate-controlled-install.json",
        ]

        for relativePath in candidatePaths {
            let url = root.appendingPathComponent(relativePath)
            guard let data = try? Data(contentsOf: url),
                  let object = try? JSONSerialization.jsonObject(with: data, options: []) else {
                continue
            }

            guard let recordedTarget = extractTarget(from: object)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
                  !recordedTarget.isEmpty else {
                continue
            }

            if recordedTarget != normalizedTarget {
                try? fileManager.removeItem(at: url)
            }
        }
    }

    private func extractTarget(from object: Any) -> String? {
        guard let dictionary = object as? [String: Any] else { return nil }

        if let target = dictionary["target"] as? String {
            return target
        }
        if let plan = dictionary["plan"] as? [String: Any],
           let target = plan["target"] as? String {
            return target
        }
        if let stageResult = dictionary["stage_result"] as? [String: Any],
           let target = stageResult["target"] as? String {
            return target
        }

        return nil
    }
}
