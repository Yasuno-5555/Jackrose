import Foundation

class RepositoryPathStore {
    static let shared = RepositoryPathStore()
    private let pathKey = "CidreRepositoryPath"
    
    private init() {}
    
    func loadPath() -> String {
        if let savedPath = UserDefaults.standard.string(forKey: pathKey), validatePath(savedPath).valid {
            let expandedPath = (savedPath as NSString).expandingTildeInPath
            let bundledMarker = URL(fileURLWithPath: expandedPath).appendingPathComponent(".cidre-backend").path
            if FileManager.default.fileExists(atPath: bundledMarker),
               let refreshedPath = installBundledBackend() {
                savePath(refreshedPath)
                return refreshedPath
            }
            return savedPath
        }
        if let bundledPath = installBundledBackend() {
            savePath(bundledPath)
            return bundledPath
        }
        return locateDefaultPath()
    }
    
    func savePath(_ path: String) {
        UserDefaults.standard.set(path, forKey: pathKey)
    }
    
    func resetPath() {
        UserDefaults.standard.removeObject(forKey: pathKey)
    }
    
    func validatePath(_ path: String) -> RepositoryStatus {
        let fm = FileManager.default
        let expandedPath = (path as NSString).expandingTildeInPath
        let pathUrl = URL(fileURLWithPath: expandedPath)
        
        let exists = fm.fileExists(atPath: pathUrl.path)
        let hasInterface = fm.fileExists(atPath: pathUrl.appendingPathComponent("interface").path)
        let hasScripts = fm.fileExists(atPath: pathUrl.appendingPathComponent("scripts").path)
        let hasMacOSApp = fm.fileExists(atPath: pathUrl.appendingPathComponent("apps/macos/CidreApp").path)
        let isBundledBackend = fm.fileExists(atPath: pathUrl.appendingPathComponent(".cidre-backend").path)
        let hasManifest = fm.fileExists(atPath: pathUrl.appendingPathComponent("interface/command-manifest.json").path)
        let hasActions = fm.fileExists(atPath: pathUrl.appendingPathComponent("interface/app-actions.json").path)
        
        let warnings: [String] = []
        var errors: [String] = []
        
        if !exists {
            errors.append("Path does not exist")
        } else {
            if !hasInterface { errors.append("Missing interface directory") }
            if !hasScripts { errors.append("Missing scripts directory") }
            if !hasMacOSApp && !isBundledBackend { errors.append("Missing Cidre app backend marker") }
            if !hasManifest { errors.append("Missing command-manifest.json") }
            if !hasActions { errors.append("Missing app-actions.json") }
        }

        let valid = exists && hasInterface && hasScripts && (hasMacOSApp || isBundledBackend) && hasManifest && hasActions

        return RepositoryStatus(
            path: path,
            exists: exists,
            hasInterfaceDirectory: hasInterface,
            hasScriptsDirectory: hasScripts,
            hasMacOSAppDirectory: hasMacOSApp || isBundledBackend,
            hasCommandManifest: hasManifest,
            hasAppActions: hasActions,
            valid: valid,
            warnings: warnings,
            errors: errors
        )
    }
    
    private func locateDefaultPath() -> String {
        let fm = FileManager.default
        let homeDir = fm.homeDirectoryForCurrentUser
        
        let candidates = [
            homeDir.appendingPathComponent("Projects/Cidre").path,
            homeDir.appendingPathComponent("Cidre").path
        ]
        
        for candidate in candidates {
            if fm.fileExists(atPath: candidate) {
                return candidate
            }
        }
        
        return candidates[0]
    }

    private func installBundledBackend() -> String? {
        let fm = FileManager.default
        guard let source = Bundle.main.resourceURL?.appendingPathComponent("CidreBackend"),
              fm.fileExists(atPath: source.appendingPathComponent(".cidre-backend").path) else { return nil }
        let support = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let destination = support.appendingPathComponent("Cidre/Backend", isDirectory: true)
        do {
            try fm.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            if fm.fileExists(atPath: destination.path) {
                try fm.removeItem(at: destination)
            }
            try fm.copyItem(at: source, to: destination)
            return destination.path
        } catch {
            return nil
        }
    }
}
