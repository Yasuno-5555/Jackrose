# Changelog

All notable changes to the Cidre project will be documented in this file.

## [0.27.0] - 2026-06-21
### Added
- Added rescue boot integration planning.
- Added rescue slot metadata generation.
- Added rescue create dry-run planning.
- Added macOS-side rescue disk audit tooling.
- Added rescue boot guide, report, checklist, and validation recording.
- Added rescue boot threat model documentation.

### Changed
- Extended `install-macos` with rescue planning commands.
- Extended `cidre-doctor` with rescue boot checks.
- Extended `cidre-recovery` with rescue boot subcommands.
- Extended Recovery Screen and Emergency Banner with rescue boot commands.
- Extended boot readiness and boot checklist with rescue boot state.

### Notes
- v0.27.0 is a planning and readiness release.
- It does not create partitions, modify boot entries, or perform destructive disk operations.

## [0.26.0] - 2026-06-21
### Added
- Added Cidre Rescue Slot foundation.
- Added rescue profile metadata.
- Added rescue rootfs artifact flow.
- Added rescue mount, export, kernel-check, and report tools.
- Added rescue documentation.

### Changed
- Extended `cidre-doctor` with `--rescue`.
- Extended `cidre-recovery` with rescue subcommands.
- Extended Recovery Screen and Emergency Banner with Rescue Slot guidance.
- Extended image and rootfs inspection with rescue readiness checks.

### Notes
- v0.26.0 does not create partitions, modify boot entries, or perform destructive disk operations.
- Boot integration is deferred to a future release.

## [0.25.0] - 2026-06-21
### Added
- Added `scripts/cidre-panic`.
- Added `scripts/cidre-recovery-screen`.
- Added `scripts/cidre-safe-mode`.
- Added `scripts/cidre-safe-shell`.
- Added `scripts/cidre-session-failure`.
- Added `scripts/cidre-desktop-failure-detect`.
- Added `scripts/cidre-recovery-actions`.
- Added `scripts/cidre-emergency-banner`.
- Added `scripts/cidre-recovery-report`.
- Added recovery screen and safe mode documentation.
- Added systemd recovery and safe-mode prototypes.

### Changed
- Extended `cidre-doctor` with recovery screen and safe mode checks.
- Extended `cidre-recovery` with recovery screen, panic, actions, and recovery report commands.
- Connected firstboot and first-login failure paths to recovery UX.
- Extended boot log collection with recovery screen state.
- Extended overlay sync and image inspection with recovery assets.

### Notes
- v0.25.0 handles failures where main Cidre can still boot far enough to present a TTY or TUI recovery path.
- Kernel-level boot failure recovery is deferred to a future Rescue Slot.

## [0.24.0] - 2026-06-21
### Added
- Added `scripts/cidre-macos-restore-check`.
- Added `scripts/cidre-macos-partition-audit`.
- Added `scripts/cidre-macos-startup-disk-check`.
- Added `scripts/cidre-macos-uninstall-guide`.
- Added `scripts/cidre-macos-restore-report`.
- Added `scripts/cidre-macos-risk`.
- Added macOS restore assistant documentation.

### Changed
- Extended `install-macos` with restore assistant commands.
- Extended `scripts/cidre-macos-installer` with restore mode dispatch.
- Expanded `scripts/cidre-macos-check --restore-readiness`.
- Added `cidre-doctor --macos-restore`.
- Updated uninstall and exit path documentation.

### Notes
- v0.24.0 is read-only.
- It does not delete partitions, resize APFS containers, or modify startup disk settings.

## [0.23.0] - 2026-06-21
### Added
- Added `scripts/cidre-uninstall-check`.
- Added `scripts/cidre-exit-plan`.
- Added `scripts/cidre-state-export`.
- Added `scripts/cidre-partition-audit`.
- Added `scripts/cidre-macos-restore-guide`.
- Added `scripts/cidre-uninstall-risk`.
- Added `scripts/cidre-goodbye`.
- Added `scripts/cidre-erase-preflight`.
- Added uninstall and exit path documentation.

### Changed
- Added `cidre-doctor --uninstall`.
- Added uninstall and exit path recovery commands.
- Updated boot/build reports with exit path guidance.
- Updated validation matrix and v1.0.0 clean-install test plan with uninstall requirements.
- Added `./install-macos --restore-help` and `scripts/cidre-macos-check --restore-readiness`.

### Notes
- v0.23.0 does not delete partitions or modify macOS boot policy.
- It creates the read-only foundation for a future guided uninstaller.

## [0.22.0] - 2026-06-21
### Added
- Added `scripts/cidre-user-handoff`.
- Added `scripts/cidre-user-phase-state`.
- Added `scripts/cidre-user-phase-verify`.
- Added `scripts/cidre-user-phase-report`.
- Added `scripts/cidre-user-phase-repair`.
- Added `scripts/cidre-first-login`.
- Added docs/user-phase-handoff.md, docs/user-phase-state.md, docs/first-login.md, docs/install-resume-validation.md, and docs/v0.22.0-user-phase-handoff.md.

### Changed
- Extended `cidre-firstboot-handoff` to output machine-readable user-phase handoff states (env and JSON profiles).
- Improved `cidre-installer --resume` preflight checks, failure trapping, and user phase state tracking.
- Updated `cidre-resume` to check schema versions and warn on profile discrepancies.
- Added `cidre-doctor --user-phase` check options.
- Added user phase recovery commands (`user-phase-status`, `user-phase-report`, `user-phase-repair`, `user-handoff`).
- Updated boot log collection and boot test reports to parse user phase metrics directories.
- Updated validation matrix and clean-install test plans.

### Notes
- v0.22.0 focuses on user phase handoff stabilization.
- It does not distribute a public bootable Cidre image.

## [0.21.0] - 2026-06-21
### Added
- Added `scripts/cidre-firstboot-diagnose` to check state directory markers and error logs.
- Added `scripts/cidre-firstboot-retry` to safely reset failures to trigger retries.
- Added `scripts/cidre-firstboot-repair` to clear failed markers and regenerate user handoff files.
- Added `scripts/cidre-firstboot-report` to compile markdown execution reports.
- Added `scripts/cidre-firstboot-console` to print status messages optimized for boot screens.
- Added docs/firstboot-fixup.md, docs/firstboot-service-ordering.md, docs/firstboot-retry-repair.md, and docs/v0.21.0-firstboot-fixup.md.

### Changed
- Improved `scripts/cidre-firstboot-root` stage tracking, failure handling, and completion routines.
- Updated `scripts/cidre-oobe` with visual styling for plain shell fallbacks and improved non-interactive output.
- Extended `scripts/cidre-firstboot-state` with subcommands: clear-failed, clear-retry-requested, mark-retry-requested, set-stage, set-error.
- Updated `scripts/cidre-firstboot-handoff` to include diagnostic recommendations and safer next-step guidance.
- Updated `scripts/cidre-boot-log-collect` to retrieve firstboot diagnostics, unit definitions, and logs.
- Updated `scripts/cidre-boot-failure-classify` with detailed classification subcategories (firstboot-service-missing, firstboot-service-failed, firstboot-state-incomplete, handoff-missing, etc.).
- Updated `scripts/cidre-image-build` to sync the new firstboot scripts into the rootfs overlay.
- Updated `scripts/cidre-doctor` to add `--firstboot-fixup` option and verify all new files in release candidate checks.
- Updated `scripts/cidre-recovery` with subcommands: firstboot-diagnose, firstboot-retry, firstboot-repair, and firstboot-report.
- Adjusted systemd service target ordering in `cidre-firstboot-root.service` to prevent boot hangs when offline.

### Notes
- v0.21.0 focuses on stabilizing the first boot initialization path.
- It does not distribute a public bootable Cidre image.

## [0.20.0] - 2026-06-21
### Added
- Added `scripts/cidre-boot-preflight` to verify files and manifest configurations before boot validation.
- Added `scripts/cidre-controlled-boot-test` high-level orchestrator for preparation, observations, log collections, and reporting.
- Added `scripts/cidre-boot-observe` to log interactive OOBE status.
- Added `scripts/cidre-firstboot-verify` to check firstboot marker files.
- Added `scripts/cidre-boot-result` to write machine-readable JSON status details.
- Added `scripts/cidre-boot-failure-classify` to classify failures into 10 categories.
- Added `scripts/cidre-boot-test-report` to generate execution summaries.
- Added `scripts/cidre-boot-test-clean` to archive active logs directories.
- Added documentation for controlled boot validation, runbooks, firstboot verification, and failure classifications.
- Added `docs/v0.20.0-controlled-boot-test.md` release plan documentation.

### Changed
- Updated `scripts/cidre-boot-checklist` to check preflight parameters and results.
- Updated `scripts/cidre-boot-log-collect` to support state directories parameters.
- Updated `scripts/cidre-image-boot-readiness` to update manifest validation status.
- Updated `scripts/cidre-real-image-build` to route `--prepare-boot-test` logic.
- Updated `scripts/cidre-image-build-report` to include next boot validation parameters.
- Updated `scripts/cidre-doctor` to add `--controlled-boot` and append new files to RC checklists.
- Updated `scripts/cidre-recovery` to add `boot-test-status` subcommand case.
- Updated validation matrices, clean-install test plans, known limitations, and README guides.

### Notes
- v0.20.0 introduces controlled hardware boot validation tooling.
- It does not distribute public bootable images or automate boot policy changes.

## [0.19.0] - 2026-06-21
### Added
- Added `scripts/cidre-real-image-build` high-level orchestrator for full local prototype image builds.
- Added `scripts/cidre-builder-run` low-level execution wrapper for builder invocation.
- Added `scripts/cidre-build-environment` for host build tool validation.
- Added `scripts/cidre-build-failure-report` to generate error diagnostic summaries.
- Added `scripts/cidre-image-register` to register builder output files to state trees.
- Added `scripts/cidre-image-verify` to check checksums and manifest properties.
- Added `scripts/cidre-image-build-report` to write build summaries.
- Added documentation for real image builds, builder runbooks, image register/verify guides, and build failure reporting.
- Added `docs/v0.19.0-real-image-build.md` release plan documentation.

### Changed
- Updated `scripts/cidre-image-build` to support `--real-build` routing logic.
- Updated `scripts/cidre-builder-invoke` to support real execute parameters (`--run`, `--capture-log`, `--exit-code-file`).
- Updated `scripts/cidre-builder-artifacts` to delegate registration flows to `cidre-image-register`.
- Updated `scripts/cidre-image-manifest` to write schema version `0.19.0` with registered image properties.
- Updated `scripts/cidre-image-mount` to reject compressed file paths.
- Updated `scripts/cidre-doctor` to add `--real-build` diagnostics flag and register new files in RC checks.
- Updated `scripts/cidre-recovery` to add `real-build-status` command case.
- Updated validation matrix and v1.0.0 clean-install test plan with real image build requirements.
- Updated known limitations with v0.19.0 constraints.

### Notes
- v0.19.0 introduces real image building and registration paths.
- It does not distribute a public bootable image or guarantee boot success on real hardware.

## [0.18.0] - 2026-06-21
### Added
- Added `scripts/cidre-builder-config` to check and load ALARM image builder workspace options.
- Added `scripts/cidre-builder-integrate` to sync overlays into the builder staging tree.
- Added `scripts/cidre-builder-invoke` to orchestrate build wrapper commands.
- Added `scripts/cidre-builder-log` to parse build compiler logs and output warnings.
- Added `scripts/cidre-builder-artifacts` to scan outputs and register images in state directories.
- Added `scripts/cidre-image-promote` to copy verified prototypes to public targets.
- Added documentation for builder integration, ALARM builder notes, and builder artifacts.
- Added `docs/v0.18.0-builder-integration.md` release plan documentation.

### Changed
- Updated `scripts/cidre-builder-status` to extract git revision metadata and verify wrapper configurations.
- Updated `scripts/cidre-image-manifest` schema version to `0.18.0` with `builder_revision` details.
- Updated `scripts/cidre-image-build` to execute builder config and integration pipelines via `--builder-config`.
- Updated `scripts/cidre-doctor` to add `--builder` audit verification checks.
- Updated `scripts/cidre-recovery` to add `builder-status` subcommand.
- Updated validation matrix and v1.0.0 clean install test plan with builder integration requirements.
- Updated known limitations with v0.18.0 developer constraints.

### Notes
- v0.18.0 completes local integration with the ALARM image builder.
- Target outputs are built and registered locally inside `.local/state/cidre/image-build/`.

## [0.17.0] - 2026-06-21
### Added
- Added `scripts/cidre-builder-status` for ALARM builder / host tool status checks.
- Added `scripts/cidre-image-mount` for read-only rootfs image mounting.
- Added `scripts/cidre-image-unmount` for image unmounting.
- Added `scripts/cidre-rootfs-inspect` for mounted rootfs Cidre component validation.
- Added `scripts/cidre-image-boot-readiness` for aggregate boot readiness checks.
- Added `scripts/cidre-boot-checklist` for boot validation checklist generation.
- Added `scripts/cidre-boot-log-collect` for post-boot log collection.
- Added image boot validation documentation.
- Added rootfs inspection documentation.
- Added boot log collection documentation.
- Added `docs/v0.17.0-image-boot-validation.md` release doc.

### Changed
- Updated `scripts/cidre-image-build`: added `--boot-readiness` and `--builder-status`.
- Updated `scripts/cidre-image-inspect`: delegates `--rootfs` to `cidre-rootfs-inspect`.
- Updated `scripts/cidre-image-manifest`: added boot validation fields; bumped `cidre_version` to `0.17.0`.
- Updated `scripts/cidre-doctor`: added `--boot`; updated `--rc-readiness` with boot validation scripts and docs.
- Updated `scripts/cidre-recovery`: added `boot-status` subcommand.
- Updated validation matrix and v1.0.0 clean install test plan with boot validation requirements.
- Updated known limitations with v0.17.0 constraints.

### Notes
v0.17.0 does not ship a public bootable Cidre image.
It adds the validation tooling needed to move prototype images toward controlled boot testing.

## [0.16.0] - 2026-06-21
### Added
- Added `scripts/cidre-oobe` as the firstboot OOBE front-end.
- Added `scripts/cidre-firstboot-state` for firstboot state management.
- Added `scripts/cidre-firstboot-handoff` for root-to-user phase handoff generation.
- Expanded `scripts/cidre-firstboot-root` from prototype into firstboot orchestration.
- Added `cidre-doctor --firstboot`.
- Added `cidre-recovery firstboot-status`.
- Added firstboot OOBE documentation and security notes.

### Changed
- Updated rootfs overlay synchronization to include firstboot OOBE scripts.
- Updated image inspection to check firstboot OOBE components.
- Updated image manifest features with firstboot OOBE status.
- Updated validation matrix and v1.0.0 clean install test plan with firstboot requirements.

### Notes
- v0.16.0 does not ship a public bootable Cidre image.
- It implements the firstboot OOBE layer intended for future Cidre-controlled images.

## [0.15.0] - 2026-06-21
### Added
- Added prototype image build entrypoint `scripts/cidre-image-build`.
- Added image inspection helper `scripts/cidre-image-inspect`.
- Added image checksum helper `scripts/cidre-image-checksum`.
- Added image manifest generator `scripts/cidre-image-manifest`.
- Added image build cleanup helper `scripts/cidre-image-clean`.
- Added `downstream/image-build/` workspace.
- Added prototype rootfs overlay synchronization flow.
- Added docs for Cidre image prototype and image build validation.
- Added `cidre-doctor --image`.
- Added `cidre-recovery image-status`.

### Changed
- Updated image plan and image build notes for prototype artifact generation.
- Updated validation matrix with image prototype checks.
- Updated known limitations with non-production image status.
- Updated v1.0.0 clean install plan with image requirements.

### Notes
- v0.15.0 does not ship a public Cidre image.
- It establishes a prototype artifact flow for generating and inspecting Cidre rootfs overlay/image contents.

## [0.14.0] - 2026-06-21
### Added
- Added downstream strategy documentation for moving Cidre toward an ALARM/Asahi downstream image.
- Added upstream repository tracking notes.
- Added Cidre image layout plan.
- Added installer integration notes.
- Added firstboot root login problem documentation.
- Added downstream workspace under `downstream/`.
- Added prototype Cidre installer entry example.
- Added rootfs overlay prototype layout.
- Added `scripts/cidre-downstream-check`.
- Added `scripts/cidre-upstream-status`.
- Added `scripts/cidre-image-layout-check`.
- Added `scripts/cidre-installer-metadata-check`.
- Added prototype `scripts/cidre-firstboot-root`.
- Added `systemd/cidre-firstboot-root.service`.
- Added one-shot root autologin example drop-in for future Cidre-controlled images.

### Changed
- Updated README to describe Cidre's downstream image direction.
- Updated known limitations with public image and installer integration status.
- Updated validation matrix with downstream foundation checks.
- Updated v1.0.0 clean install test plan with firstboot OOBE requirements.
- Updated `cidre-doctor --rc-readiness` to include downstream foundation scripts.

### Notes
- v0.14.0 does not ship a public Cidre image.
- It establishes the downstream foundation needed to build one in a future release.

## [0.13.0] - 2026-06-21
### Added
- Added `scripts/cidre-seed` for seed operations.
- Added `scripts/cidre-seed-verify` for validating Cidre seed archives.
- Added `scripts/cidre-seed-import` for importing macOS-generated seed archives into fresh ALARM systems.
- Added `scripts/cidre-resume` for inspecting and using imported resume state.
- Added `./preinstall --import-seed <path>` for root-phase seed import.
- Added `./install --resume` for user-phase profile continuation.
- Added seed/resume state storage under `/var/lib/cidre/`.
- Added `docs/seed-resume.md`.
- Added `docs/v0.13.0-seed-resume.md`.

### Changed
- Updated macOS handoff instructions to include seed import and resume.
- Updated `cidre-doctor --rc-readiness` to check seed/resume commands.
- Updated validation matrix with seed verification, import, and resume tests.
- Updated known limitations to clarify manual seed transfer requirements.

### Notes
- v0.13.0 connects the macOS bootstrap phase to the fresh ALARM setup phase.
- It does not yet provide automatic rootfs seed injection, a Cidre ALARM image, or a GUI installer.

## [0.12.0] - 2026-06-21
### Added
- Added `./install-macos` as the macOS-side Cidre bootstrap entrypoint.
- Added `scripts/cidre-macos-check` for macOS readiness checks.
- Added `scripts/cidre-macos-installer` for interactive macOS-side bootstrap flow.
- Added `scripts/cidre-macos-seed` for generating Cidre install manifests.
- Added `scripts/cidre-macos-handoff` for ALARM/Asahi installer handoff guidance.
- Added macOS installation documentation.
- Added installer threat model documentation.
- Added macOS-to-Cidre flow documentation.

### Changed
- Updated README installation flow to distinguish macOS, root-phase, and user-phase entrypoints.
- Updated validation matrix with macOS bootstrap checks.
- Updated known limitations to clarify that v0.12.0 does not provide full automatic ALARM installation.

### Notes
- v0.12.0 introduces the first macOS-side entrypoint for Cidre.
- It does not yet provide a custom Cidre ALARM image, automatic rootfs seed injection, or a GUI installer.

## [0.11.0] - 2026-06-21
### Added
- Guided `./preinstall` dashboard/wizard mode with backend selection across `dialog`, `whiptail`, and plain shell fallback.
- Root-phase setup status dashboard covering system, Apple Silicon hints, network, pacman, user, sudo, tools, next step, and preinstall log paths.
- Guided user selection/creation, wheel/sudo setup, isolated sudoers validation, and final root-to-user handoff output.
- Root-phase preinstall state logging under `~/.local/state/cidre/preinstall/` with `preinstall.log`, `last-check.log`, and `last-status`.

### Changed
- `cidre-doctor --base-readiness` terminology now aligns with preinstall readiness checks and points back to the root-phase entrypoint.
- Root execution failure path in `./install` now redirects to `./preinstall` and `cidre-doctor --base-readiness --summary`.
- `cidre-preinstall` package metadata now documents optional `dialog` and `whiptail` backends.

## [0.10.0] - 2026-06-21
### Added
- Root-phase helper utility `preinstall` (backed by `scripts/cidre-preinstall`) managing package sync, base utilities sync (`git`, `curl`, `sudo`, `base-devel`), sudo/wheel configuration validation, and normal user account verification.
- Intercept and guidance redirection pointing root execution attempts on `./install` to run `./preinstall --prepare` first.
- Pre-install base setup diagnostics flag `cidre-doctor --base-readiness` verifying network link, DNS lookups, system clock sanity, filesystem permissions, disk space, and Asahi platform hints.
- Consolidated guide for fresh ALARM base environment setups under `docs/base-install.md` and release notes under `docs/v0.10.0-base-install-simplification.md`.

## [0.9.0] - 2026-06-21
### Added
- Release candidate diagnostics check-suite inside `cidre-doctor --rc-readiness` auditing local tree command files, docs, global path statuses, and state structures.
- Release candidate installer validation dry-run `install --rc-dry-run` compiling all profile and doctor tests in a single simulation sweep.
- Consolidated documentation references for commands, profiles, package ownership, managed files, validation matrix, known limitations, and the v1.0.0 clean-install test plan.

## [0.8.0] - 2026-06-21
### Added
- Integrated update controller script `cidre-update` supporting `--check`, `--dry-run`, `--apply`, and `--doctor`.
- Everyday maintenance console `cidre-maintenance` supporting `status`, `prune`, `drift`, and `logs`.
- New diagnostic check-suite inside `cidre-doctor --maintenance` covering state, manifest, log health, and configuration drift.
- Enhanced snapshot pruning in `cidre-snapshot` supporting `--older-than` cutoff and interactive deletion prompts.
- Integration updates in firstboot diagnostic audits, welcome banners, and guided installers.
- Independent packaging definitions for `cidre-update` and `cidre-maintenance` packages under `packages/arch`.

## [0.7.0] - 2026-06-21
### Added
- Dedicated snapshot utility command `cidre-snapshot` for configuration backups.
- Automatic configuration pre-apply snapshot hooks inside `cidre-user-setup`.
- Rollback and history subcommands to `cidre-user-setup`.
- Extended `cidre-recovery` to run snapshots listings and rollback restores.
- Saved diagnostic execution runs, with parameters `--last`, `--history`, and `--fix-suggestions` in `cidre-doctor`.

## [0.6.0] - 2026-06-21
### Added
- Sane keybindings for window and workspace navigation (Super + Enter for Ghostty).
- Waybar native wireplumber audio volume and battery indicators.
- Sane Print Screen key bindings for Grim/Slurp screenshot flows.
- Extended volume, mute, unmute, and restart actions to `cidre-audio`.
- Daily diagnostics `--daily` verification flag in `cidre-doctor`.

## [0.5.0] - 2026-06-21
### Added
- Root-level `./install` entrypoint.
- `cidre-installer` guided interactive CLI manager.
- `desktop`, `developer`, `minimal`, and `recovery` installation profiles.
- `cidre-firstboot` first-boot verification helper script and package.
- Onboarding documentation.
- Integrated post-install check markers and installation logging.

## [0.4.0] - 2026-06-21
### Added
- `--check` and `--dry-run` modes to `bootstrap.sh`.
- `cidre-doctor` health diagnostics command.
- `cidre-diagnostics` Arch package definition.
- `doctor`, `list`, and `restore` subcommands to `cidre-recovery`.
- `check-packages` package verification script.
- `verify` and `list` subcommands to `cidre-user-setup`.
- Complete documentation guides for installation, recovery, and diagnostics.

## [0.3.0] - 2026-06-21
### Added
- Unified Catppuccin Mocha theme configuration for Waybar, Ghostty, and fuzzel.
- Premium abstract desktop wallpaper asset and `cidre-wallpapers` package.
- Systemd user service `fcitx5.service` to manage Japanese Mozc inputs.
- First-login dashboard CLI command `cidre-welcome`.
- Python-based configuration setup manager `cidre-user-setup` with backups and profile levels.

## [0.2.0] - 2026-06-21
### Added
- Automated `bootstrap.sh` script to install packages, localectl keymaps, and configure `greetd`.
- Core recovery tool `cidre-recovery` and audio profile settings `cidre-audio`.
- Updated package templates for `niri-cidre` remote fetch.

## [0.1.0] - 2026-06-20
### Added
- Initial proof-of-concept monorepo.
- ALARM minimal desktop boots on niri compositors.
