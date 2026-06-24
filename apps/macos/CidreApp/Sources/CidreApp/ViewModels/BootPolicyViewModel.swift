import Foundation
import Combine
import SwiftUI

/// State of m1n1 bootloader acquisition
enum M1n1State: Equatable {
    case notAcquired
    case downloading
    case acquired(version: String, path: String)
    case failed(reason: String)
}

/// Boot security mode for the Cidre Volume Group
enum SecurityModeState: Equatable {
    case unknown
    case fullSecurity
    case reducedSecurity
    case permissiveSecurity
}

/// How Reduced Security was (or needs to be) configured
enum ReducedSecurityState: Equatable {
    case unknown
    case setViaBputil
    case setViaRecovery
    case manualRecoveryRequired
}

/// Component status for boot chain display
enum ComponentStatus {
    case ready
    case pending
    case missing
    case failed(String)

    var icon: String {
        switch self {
        case .ready: return "checkmark.circle.fill"
        case .pending: return "hourglass"
        case .missing: return "circle"
        case .failed: return "xmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .ready: return .green
        case .pending: return .orange
        case .missing: return .secondary
        case .failed: return .red
        }
    }

    var label: String {
        switch self {
        case .ready: return "Ready"
        case .pending: return "Pending"
        case .missing: return "Not found"
        case .failed(let reason): return "Failed: \(reason)"
        }
    }
}

/// Manages boot policy state: m1n1 acquisition, boot policy creation, security mode verification.
final class BootPolicyViewModel: ObservableObject {
    @Published var m1n1State: M1n1State = .notAcquired
    @Published var securityMode: SecurityModeState = .unknown
    @Published var reducedSecurityState: ReducedSecurityState = .unknown
    @Published var ownerCredentials: OwnerCredentials?
    @Published var isRunning = false
    @Published var lastResult: [String: Any]?
    @Published var summaryText: String = ""
    @Published var guidanceText: String = ""

    /// Boot chain component status
    @Published var m1n1Status: ComponentStatus = .missing
    @Published var kernelStatus: ComponentStatus = .missing
    @Published var initramfsStatus: ComponentStatus = .missing

    /// Whether SSU (Startup Security Utility) interaction is required
    @Published var ssuRequired: Bool = false
    /// Whether the user has confirmed completing SSU Reduced Security setup
    @Published var ssuCompleted: Bool = false
    /// Post-SSU restore state tracking
    @Published var restoreCompleted: Bool = false
    /// Whether Reduced Security was verified via bputil -e
    @Published var reducedSecurityVerified: Bool = false
    /// Whether Cidre is set as default boot for 1TR auto-setup
    @Published var oneTrReady: Bool = false
    /// Whether the automated step2 script is staged on the Cidre volume
    @Published var step2Ready: Bool = false
    /// Path to the step2 script for Recovery Terminal
    @Published var step2Command: String?

    var allComponentsReady: Bool {
        if case .ready = m1n1Status, case .ready = kernelStatus, case .ready = initramfsStatus {
            return true
        }
        return false
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Script Execution Helpers

    /// Build arguments for scripts that need owner credentials
    func credentialArgs() -> [String] {
        guard let creds = ownerCredentials else { return [] }
        return ["--owner-user", creds.username, "--owner-password", creds.password]
    }

    /// Parse a CommandResult-like dictionary from script JSON output
    func parseResult(from jsonString: String?) -> [String: Any]? {
        guard let jsonString, let data = jsonString.data(using: .utf8) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }

    /// Update state from a parsed result dictionary
    func updateFromResult(_ result: [String: Any]?) {
        lastResult = result
        guard let result else { return }

        if let m1n1Installed = result["m1n1_installed"] as? Bool, m1n1Installed {
            let version = result["m1n1_version"] as? String ?? "unknown"
            m1n1State = .acquired(version: version, path: result["m1n1_path"] as? String ?? "")
        }

        if let mode = result["security_mode"] as? String {
            switch mode {
            case "full": securityMode = .fullSecurity
            case "reduced": securityMode = .reducedSecurity
            case "permissive": securityMode = .permissiveSecurity
            default: securityMode = .unknown
            }
        }

        if let reducedStatus = result["reduced_security_status"] as? String {
            switch reducedStatus {
            case "set-via-bputil", "set-via-fork": reducedSecurityState = .setViaBputil
            case "set-via-recovery", "recovery-step2-ready", "one-tr-pending", "one-tr-manual-step2": reducedSecurityState = .setViaRecovery
            case "needs-default-boot": reducedSecurityState = .manualRecoveryRequired
            default: reducedSecurityState = .manualRecoveryRequired
            }
        }

        // Parse 1TR auto-setup (Asahi-style) fields
        if let oneTr = result["one_tr_ready"] as? Bool {
            oneTrReady = oneTr
        }
        // Parse step2 automation fields
        if let step2cmd = result["step2_command"] as? String {
            step2Command = step2cmd
        }
        if let step2rdy = result["step2_ready"] as? Bool {
            step2Ready = step2rdy
        }

        // Parse new SSU/recovery fields
        if let ssuReq = result["ssu_required"] as? Bool {
            ssuRequired = ssuReq
        }
        if let verified = result["reduced_security_verified"] as? Bool, verified {
            reducedSecurityVerified = true
            securityMode = .reducedSecurity
            reducedSecurityState = .setViaRecovery
        }

        summaryText = result["summary"] as? String ?? ""
        guidanceText = result["reduced_security_guide"] as? String ?? ""

        // Update boot chain component status from staged_files
        if let staged = result["staged_files"] as? [String] {
            for file in staged {
                if file.contains("m1n1.macho") || file.contains("boot.efi") {
                    m1n1Status = .ready
                }
                if file.contains("Image") {
                    kernelStatus = .ready
                }
                if file.contains("initramfs") {
                    initramfsStatus = .ready
                }
            }
        }
    }
}
