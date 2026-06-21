# Cidre (v0.18.0 Builder Integration Pack)

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
This remains a developer release intended to ensure robust, repeatable local image building.

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
- [Update Guide](./docs/update.md)
- [Maintenance Guide](./docs/maintenance.md)
- [Recovery Guide](./docs/recovery.md)
- [Diagnostics Guide](./docs/diagnostics.md)
- [Configuration Management Guide](./docs/config-management.md)
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
