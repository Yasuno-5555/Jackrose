# Cidre Command Reference

This document catalogs all stable command line utilities provided by the Cidre desktop layer.

## User-Facing Commands

### `./install-macos`
The macOS-side bootstrap entrypoint for Apple Silicon onboarding.
* `--check`: Runs macOS readiness checks only.
* `--dry-run`: Previews profile selection, seed generation, and handoff steps without writing files.
* `--profile <name>`: Selects `desktop`, `developer`, `minimal`, or `recovery`.
* `--no-seed`: Skips manifest generation.
* `--print-handoff`: Prints ALARM/Asahi installer continuation guidance only.
* `--restore-help`: Prints v0.23.0 restore and removal guidance only.
* `--restore-check`: Runs macOS-side restore readiness checks.
* `--partition-audit`: Collects a read-only macOS partition audit.
* `--startup-disk-check`: Generates startup disk guidance.
* `--uninstall-guide`: Generates a macOS uninstall guide.
* `--restore-report`: Generates a macOS restore report.
* `--rescue-help`: Prints Rescue Slot guidance only.
* `--rescue-check`: Runs macOS-side Rescue Slot readiness checks.
* `--rescue-disk-audit`: Collects a read-only macOS rescue disk audit.
* `--rescue-plan`: Generates a macOS rescue plan.
* `--rescue-guide`: Generates a macOS rescue guide.
* `--rescue-report`: Generates a macOS rescue report.
* `--rescue-create-dry-run`: Prints rescue creation dry-run guidance.

### `scripts/cidre-seed`
The Linux-side seed command wrapper.
* `verify <seed.tar.gz>`: Validates archive structure, manifest metadata, checksum, and profile values.
* `import <seed.tar.gz>`: Imports a verified seed into `/var/lib/cidre/`.
* `status`: Shows whether imported resume state exists.
* `show`: Prints a seed/resume summary.

### `scripts/cidre-resume`
Reads imported resume state from `/var/lib/cidre/resume/`.
* `status`: Reports whether resume state exists and whether a user-level apply record exists.
* `show`: Prints profile, install mode, and source commit summary.
* `profile`: Prints the imported profile name for installer reuse.

### `scripts/cidre-downstream-check`
Checks whether the downstream foundation files, docs, units, and skeleton directories exist.

### `scripts/cidre-upstream-status`
Inspects local downstream fork/reference repositories using configured environment variables.

### `scripts/cidre-image-layout-check`
Validates the rootfs overlay prototype structure under `downstream/rootfs-overlay/`.

### `scripts/cidre-installer-metadata-check`
Validates the prototype installer entry example as JSON when `python3` is available.

### `scripts/cidre-firstboot-root`
Root-phase firstboot OOBE orchestration entrypoint intended for future Cidre-controlled images.

### `scripts/cidre-oobe`
Firstboot OOBE front-end with pure shell fallback and optional dialog/whiptail backends.

### `scripts/cidre-firstboot-state`
Reads and writes firstboot state markers, selected user/profile, and handoff output.

### `scripts/cidre-firstboot-handoff`
Generates root-to-user handoff instructions for the user-phase installer.

### `scripts/cidre-image-build`
Builds prototype Cidre image artifacts and overlay tarballs.

### `scripts/cidre-image-inspect`
Inspects an overlay directory, overlay tarball, or mounted rootfs path for required Cidre image content.

### `scripts/cidre-image-checksum`
Writes a `.sha256` checksum file for a generated prototype artifact.

### `scripts/cidre-image-manifest`
Generates the prototype image manifest JSON describing source, builder path, artifacts, and validation state.

### `scripts/cidre-image-clean`
Removes `.local/state/cidre/image-build/` after explicit confirmation.

### `./preinstall` / `cidre-preinstall`
The root-phase base system helper.
* `--tui`: Forces the guided dashboard/wizard mode.
* `--check`: Audits base system packages and connections.
* `--dry-run`: Previews setup actions.
* `--prepare`: Installs core dependencies and configures wheel-sudo users.
* `--import-seed <path>` / `--seed <path>`: Verifies and imports a macOS-generated seed before root-phase continuation.
* `--no-seed`: Ignores seed/resume integration.
* `--non-interactive`: Forces plain output without interactive prompts.
* `--user <name>`: Pins the target normal user for verification or creation.
* `--yes`: Auto-confirms prompts.

### `./install` / `cidre-installer`
The guided interactive orchestration installer.
* `--check`: Runs compatibility checks on commands and packages.
* `--dry-run`: Simulates the system bootstrap and configuration deploy.
* `--profile <name>`: Installs with the specified profile (`desktop`, `developer`, `minimal`, `recovery`).
* `--resume`: Loads the imported profile from `/var/lib/cidre/resume/resume.env`.
* `--resume-profile`: Prints the imported resume profile and exits.
* `--no-resume`: Ignores imported resume state.
* `--rc-dry-run`: Runs comprehensive simulation of all profiles and doctor audits.

### `cidre-user-setup`
Manages user configurations, profiles, and backup snapshots.
* `apply --profile <name>`: Deploys template files to the user's home directory.
* `verify`: Checks if configurations match expected template configurations or have drift.
* `diff`: Shows differences between deployed configurations and template sources.
* `rollback`: Reverts changes using the most recent auto-backup snapshot.

### `cidre-doctor`
Diagnoses system compatibility and environment state.
* `--daily`: Standard diagnostic suit covering wayland, binaries, service activation.
* `--maintenance`: Audits snapshot directories, log files, package synchronization dates.
* `--rc-readiness`: Confirms tree readiness for release candidate standards.
* `--base-readiness`: Audits root-phase readiness for `./preinstall`.
* `--base-readiness --summary`: Condensed readiness status for handoff/debugging.
* `--seed`: Audits imported seed state under `/var/lib/cidre/seed`.
* `--resume`: Audits system and user resume state.
* `--downstream`: Audits downstream foundation files, prototypes, and metadata examples.
* `--image`: Audits prototype image scripts, overlay contents, workspace docs, and latest generated artifacts.
* `--firstboot`: Audits firstboot scripts, state markers, handoff files, and overlay OOBE content.
* `--fix-suggestions`: Renders actionable recovery commands based on the last run.
* `--recovery-screen`: Audits recovery screen assets and state directories.
* `--safe-mode`: Audits safe mode assets and non-destructive recovery actions.
* `--rescue`: Audits Rescue Slot foundation assets, profile metadata, and read-only safety defaults.
* `--rescue-boot`: Audits Rescue Boot Integration assets and dry-run planning flow.
* `--macos-rescue`: Audits macOS-side rescue planning scripts.

### `cidre-recovery`
Dispatches rescue triggers from console TTY in emergency loops.
* `status`: Inspects session and config state.
* `screen`: Shows the recovery screen.
* `safe-mode`: Opens the v0.25.0 safe mode path.
* `panic`: Triggers the panic entrypoint.
* `actions`: Lists or runs recovery actions.
* `recovery-report`: Generates the recovery report.
* `rescue-status`: Runs Rescue Slot readiness checks.
* `rescue-plan`: Generates a Rescue Slot plan.
* `rescue-report`: Generates the Rescue Slot report.
* `rescue-build`: Builds the Rescue Slot overlay artifact.
* `rescue-inspect`: Inspects the Rescue Slot overlay.
* `rescue-boot-status`: Shows rescue boot integration risk or status.
* `rescue-boot-plan`: Generates the rescue boot plan.
* `rescue-boot-report`: Generates the rescue boot report.
* `rescue-boot-checklist`: Generates the rescue boot checklist.
* `rescue-create-dry-run`: Generates rescue creation dry-run output.
* `restore latest`: Restores configurations to the last snapshot.
* `reset-niri`: Resets composer files to stable factory defaults.
* `seed-status`: Shows imported seed profile and source commit summary.
* `resume-status`: Shows whether resume state exists and whether it has been applied.
* `downstream-status`: Shows whether downstream prototype files are available.
* `image-status`: Shows whether prototype image artifacts have been generated.
* `firstboot-status`: Shows firstboot started/completed/skipped/failed status and handoff presence.

### `cidre-snapshot`
Takes snapshot points of Cidre configuration directories.
* `create [--label <lbl>]`: Copies configurations to a snapshot bundle.
* `list`: Chronologically lists available snapshot points.
* `prune [--keep <num>] [--older-than <dur>]`: Deletes older snapshots, protecting the latest index.

### `cidre-update`
Safe updater wrapper for packages and configurations.
* `--check`: Checks update prerequisites and Sync age.
* `--dry-run`: Previews incoming sync changes.
* `--apply`: Safely updates package databases and configuration templates.

### `cidre-maintenance`
Consolidates standard admin tasks.
* `status`: Displays snapshot statistics and log summaries.
* `prune`: Cleans up logs and snapshots interactively.
* `drift`: Tracks configuration updates.

### `scripts/cidre-macos-check`
Runs macOS-side readiness checks for Apple Silicon, command availability, network reachability, disk advisory output, and repository state.
* `--restore-readiness`: Prints the current macOS-side restore-readiness checklist stub.

### `scripts/cidre-macos-restore-check`
Runs the macOS-side high-level restore readiness audit.

### `scripts/cidre-macos-partition-audit`
Collects `diskutil`-based partition layout output and advisory candidate summaries.

### `scripts/cidre-macos-startup-disk-check`
Generates startup disk guidance without changing any setting.

### `scripts/cidre-macos-uninstall-guide`
Generates the macOS-side uninstall guide from current restore artifacts.

### `scripts/cidre-macos-restore-report`
Generates the macOS-side restore report.

### `scripts/cidre-macos-risk`
Classifies macOS-side restore risk from advisory audit output.

### Exit Path Commands
The Linux-side uninstall foundation commands.
* `scripts/cidre-uninstall-check`: Read-only uninstall readiness audit.
* `scripts/cidre-exit-plan`: Generates a human-readable exit plan.
* `scripts/cidre-state-export`: Exports Cidre state and reports into an archive.
* `scripts/cidre-partition-audit`: Records the current partition layout in text and JSON.
* `scripts/cidre-macos-restore-guide`: Writes a macOS cleanup checklist.
* `scripts/cidre-uninstall-risk`: Classifies uninstall readiness risk.
* `scripts/cidre-goodbye`: Generates a final uninstall summary.
* `scripts/cidre-erase-preflight`: Confirms prerequisites and intentionally blocks destructive erase in v0.23.0.

### Recovery Commands
The TTY-first recovery UX commands.
* `scripts/cidre-panic`: Records a failure reason and routes to recovery UX.
* `scripts/cidre-recovery-screen`: Prints the recovery screen and available actions.
* `scripts/cidre-safe-mode`: Skips normal desktop startup and opens recovery guidance.
* `scripts/cidre-safe-shell`: Prints or opens the safe shell environment.
* `scripts/cidre-session-failure`: Records session failure and connects to panic flow.
* `scripts/cidre-desktop-failure-detect`: Detects repeated desktop failure state.
* `scripts/cidre-recovery-actions`: Lists or runs non-destructive recovery actions.
* `scripts/cidre-emergency-banner`: Prints emergency recovery commands.
* `scripts/cidre-recovery-report`: Writes the recovery summary report.

### Rescue Commands
The separate rescue environment foundation commands.
* `scripts/cidre-rescue`: High-level rescue entrypoint.
* `scripts/cidre-rescue-check`: Verifies rescue environment readiness.
* `scripts/cidre-rescue-plan`: Generates the Rescue Slot plan.
* `scripts/cidre-rescue-profile`: Prints and validates rescue profile metadata.
* `scripts/cidre-rescue-image-build`: Builds rescue overlay artifacts.
* `scripts/cidre-rescue-image-inspect`: Inspects rescue artifacts or overlay trees.
* `scripts/cidre-rescue-manifest`: Generates and validates rescue manifests.
* `scripts/cidre-rescue-mount`: Scans and mounts likely main Cidre roots with read-only default.
* `scripts/cidre-rescue-export`: Exports state and logs from a mounted main root.
* `scripts/cidre-rescue-kernel-check`: Inspects kernel, initramfs, and boot files.
* `scripts/cidre-rescue-report`: Summarizes rescue session status and next steps.
* `scripts/cidre-rescue-clean`: Cleans rescue artifacts and temporary paths safely.
* `scripts/cidre-rescue-boot-plan`: Generates rescue boot integration plan output.
* `scripts/cidre-rescue-disk-check`: Collects read-only Linux-side rescue disk hints.
* `scripts/cidre-rescue-slot-metadata`: Generates and validates rescue boot metadata.
* `scripts/cidre-rescue-boot-guide`: Generates human-readable rescue boot guidance.
* `scripts/cidre-rescue-boot-report`: Summarizes rescue boot planning status.
* `scripts/cidre-rescue-create-dry-run`: Prints future rescue creation steps without writing to disk.
* `scripts/cidre-rescue-boot-checklist`: Generates a real-hardware validation checklist.
* `scripts/cidre-rescue-boot-risk`: Classifies rescue boot planning risk.
* `scripts/cidre-rescue-boot-validate`: Records rescue boot validation status.

### `scripts/cidre-macos-seed`
Generates `.local/state/cidre/macos-bootstrap/manifest.json`, checksum metadata, and handoff notes for later manual continuation.

### `scripts/cidre-macos-handoff`
Prints the ALARM/Asahi installer handoff steps and the follow-up `./preinstall` then `./install` continuation path.

### `cidre-welcome`
Visual dashboard greeting users with keybindings and navigation tips upon initial login.

### `cidre-audio`
Manages audio volume and buffer profiles (e.g. Asahi popping noise workarounds).
* `status`: Displays audio profiles.
* `profile stable`: Sets buffer rates for pop noise prevention.
