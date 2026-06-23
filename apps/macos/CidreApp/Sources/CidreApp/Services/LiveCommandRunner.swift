import Foundation

class LiveCommandRunner {
    static let shared = LiveCommandRunner()
    
    private init() {}
    
    func run(_ commandName: String, arguments: [String], repositoryPath: String, isMockMode: Bool) -> CommandExecution {
        let id = UUID()
        let startedAt = Date()
        let workingDir = (repositoryPath as NSString).expandingTildeInPath
        
        if isMockMode {
            let result = mockResult(for: commandName, arguments: arguments, workingDir: workingDir)
            return CommandExecution(
                id: id,
                command: commandName,
                arguments: arguments,
                workingDirectory: workingDir,
                startedAt: startedAt,
                finishedAt: Date(),
                exitCode: result.exitCode,
                status: result.status,
                stdout: result.summary,
                stderr: "",
                parsedResult: result,
                parseError: nil
            )
        }
        
        let process = Process()
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        
        let resolvedPath: String
        if commandName.hasPrefix("scripts/") {
            resolvedPath = URL(fileURLWithPath: workingDir).appendingPathComponent(commandName).path
        } else {
            resolvedPath = commandName
        }
        
        process.executableURL = URL(fileURLWithPath: resolvedPath)
        process.arguments = arguments
        process.currentDirectoryURL = URL(fileURLWithPath: workingDir)
        process.environment = resolvedEnvironment(for: workingDir)
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
            let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
            
            let stdoutString = String(data: stdoutData, encoding: .utf8) ?? ""
            let stderrString = String(data: stderrData, encoding: .utf8) ?? ""
            let exitCode = Int(process.terminationStatus)
            
            var parsedResult: CommandResult? = nil
            var parseError: String? = nil
            if let jsonData = stdoutString.data(using: .utf8) {
                do {
                    parsedResult = try JSONDecoder().decode(CommandResult.self, from: jsonData)
                } catch {
                    if arguments.contains("--json") && !stdoutString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        parseError = error.localizedDescription
                    }
                }
            }
            
            let status = parsedResult?.status ?? (exitCode == 0 ? "pass" : "fail")
            
            return CommandExecution(
                id: id,
                command: commandName,
                arguments: arguments,
                workingDirectory: workingDir,
                startedAt: startedAt,
                finishedAt: Date(),
                exitCode: exitCode,
                status: status,
                stdout: stdoutString,
                stderr: stderrString,
                parsedResult: parsedResult,
                parseError: parseError
            )
        } catch {
            return CommandExecution(
                id: id,
                command: commandName,
                arguments: arguments,
                workingDirectory: workingDir,
                startedAt: startedAt,
                finishedAt: Date(),
                exitCode: -1,
                status: "fail",
                stdout: "",
                stderr: "Execution error: \(error.localizedDescription)",
                parsedResult: nil,
                parseError: nil
            )
        }
    }

    private func resolvedEnvironment(for workingDir: String) -> [String: String] {
        var environment = ProcessInfo.processInfo.environment
        let testModePath = URL(fileURLWithPath: workingDir)
            .appendingPathComponent(".local/state/cidre/mutation/current/test-mode.json")

        guard let data = try? Data(contentsOf: testModePath),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              (json["mode"] as? String) == "enabled" || (json["enabled"] as? Bool) == true else {
            return environment
        }

        environment["CIDRE_MUTATION_TEST_MODE"] = "1"
        return environment
    }
    
    private func mockResult(for command: String, arguments: [String], workingDir: String) -> CommandResult {
        let fixturesDir = URL(fileURLWithPath: workingDir).appendingPathComponent("apps/macos/CidreApp/Fixtures")
        
        var filename = "command-result.pass.json"
        if command.contains("uninstall") || command.contains("blocked") {
            filename = "command-result.blocked.json"
        } else if command.contains("warn") {
            filename = "command-result.warn.json"
        }
        
        let fixtureUrl = fixturesDir.appendingPathComponent(filename)
        if let data = try? Data(contentsOf: fixtureUrl),
           let result = try? JSONDecoder().decode(CommandResult.self, from: data) {
            return result
        }
        
        return CommandResult(
            schemaVersion: 1,
            command: command,
            status: "pass",
            summary: "Mock result for \(command)",
            phase: nil,
            stage: nil,
            exitCode: 0,
            warnings: [],
            errors: [],
            artifacts: nil,
            nextActions: nil
        )
    }
}
