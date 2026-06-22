# Cidre (v0.35.6 Controlled Manual-Boot Install Pack)

Cidre is an Apple Silicon Mac-oriented Linux experience layer built on ALARM (Arch Linux ARM) / Asahi Linux.

This repository contains the Cidre environment, including installer, recovery, rescue tooling, documentation, package metadata, and the `niri-cidre` desktop layer.

The launchable macOS installer is [`dist/Cidre.app`](dist/Cidre.app). It provides a setup wizard with APFS inspection, validated partition planning, an administrator-authenticated disk helper, packaged backend resources, and operation logs. Disk mutations now sit behind DFU incident containment and remain disabled by default.

> [!WARNING]
> Cidre is experimental and currently not safe for general installation.
> A recent GUI install flow caused a pre-m1n1 / Apple Recovery-level boot failure on Apple Silicon hardware.
> Do not run disk-changing installer flows on a machine you cannot erase and DFU restore.

Current safety status:

```text
Disk-changing install flows are disabled by default after DFU_RESTORE_001.
Boot survivability checks must pass before install completion can be considered safe.
Cidre does not register itself as the default boot target.
```

## Current Disk Safety Status

Cidre.app currently keeps disk-changing install flows disabled by default.

v0.35.2 adds disk snapshot, APFS snapshot, protected Apple partition guard,
pre/post disk diff, fixture validation, and recovery survival checks. These
checks are required before destructive installer flows can ever be re-enabled.

v0.35.3 promotes those checks into enforced gate conditions for helper
execution, wizard progression, finish, restart, and shutdown.

v0.35.6 adds controlled manual-boot install planning, payload verification,
and an explicit no-default-boot mutation policy. Payload staging is separated
from boot registration, and Cidre does not set itself as the default startup
disk.

> [!IMPORTANT]
> **Cidre is not a niri fork.**
> `niri-cidre` is the desktop/compositor component shipped as part of Cidre. It is not the whole project. Cidre itself is a full integration layer that manages installer scripts, configuration deployment, system recovery, sound optimization, and desktop session profiles.

## Project Direction

Cidre is moving from a post-install setup project toward a downstream ALARM/Asahi image for Apple Silicon MacBooks.

The goal is to make Cidre feel less like "install Linux and then run scripts" and more like "install Cidre on your MacBook".

## Image Prototype Status

Cidre v0.15.0 introduces the first prototype image artifact flow.

This does not mean Cidre ships a public installable image yet.
The goal is to generate and inspect prototype rootfs artifacts containing Cidre firstboot, seed/resume, and downstream overlay components.

## Firstboot OOBE Status

Cidre v0.16.0 introduces the firstboot OOBE layer for future Cidre-controlled images.

The goal is to avoid requiring users to know default ALARM credentials such as `root/root`.
This is not a public boot-validated image yet, but it establishes the firstboot setup path used by future Cidre images.

## Boot Validation Status

Cidre v0.17.0 adds image boot validation tooling.

This includes rootfs inspection, boot readiness checks, boot checklists, and boot log collection helpers.
It still does not mean Cidre ships a public bootable image.

## Builder Integration Status

Cidre v0.18.0 integrates the boot validation layer and rootfs overlay trees with the ALARM image builder, tracking configurations, logs, and output registration.

## Real Image Build Status

Cidre v0.19.0 introduces the first local real image build flow. It supports executing the ALARM image builder, staging custom configurations, registering produced prototype images into local state directories, verifying checksums/manifests, and generating markdown build/failure reports.
This remains a developer release intended to ensure robust, repeatable local image building.

## Controlled Boot Test Status

Cidre v0.20.0 introduces controlled boot testing orchestration on Apple Silicon Macs, supporting observations checklist tracking, boot logs collection, failure classification, and test result reports.

## Firstboot Fixup Status

Cidre v0.21.0 improves firstboot stability, retry, repair, diagnosis, and reporting.
This makes the prototype image firstboot path easier to validate and recover, but it still does not mean Cidre ships a public production image.

## User Phase Handoff Status

Cidre v0.22.0 adds user phase handoff validation and state tracking.
This improves the transition from firstboot root setup to `./install --resume` as the normal user.
It does not yet mean the full desktop profile is production-ready.

## Exit Path First

Cidre v0.23.0 adds uninstall readiness checks, state export, partition audit reports, and macOS restore guide generation.
This release does not perform destructive disk operations.

## macOS Restore Assistant

Cidre v0.24.0 adds macOS-side restore readiness checks.
It can collect read-only disk layout information, generate uninstall guides, and report restore risk from macOS.
It does not delete partitions or resize APFS containers.

## Recovery Screen and Safe Mode

Cidre is designed to fail visibly.

If the normal desktop session cannot start, Cidre can show a recovery screen
with actions for safe shell, doctor checks, state export, exit plan generation,
and macOS restore guidance.

v0.25.0 does not repair kernel-level boot failures.
Those require a future Rescue Slot or macOS-side restore path.

## Rescue Slot foundation

Cidre v0.26.0 introduces the foundation for a separate minimal rescue environment.

The Rescue Slot is intended for cases where the main Cidre install no longer boots
far enough to show the Recovery Screen.

v0.26.0 does not create partitions or modify boot entries automatically.

## Rescue Boot Integration

Cidre v0.27.0 adds rescue boot integration planning.

It can generate rescue slot plans, metadata, dry-run creation reports,
macOS-side rescue disk audits, and validation checklists.

This release does not create partitions, modify boot entries, or install a fully bootable Rescue Slot.

## Guided Rescue Slot creation

Cidre v0.28.0 can create a Rescue Slot on an explicitly selected prepared target.

Creation is guided and defaults to dry-run.
Real creation requires an exact target, a rescue artifact, Cidre state export,
and an explicit confirmation phrase.

This release does not automatically create partitions, resize APFS containers,
or modify boot entries.

## Fully Guided Installer

Cidre v0.29.0 introduces a guided installer flow.

The installer tracks install stages from macOS preparation through ALARM root phase, user phase, firstboot, and desktop verification.

It provides dashboards, handoff instructions, resume commands, and install reports.

This release does not automatically resize macOS/APFS containers or create partitions.

## Fully Guided Uninstaller

Cidre v0.30.0 introduces a guided uninstall flow.

The uninstaller requires state export before deletion planning, scans and reviews delete targets, blocks protected targets, generates dry-run plans, and connects to the macOS Restore Assistant.

This release does not perform automatic destructive disk operations by default.

## App-ready command interface

Cidre v0.31.0 introduces an app-ready command interface.

Guided installer, uninstaller, recovery, and report commands now expose machine-readable output, predictable exit codes, noninteractive modes, and versioned interface metadata for future integration with Cidre.app.

## Cidre.app prototype

Cidre v0.32.0 introduces the first macOS app prototype.

The prototype reads the app-ready command interface added in v0.31.0 and displays dashboards, actions, reports, and command results in a SwiftUI-based interface.

This release does not perform destructive disk operations and does not include a privileged helper.

## Cidre.app guided action UI

Cidre v0.33.0 extends the macOS app prototype with a guided action UI.

The app can select a Cidre repository, read interface metadata, display install
and uninstall actions, run safe read-only commands, display JSON results, preview
reports, and keep an execution log.

Destructive install/uninstall operations remain blocked.

## Cidre.app runtime validation

Cidre v0.34.0 adds runtime validation tooling for the macOS app prototype.

The goal is to verify build, launch readiness, repository selection, safe read-only command execution, report preview, and blocked destructive action display on a real macOS machine.

## Installation Flow

Cidre has three phases.

### 1. macOS phase

```sh
git clone https://github.com/Yasuno-5555/Cidre
cd Cidre
./install-macos --profile developer
```

This creates a Cidre seed:

```text
.local/state/cidre/macos-bootstrap/cidre-seed.tar.gz
```

`./install-macos` does not directly install ALARM or modify APFS containers. It prepares the Cidre-side bootstrap flow and hands off to the ALARM/Asahi installer.

### 2. fresh ALARM root phase

After installing ALARM and booting into the fresh system, copy the seed into the ALARM environment and run:

```bash
./preinstall --import-seed /path/to/cidre-seed.tar.gz
```

`./preinstall` can import the macOS-generated seed, verify it, store it under `/var/lib/cidre/`, and continue with the root-phase setup flow.

### 3. ALARM user phase

After switching to the normal user, resume the Cidre setup:

```bash
./install --resume
```

## Documentation Guides

- [Guided Onboarding](./docs/onboarding.md)
- [Installing Cidre from macOS](./docs/macos-install.md)
- [macOS to Cidre Flow](./docs/macos-to-cidre-flow.md)
- [Installer Threat Model](./docs/installer-threat-model.md)
- [Seed & Resume](./docs/seed-resume.md)
- [Downstream Strategy](./docs/downstream-strategy.md)
- [ALARM Fork Strategy](./docs/alarm-fork-strategy.md)
- [Cidre Image Plan](./docs/cidre-image-plan.md)
- [Cidre Image Prototype](./docs/cidre-image-prototype.md)
- [Installer Integration](./docs/installer-integration.md)
- [Image Build Notes](./docs/image-build-notes.md)
- [Image Build Validation](./docs/image-build-validation.md)
- [Firstboot OOBE](./docs/firstboot-oobe.md)
- [Firstboot Fixup](./docs/firstboot-fixup.md)
- [Firstboot Service Ordering](./docs/firstboot-service-ordering.md)
- [Firstboot Retry & Repair](./docs/firstboot-retry-repair.md)
- [User Phase Handoff](./docs/user-phase-handoff.md)
- [User Phase State](./docs/user-phase-state.md)
- [First Login](./docs/first-login.md)
- [Install Resume Validation](./docs/install-resume-validation.md)
- [Uninstall Guide](./docs/uninstall.md)
- [Exit Path](./docs/exit-path.md)
- [State Export](./docs/state-export.md)
- [Partition Audit](./docs/partition-audit.md)
- [macOS Restore Guide](./docs/macos-restore-guide.md)
- [macOS Restore Assistant](./docs/macos-restore-assistant.md)
- [macOS Partition Audit](./docs/macos-partition-audit.md)
- [macOS Startup Disk Check](./docs/macos-startup-disk.md)
- [macOS Uninstall Guide](./docs/macos-uninstall-guide.md)
- [Uninstall Threat Model](./docs/uninstall-threat-model.md)
- [Recovery Screen](./docs/recovery-screen.md)
- [Safe Mode](./docs/safe-mode.md)
- [Failure Levels](./docs/failure-levels.md)
- [TTY Recovery](./docs/tty-recovery.md)
- [Recovery Shortcuts](./docs/recovery-shortcuts.md)
- [Rescue Slot](./docs/rescue-slot.md)
- [Rescue Profile](./docs/rescue-profile.md)
- [Rescue Image](./docs/rescue-image.md)
- [Rescue Mount](./docs/rescue-mount.md)
- [Rescue Kernel Check](./docs/rescue-kernel-repair.md)
- [Rescue Threat Model](./docs/rescue-threat-model.md)
- [Rescue Boot Integration](./docs/rescue-boot-integration.md)
- [Rescue Slot Layout](./docs/rescue-slot-layout.md)
- [Rescue Boot Metadata](./docs/rescue-boot-metadata.md)
- [Rescue Boot Validation](./docs/rescue-boot-validation.md)
- [macOS Rescue Slot Planning](./docs/macos-rescue-slot.md)
- [Rescue Boot Threat Model](./docs/rescue-boot-threat-model.md)
- [Guided Rescue Slot Creation](./docs/rescue-create.md)
- [Rescue Target Selection](./docs/rescue-target-selection.md)
- [Rescue Creation Safety](./docs/rescue-create-safety.md)
- [Rescue Rootfs Deployment](./docs/rescue-rootfs-deployment.md)
- [macOS Rescue Create](./docs/macos-rescue-create.md)
- [Rescue Create Threat Model](./docs/rescue-create-threat-model.md)
- [Firstboot Security](./docs/firstboot-security.md)
- [Firstboot Root Login Problem](./docs/firstboot-root-login-problem.md)
- [Fresh ALARM Base Setup](./docs/base-install.md)
- [Installation Guide (Advanced)](./docs/installation.md)
- [Stable Commands Reference](./docs/commands.md)
- [Installation Profiles](./docs/profiles.md)
- [Package Ownership Index](./docs/packages.md)
- [Managed Files Inventory](./docs/managed-files.md)
- [Validation Matrix](./docs/validation-matrix.md)
- [Known Limitations](./docs/known-limitations.md)
- [v1.0.0 Clean-Install Test Plan](./docs/v1.0.0-clean-install-test-plan.md)
- [Builder Integration](./docs/builder-integration.md)
- [ALARM Builder Notes](./docs/alarm-builder-notes.md)
- [Builder Artifacts](./docs/builder-artifacts.md)
- [Real Image Build](./docs/real-image-build.md)
- [Builder Runbook](./docs/builder-runbook.md)
- [Image Register & Verify](./docs/image-register-verify.md)
- [Build Failure Report](./docs/build-failure-report.md)
- [Update Guide](./docs/update.md)
- [Maintenance Guide](./docs/maintenance.md)
- [Recovery Guide](./docs/recovery.md)
- [Diagnostics Guide](./docs/diagnostics.md)
- [Configuration Management Guide](./docs/config-management.md)
- [v0.23.0 Release Notes](./docs/v0.23.0-uninstall-exit-path.md)
- [v0.24.0 Release Notes](./docs/v0.24.0-macos-restore-assistant.md)
- [v0.30.0 Release Notes](./docs/v0.30.0-fully-guided-uninstaller.md)
- [v0.31.0 Release Notes](./docs/v0.31.0-app-ready-command-interface.md)
- [v0.32.0 Release Notes](./docs/v0.32.0-cidre-app-prototype.md)
- [v0.33.0 Release Notes](./docs/v0.33.0-cidre-app-guided-action-ui.md)
- [v0.34.0 Release Notes](./docs/v0.34.0-cidre-app-runtime-validation.md)
- [Cidre.app Prototype](./docs/cidre-app-prototype.md)
- [Cidre.app Architecture](./docs/cidre-app-architecture.md)
- [Cidre.app UI Flow](./docs/cidre-app-ui-flow.md)
- [Cidre.app Backend Bridge](./docs/cidre-app-backend-bridge.md)
- [Cidre.app Safety Model](./docs/cidre-app-safety-model.md)
- [Cidre.app Guided Action UI](./docs/cidre-app-guided-action-ui.md)
- [Cidre.app Runtime Validation](./docs/cidre-app-runtime-validation.md)
- [Cidre.app Build Validation](./docs/cidre-app-build-validation.md)
- [Cidre.app Launch Validation](./docs/cidre-app-launch-validation.md)
- [Cidre.app Runtime Report](./docs/cidre-app-runtime-report.md)
- [Cidre.app Runtime Known Issues](./docs/cidre-app-runtime-known-issues.md)
- [Cidre.app Command Execution](./docs/cidre-app-command-execution.md)
- [Cidre.app Repository Selection](./docs/cidre-app-repository-selection.md)
- [Cidre.app Execution Log](./docs/cidre-app-execution-log.md)
- [Cidre.app Read-Only Safety Policy](./docs/cidre-app-read-only-policy.md)
- [v0.25.0 Release Notes](./docs/v0.25.0-recovery-screen-safe-mode.md)
- [v0.26.0 Release Notes](./docs/v0.26.0-rescue-slot-foundation.md)
- [v0.27.0 Release Notes](./docs/v0.27.0-rescue-boot-integration.md)
- [v0.28.0 Release Notes](./docs/v0.28.0-guided-rescue-slot-creation.md)
- [v0.22.0 Release Notes](./docs/v0.22.0-user-phase-handoff.md)
- [v0.21.0 Release Notes](./docs/v0.21.0-firstboot-fixup.md)
- [v0.20.0 Release Notes](./docs/v0.20.0-controlled-boot-test.md)
- [v0.19.0 Release Notes](./docs/v0.19.0-real-image-build.md)
- [v0.18.0 Release Notes](./docs/v0.18.0-builder-integration.md)
- [v0.17.0 Release Notes](./docs/v0.17.0-image-boot-validation.md)
- [v0.16.0 Release Notes](./docs/v0.16.0-firstboot-oobe.md)
- [v0.15.0 Release Notes](./docs/v0.15.0-cidre-image-prototype.md)
- [v0.13.0 Release Notes](./docs/v0.13.0-seed-resume.md)
- [v0.14.0 Release Notes](./docs/v0.14.0-downstream-foundation.md)
- [v0.12.0 Release Notes](./docs/v0.12.0-macos-bootstrap.md)
- [v0.11.0 Release Notes](./docs/v0.11.0-base-setup-tui.md)
- [v0.10.0 Release Notes](./docs/v0.10.0-base-install-simplification.md)
- [v0.9.0 Release Notes](./docs/v0.9.0-rc-readiness.md)
- [v0.8.0 Release Notes](./docs/v0.8.0-update-maintenance.md)
- [v0.7.0 Release Notes](./docs/v0.7.0-stability-rollback.md)
- [v0.6.0 Release Notes](./docs/v0.6.0-daily-driver-polish.md)
- [v0.5.0 Release Notes](./docs/v0.5.0-guided-onboarding.md)
