import SwiftUI

struct BootPolicyStepView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @ObservedObject var wizardVM: SetupWizardViewModel

    var body: some View {
        WizardStepContainerView(
            title: "Boot Policy",
            bodyText: "Register Cidre in the Mac's Startup Options. This requires your macOS owner password to authorize the boot policy creation."
        ) {
            VStack(alignment: .leading, spacing: 16) {
                // Owner credentials
                GroupBox("Owner Authentication") {
                    VStack(alignment: .leading, spacing: 8) {
                        if wizardVM.ownerCredentials != nil {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.shield.fill")
                                    .foregroundColor(.green)
                                Text("Owner credentials provided for bless/bputil")
                                    .font(.callout)
                            }
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.shield.fill")
                                    .foregroundColor(.orange)
                                Text("Owner credentials required. Go back to Privileged Preparation to enter them.")
                                    .font(.callout)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Boot policy status
                if let result = bootPolicyVM.lastResult {
                    GroupBox("Boot Policy Result") {
                        VStack(alignment: .leading, spacing: 8) {
                            StatusRow(
                                label: "Status",
                                value: result["status"] as? String ?? "unknown"
                            )
                            if let summary = result["summary"] as? String {
                                Text(summary)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            if let vgUUID = result["volume_group_uuid"] as? String, !vgUUID.isEmpty {
                                StatusRow(label: "Volume Group UUID", value: vgUUID)
                            }
                            if let stepsCompleted = result["steps_completed"] as? String {
                                StatusRow(label: "Steps completed", value: stepsCompleted)
                            }
                            if let stepsFailed = result["steps_failed"] as? String {
                                StatusRow(label: "Steps failed", value: stepsFailed)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // 1TR Auto-Run setup guidance (Asahi-style: Cidre is default boot → auto-boots into 1TR)
                if bootPolicyVM.oneTrReady && bootPolicyVM.step2Ready {
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.triangle.branch")
                                    .foregroundColor(.blue)
                                Text("Automatic Setup Ready — Restart Now")
                                    .font(.headline)
                            }

                            Text("Cidre is set as the default boot. On restart, your Mac will automatically boot into the Cidre setup environment (1TR — One True Recovery) using an Apple-signed kernelcache. Setup completes in 1–2 minutes, then your Mac restarts back to macOS. No manual steps needed.")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Divider()

                            VStack(alignment: .leading, spacing: 8) {
                                StepView(number: 1, icon: "arrow.triangle.2.circlepath", title: "Restart your Mac", detail: "Apple menu → Restart (save your work first)")
                                StepView(number: 2, icon: "gearshape.2", title: "Setup runs automatically", detail: "bputil sets Reduced Security, kmutil installs m1n1 (--raw --entry-point 2048) as custom boot object")
                                StepView(number: 3, icon: "arrow.uturn.backward", title: "Mac restarts to macOS", detail: "Setup restores macOS as default and reboots")
                                StepView(number: 4, icon: "hand.tap", title: "Hold power button to boot Cidre", detail: "From now on, Cidre appears in Startup Options → Linux boots!")
                            }

                            Divider()

                            Text("This is the same approach used by the Asahi Linux installer (asahi-alarm reference). Cidre is default boot for ONE reboot only — during that boot, bputil sets Reduced Security and kmutil installs m1n1 (entry-point 2048, matching Asahi's boot.bin layout). macOS is restored as default automatically after setup.")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            if !bootPolicyVM.ssuCompleted {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        wizardVM.markSsuCompleted(repositoryPath: appVM.repositoryPath)
                                    }) {
                                        Label("I have restarted and setup completed", systemImage: "checkmark.circle")
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.blue)
                                    .controlSize(.large)
                                    Spacer()
                                }
                            } else {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                    Text("Proceeding to verification...").font(.caption)
                                }
                            }
                        }
                        .padding(8)
                    }
                }

                // 1TR pending but step2 not fully staged (Cidre IS default boot, user needs to run step2 manually)
                if bootPolicyVM.oneTrReady && !bootPolicyVM.step2Ready {
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "terminal")
                                    .foregroundColor(.orange)
                                Text("1TR Recovery Setup")
                                    .font(.headline)
                            }

                            Text("Cidre is set as default boot. On restart, your Mac will boot into the Cidre recovery environment. Open Terminal (Utilities → Terminal) and run the step2 script to complete setup.")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            if let step2Cmd = bootPolicyVM.step2Command, !step2Cmd.isEmpty {
                                Text("Run: \(step2Cmd)")
                                    .font(.caption.monospaced())
                                    .padding(8)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(6)
                            }

                            Text("After step2 completes, your Mac restarts to macOS and Cidre appears in Startup Options.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(8)
                    }
                }

                // SSU guidance (fallback when 1TR not ready and no step2 automation)
                if !bootPolicyVM.oneTrReady && !bootPolicyVM.step2Ready {
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("One More Step: Enable Reduced Security")
                                    .font(.headline)
                            }

                            Text("Your Mac uses Full Security, which requires Apple-signed bootloaders. To allow Cidre's unsigned bootloader (m1n1), you must enable Reduced Security from macOS Recovery.")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Divider()

                            // Embedded step-by-step guide
                            ReducedSecurityGuidanceView()

                            Divider()

                            if !bootPolicyVM.ssuCompleted {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        wizardVM.markSsuCompleted(repositoryPath: appVM.repositoryPath)
                                    }) {
                                        Label("I have set Reduced Security — Continue", systemImage: "checkmark.circle")
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.blue)
                                    .controlSize(.large)
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                            } else {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("SSU completed. Proceeding to verification...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(8)
                    }
                }

                // Fallback: no 1TR and no step2 — show manual guidance
                if !bootPolicyVM.oneTrReady, !bootPolicyVM.step2Ready,
                    !bootPolicyVM.ssuCompleted,
                    case .manualRecoveryRequired = bootPolicyVM.reducedSecurityState {
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.orange)
                                Text("Boot policy needs owner authentication.")
                                    .font(.callout)
                            }
                            Text("Go back to Privileged Preparation, enter your macOS credentials, then return here and run the Boot Policy operation.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(8)
                    }
                }

                // Success: Reduced Security is configured
                if case .reducedSecurity = bootPolicyVM.securityMode {
                    GroupBox {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(.green)
                            Text("Reduced Security is configured. Cidre is ready to boot.")
                                .font(.callout)
                        }
                        .padding(8)
                    }
                }
            }
        }
    }

    private var bootPolicyVM: BootPolicyViewModel {
        wizardVM.bootPolicyVM
    }
}

// MARK: - Status Row

fileprivate struct StatusRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(2)
        }
    }
}
