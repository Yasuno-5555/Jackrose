import Foundation
import CryptoKit

enum DiskOperationService {
    struct Result {
        let status: String
        let summary: String
        let exitCode: Int32
        let command: [String]
        let stdout: String
        let stderr: String
    }

    private static let diskIdentifier = try! NSRegularExpression(pattern: #"^disk[0-9]+s[0-9]+$"#)
    private static let containerIdentifier = try! NSRegularExpression(pattern: #"^disk[0-9]+$"#)
    private static let sizeValue = try! NSRegularExpression(pattern: #"^(0|[1-9][0-9]*(B|K|M|G|T|P))$"#, options: .caseInsensitive)

    static func execute(_ request: HelperProtocol) -> Result {
        guard request.schemaVersion == 1 else { return rejected("Unsupported helper request schema.") }
        guard HelperAuthorization.canExecute(request) else { return rejected("Confirmation token does not match the plan.") }
        guard let target = request.target else {
            return rejected("Target is required.")
        }
        if request.operation == "partition-create" || request.operation == "partition-delete" || request.operation == "cidre-uninstall" {
            guard request.planID == expectedPlanID(for: request, target: target) else {
                return rejected("Plan ID does not match the requested disk operation.")
            }
        }
        if request.operation == "cidre-uninstall" {
            return executeCidreUninstall(request, stubTarget: target)
        }

        let command: [String]
        switch request.operation {
        case "partition-create":
            guard request.arguments.count == 3,
                  (matches(containerIdentifier, target) || matches(diskIdentifier, target)),
                  matches(sizeValue, request.arguments[0]),
                  validVolumeName(request.arguments[1]),
                  matches(sizeValue, request.arguments[2]) else {
                return rejected("partition-create requires container-size, volume-name, and partition-size.")
            }
            guard let resizeError = validateResize(target: target, containerSize: request.arguments[0], partitionSize: request.arguments[2]) else {
                return rejected("Could not read APFS resize limits for the selected target.")
            }
            guard resizeError.isEmpty else { return rejected(resizeError) }
            guard isValidInstallCreationTarget(target) else {
                return rejected("The selected target is not the current startup APFS container or startup physical store.")
            }
            command = ["/usr/sbin/diskutil", "apfs", "resizeContainer", target, request.arguments[0], "APFS", request.arguments[1], request.arguments[2]]
        case "apfs-add-volume":
            guard request.arguments.count == 2,
                  matches(containerIdentifier, target),
                  validVolumeName(request.arguments[1]) else {
                return rejected("apfs-add-volume requires a container target, filesystem, and volume name.")
            }
            guard !isProtectedForCreation(target) else { return rejected("The selected APFS container belongs to the startup system or another protected region.") }
            command = ["/usr/sbin/diskutil", "apfs", "addVolume", target, request.arguments[0], request.arguments[1]]
        case "apfs-resize-container":
            guard matches(containerIdentifier, target),
                  request.arguments.count == 1,
                  matches(sizeValue, request.arguments[0]) else {
                return rejected("apfs-resize-container requires one validated size.")
            }
            guard let resizeError = validateResize(target: target, containerSize: request.arguments[0], partitionSize: nil) else {
                return rejected("Could not read APFS resize limits for the selected target.")
            }
            guard resizeError.isEmpty else { return rejected(resizeError) }
            command = ["/usr/sbin/diskutil", "apfs", "resizeContainer", target, request.arguments[0]]
        case "apfs-delete-volume":
            guard matches(diskIdentifier, target), request.arguments.isEmpty else { return rejected("apfs-delete-volume accepts no extra arguments.") }
            guard !isProtectedForDeletion(target) else { return rejected("The selected APFS volume is protected or belongs to the startup system.") }
            command = ["/usr/sbin/diskutil", "apfs", "deleteVolume", target]
        case "partition-delete":
            guard matches(diskIdentifier, target), request.arguments.isEmpty else { return rejected("partition-delete accepts no extra arguments.") }
            guard !isProtectedForDeletion(target) else { return rejected("The selected partition is protected or belongs to the startup system.") }
            command = ["/usr/sbin/diskutil", "eraseVolume", "free", "CidreFreeSpace", target]
        default:
            return rejected("Operation is not in the helper allowlist.")
        }

        guard validateTargetStillExists(target) else { return rejected("Target disappeared or changed before execution.") }
        if request.dryRun {
            return Result(status: "pass", summary: "Validated disk operation preview.", exitCode: 0, command: command, stdout: "", stderr: "")
        }

        let process = Process()
        let stdout = Pipe()
        let stderr = Pipe()
        process.executableURL = URL(fileURLWithPath: command[0])
        process.arguments = Array(command.dropFirst())
        process.standardOutput = stdout
        process.standardError = stderr
        do {
            try process.run()
            process.waitUntilExit()
            let output = String(data: stdout.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            let error = String(data: stderr.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            return Result(
                status: process.terminationStatus == 0 ? "pass" : "fail",
                summary: process.terminationStatus == 0 ? "Disk operation completed." : "diskutil rejected or failed the operation.",
                exitCode: process.terminationStatus,
                command: command,
                stdout: output,
                stderr: error
            )
        } catch {
            return Result(status: "fail", summary: "Could not start diskutil.", exitCode: 1, command: command, stdout: "", stderr: error.localizedDescription)
        }
    }

    private static func rejected(_ message: String) -> Result {
        Result(status: "blocked", summary: message, exitCode: 4, command: [], stdout: "", stderr: "")
    }

    private static func matches(_ expression: NSRegularExpression, _ value: String) -> Bool {
        expression.firstMatch(in: value, range: NSRange(value.startIndex..., in: value)) != nil
    }

    private static func validVolumeName(_ value: String) -> Bool {
        !value.isEmpty && value.count <= 64 && !value.contains("/") && !value.contains("\n")
    }

    private static func isProtectedForCreation(_ target: String) -> Bool {
        guard let root = plist(["info", "-plist", "/"]) else { return true }
        let startupContainer = root["APFSContainerReference"] as? String
        let startupStores = Set((root["APFSPhysicalStores"] as? [[String: Any]] ?? []).compactMap { $0["APFSPhysicalStore"] as? String })
        if target == startupContainer || startupStores.contains(target) {
            return true
        }
        guard let containerList = plist(["apfs", "list", "-plist", target]) else { return true }
        let containers = containerList["Containers"] as? [[String: Any]] ?? []
        guard let container = containers.first(where: { ($0["ContainerReference"] as? String) == target }) else { return true }
        let physicalStores = Set((container["PhysicalStores"] as? [[String: Any]] ?? []).compactMap { $0["DeviceIdentifier"] as? String })
        return !physicalStores.isDisjoint(with: startupStores)
    }

    private static func isValidInstallCreationTarget(_ target: String) -> Bool {
        guard let root = plist(["info", "-plist", "/"]),
              let targetInfo = plist(["info", "-plist", target]) else { return false }
        let startupContainer = root["APFSContainerReference"] as? String
        let startupStores = Set((root["APFSPhysicalStores"] as? [[String: Any]] ?? []).compactMap { $0["APFSPhysicalStore"] as? String })
        let identifier = targetInfo["DeviceIdentifier"] as? String ?? target
        let content = ((targetInfo["Content"] as? String) ?? (targetInfo["FilesystemType"] as? String) ?? "").lowercased()
        if identifier == startupContainer {
            return true
        }
        return startupStores.contains(identifier) && content.contains("apple_apfs")
    }

    private static func expectedPlanID(for request: HelperProtocol, target: String) -> String? {
        if request.operation == "cidre-uninstall" {
            let canonical = (["uninstall", request.operation, target] + request.arguments).joined(separator: "\n")
            let digest = SHA256.hash(data: Data(canonical.utf8))
            return digest.prefix(8).map { String(format: "%02x", $0) }.joined()
        }
        let mode = request.operation == "partition-create" ? "install" : "uninstall"
        let containerSize = request.arguments.indices.contains(0) && request.operation == "partition-create" ? request.arguments[0] : ""
        let volumeName = request.arguments.indices.contains(1) && request.operation == "partition-create" ? request.arguments[1] : ""
        let partitionSize = request.arguments.indices.contains(2) && request.operation == "partition-create" ? request.arguments[2] : ""
        let canonical = [mode, request.operation, target, containerSize, partitionSize, volumeName].joined(separator: "\n")
        let digest = SHA256.hash(data: Data(canonical.utf8))
        return digest.prefix(8).map { String(format: "%02x", $0) }.joined()
    }

    private static func executeCidreUninstall(_ request: HelperProtocol, stubTarget: String) -> Result {
        guard request.arguments.count == 4 else { return rejected("Cidre uninstall requires EFI, Linux, Recovery, and startup APFS targets.") }
        let efiTarget = request.arguments[0]
        let linuxTarget = request.arguments[1]
        let recoveryTarget = request.arguments[2]
        let growTarget = request.arguments[3]
        guard [efiTarget, linuxTarget, recoveryTarget].allSatisfy({ matches(diskIdentifier, $0) }),
              matches(containerIdentifier, growTarget) else {
            return rejected("Uninstall requires partition identifiers plus a startup APFS container reference.")
        }
        guard let stub = plist(["info", "-plist", stubTarget]),
              let efi = plist(["info", "-plist", efiTarget]),
              let linux = plist(["info", "-plist", linuxTarget]),
              let recovery = plist(["info", "-plist", recoveryTarget]),
              let root = plist(["info", "-plist", "/"]),
              let rootStore = root["APFSPhysicalStores"] as? [[String: Any]],
              let startupPhysicalStore = rootStore.first?["APFSPhysicalStore"] as? String,
              let grow = plist(["apfs", "list", "-plist", growTarget]) else {
            return rejected("One or more uninstall targets disappeared before execution.")
        }
        let dictionaries = [plist(["info", "-plist", startupPhysicalStore]), stub, efi, linux, recovery].compactMap { $0 }
        let parents = Set(dictionaries.compactMap { $0["ParentWholeDisk"] as? String })
        guard parents.count == 1 else { return rejected("Uninstall targets are not on the same physical disk.") }
        guard growTarget == root["APFSContainerReference"] as? String,
              grow["Containers"] as? [[String: Any]] != nil,
              identifiers(in: root).contains(startupPhysicalStore) else {
            return rejected("The grow target is not the current macOS startup APFS container.")
        }
        guard let startupInfo = dictionaries.first,
              startupInfo["Content"] as? String == "Apple_APFS" else {
            return rejected("The startup physical store is not a resizable APFS partition.")
        }
        guard stub["Content"] as? String == "Apple_APFS",
              let stubContainer = stub["APFSContainerReference"] as? String,
              let containerInfo = plist(["apfs", "list", "-plist", stubContainer]),
              containsCidreVolume(containerInfo) else {
            return rejected("The first target is not a Cidre APFS stub container.")
        }
        let efiName = (efi["VolumeName"] as? String ?? "").uppercased()
        guard efi["Content"] as? String == "EFI", efiName.contains("CIDRE") else {
            return rejected("The EFI target is not labeled for Cidre.")
        }
        guard linux["Content"] as? String == "Linux Filesystem" else {
            return rejected("The selected Linux target has an unexpected partition type.")
        }
        guard recovery["Content"] as? String == "Apple_APFS_Recovery" else {
            return rejected("The selected recovery target is not the old installation recovery partition.")
        }
        guard partitionsAreContiguous(dictionaries) else {
            return rejected("Cidre partitions are not contiguous with the macOS container.")
        }
        // deleteContainer requires an APFS Container Reference (e.g. disk3), not a physical
        // partition slice (e.g. disk0s6). Resolve the container reference from each physical
        // store partition before building the command list.
        // Note: diskutil info for Apple_APFS_Recovery partitions does not include
        // APFSContainerReference, so we look it up from the global APFS container list.
        let recoveryContainer = (recovery["APFSContainerReference"] as? String)
            ?? apfsContainerReference(forPhysicalStore: recoveryTarget)
        guard let recoveryContainer else {
            return rejected("Could not resolve APFS container reference for the recovery partition.")
        }

        let commands = [
            ["/usr/sbin/diskutil", "apfs", "deleteContainer", recoveryContainer],
            ["/usr/sbin/diskutil", "eraseVolume", "free", "free", linuxTarget],
            ["/usr/sbin/diskutil", "eraseVolume", "free", "free", efiTarget],
            ["/usr/sbin/diskutil", "apfs", "deleteContainer", stubContainer],
            ["/usr/sbin/diskutil", "apfs", "resizeContainer", growTarget, "0"],
        ]
        let preview = commands.map { $0.joined(separator: " ") }
        if request.dryRun {
            return Result(status: "pass", summary: "Validated complete Cidre uninstall preview.", exitCode: 0, command: preview, stdout: preview.joined(separator: "\n"), stderr: "")
        }
        var output = ""
        for command in commands {
            let result = run(command)
            output += result.output
            if result.status != 0 {
                return Result(status: "fail", summary: "Cidre uninstall stopped because diskutil failed.", exitCode: result.status, command: preview, stdout: output, stderr: result.error)
            }
        }
        return Result(status: "pass", summary: "Old Cidre partitions were removed and macOS space was restored.", exitCode: 0, command: preview, stdout: output, stderr: "")
    }

    private static func containsCidreVolume(_ value: Any) -> Bool {
        if let dictionary = value as? [String: Any] {
            if let name = dictionary["Name"] as? String, name.lowercased().contains("cidre") { return true }
            return dictionary.values.contains(where: containsCidreVolume)
        }
        if let values = value as? [Any] { return values.contains(where: containsCidreVolume) }
        return false
    }

    private static func partitionsAreContiguous(_ dictionaries: [[String: Any]]) -> Bool {
        var previousEnd: Int64?
        for dictionary in dictionaries {
            guard let offset = (dictionary["PartitionMapPartitionOffset"] as? NSNumber)?.int64Value,
                  let size = (dictionary["Size"] as? NSNumber)?.int64Value else { return false }
            if let previousEnd, offset < previousEnd || offset - previousEnd > 1_048_576 { return false }
            previousEnd = offset + size
        }
        return true
    }

    private static func run(_ command: [String]) -> (status: Int32, output: String, error: String) {
        let process = Process()
        let stdout = Pipe()
        let stderr = Pipe()
        process.executableURL = URL(fileURLWithPath: command[0])
        process.arguments = Array(command.dropFirst())
        process.standardOutput = stdout
        process.standardError = stderr
        do {
            try process.run()
            process.waitUntilExit()
            return (
                process.terminationStatus,
                String(data: stdout.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "",
                String(data: stderr.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            )
        } catch {
            return (1, "", error.localizedDescription)
        }
    }

    private static func validateResize(target: String, containerSize: String, partitionSize: String?) -> String? {
        guard let limits = plist(["apfs", "resizeContainer", target, "limits", "-plist"]),
              let current = (limits["CurrentSize"] as? NSNumber)?.int64Value,
              let preferred = (limits["MinimumSizePreferred"] as? NSNumber)?.int64Value,
              let requested = bytes(from: containerSize) else { return nil }
        if requested < preferred {
            return "Requested container size is below macOS recommended minimum (\(preferred) bytes). Free space and retry."
        }
        if requested > current {
            return "Requested container size exceeds the current APFS physical store size."
        }
        if let partitionSize {
            guard let partitionBytes = bytes(from: partitionSize), partitionBytes > 0 else {
                return "New partition size must be a positive explicit size."
            }
            if requested > current - partitionBytes {
                return "Container and new partition sizes exceed the current physical store size."
            }
        }
        return ""
    }

    private static func bytes(from value: String) -> Int64? {
        if value == "0" { return 0 }
        guard let unit = value.last, let number = Int64(value.dropLast()) else { return nil }
        let multiplier: Int64
        switch String(unit).uppercased() {
        case "B": multiplier = 1
        case "K": multiplier = 1_000
        case "M": multiplier = 1_000_000
        case "G": multiplier = 1_000_000_000
        case "T": multiplier = 1_000_000_000_000
        case "P": multiplier = 1_000_000_000_000_000
        default: return nil
        }
        return number.multipliedReportingOverflow(by: multiplier).overflow ? nil : number * multiplier
    }

    private static func validateTargetStillExists(_ target: String) -> Bool {
        runDiskutil(["info", "-plist", target]).status == 0
    }

    private static func isProtectedForDeletion(_ target: String) -> Bool {
        guard let targetInfo = plist(["info", "-plist", target]),
              let rootInfo = plist(["info", "-plist", "/"]) else { return true }
        let mountPoint = targetInfo["MountPoint"] as? String
        if mountPoint == "/" || mountPoint == "/System/Volumes/Data" { return true }
        let targetUUIDs = identifiers(in: targetInfo)
        let rootUUIDs = identifiers(in: rootInfo)
        if !targetUUIDs.isDisjoint(with: rootUUIDs) { return true }
        let name = ((targetInfo["VolumeName"] as? String) ?? "").lowercased()
        return name.contains("recovery") || name.contains("preboot") || name.contains("vm")
    }

    private static func identifiers(in dictionary: [String: Any]) -> Set<String> {
        let keys = ["DeviceIdentifier", "APFSContainerReference", "APFSVolumeGroupUUID", "VolumeUUID", "ParentWholeDisk"]
        var result = Set(keys.compactMap { dictionary[$0] as? String })
        func collect(_ value: Any) {
            if let nested = value as? [String: Any] {
                for (key, item) in nested {
                    if (keys + ["APFSPhysicalStore"]).contains(key), let identifier = item as? String {
                        result.insert(identifier)
                    }
                    collect(item)
                }
            } else if let items = value as? [Any] {
                items.forEach(collect)
            }
        }
        collect(dictionary)
        return result
    }

    private static func plist(_ arguments: [String]) -> [String: Any]? {
        let result = runDiskutil(arguments)
        guard result.status == 0 else { return nil }
        return (try? PropertyListSerialization.propertyList(from: result.data, options: [], format: nil)) as? [String: Any]
    }

    private static func runDiskutil(_ arguments: [String]) -> (status: Int32, data: Data) {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/diskutil")
        process.arguments = arguments
        process.standardOutput = pipe
        process.standardError = Pipe()
        do {
            try process.run()
            process.waitUntilExit()
            return (process.terminationStatus, pipe.fileHandleForReading.readDataToEndOfFile())
        } catch {
            return (1, Data())
        }
    }

    /// Looks up the APFS container reference (e.g. "disk3") whose physical store matches
    /// the given partition slice (e.g. "disk0s6"). This is necessary because
    /// `diskutil info` does not populate `APFSContainerReference` for every partition type
    /// (e.g. Apple_APFS_Recovery slices).
    private static func apfsContainerReference(forPhysicalStore physicalStore: String) -> String? {
        guard let allContainers = plist(["apfs", "list", "-plist"]),
              let containers = allContainers["Containers"] as? [[String: Any]] else { return nil }
        for container in containers {
            guard let ref = container["ContainerReference"] as? String,
                  let stores = container["PhysicalStores"] as? [[String: Any]] else { continue }
            if stores.contains(where: { ($0["DeviceIdentifier"] as? String) == physicalStore }) {
                return ref
            }
        }
        return nil
    }
}
