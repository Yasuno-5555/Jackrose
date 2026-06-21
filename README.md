# Cidre (v0.25.0 Recovery Screen & Safe Mode Pack)

Cidre is an Apple Silicon Mac-oriented Linux experience layer built on ALARM (Arch Linux ARM) / Asahi Linux.

> [!IMPORTANT]
> **Cidre is not a niri fork.**
> Cidre is a full integration layer that manages installer scripts, configuration deployment, system recovery, sound optimization, and desktop session profiles. The compositor itself is managed under a separate component called `niri-cidre`.

## Project Direction

Cidre is moving from a post-install setup project toward a downstream ALARM/Asahi image for Apple Silicon MacBooks.

The goal is to make Cidre feel less like “install Linux and then run scripts” and more like “install Cidre on your MacBook”.

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
- [v0.25.0 Release Notes](./docs/v0.25.0-recovery-screen-safe-mode.md)
- [v0.26.0 Release Notes](./docs/v0.26.0-rescue-slot-foundation.md)
- [v0.27.0 Release Notes](./docs/v0.27.0-rescue-boot-integration.md)
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
