import Foundation

public struct ScriptResult {
    public let command: String
    public let arguments: [String]
    public let exitCode: Int32
    public let stdout: String
    public let stderr: String
    public let startedAt: Date
    public let finishedAt: Date
}

public class CidreWrapperScriptRunner {
    private let repoRoot: URL
    
    public init(repoRoot: URL? = nil) {
        if let root = repoRoot {
            self.repoRoot = root
        } else {
            // Estimate repository root from running bundle or common development paths
            self.repoRoot = URL(fileURLWithPath: "/Users/yasuno/Projects/Cidre")
        }
    }
    
    public func runScript(name: String, arguments: [String]) async throws -> ScriptResult {
        let startedAt = Date()
        let scriptURL = repoRoot.appendingPathComponent("installer/scripts").appendingPathComponent(name)
        
        let process = Process()
        process.executableURL = scriptURL
        process.arguments = arguments
        process.currentDirectoryURL = repoRoot
        
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        
        return try await withCheckedThrowingContinuation { continuation in
            do {
                process.terminationHandler = { process in
                    let finishedAt = Date()
                    let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
                    let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
                    
                    let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
                    let stderr = String(data: stderrData, encoding: .utf8) ?? ""
                    
                    let result = ScriptResult(
                        command: name,
                        arguments: arguments,
                        exitCode: process.terminationStatus,
                        stdout: stdout,
                        stderr: stderr,
                        startedAt: startedAt,
                        finishedAt: finishedAt
                    )
                    
                    continuation.resume(returning: result)
                }
                
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
