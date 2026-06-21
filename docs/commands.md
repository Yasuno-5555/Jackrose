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

### `cidre-recovery`
Dispatches rescue triggers from console TTY in emergency loops.
* `status`: Inspects session and config state.
* `safe-mode`: Disables compositor customizations and re-routes logins to console standard.
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
