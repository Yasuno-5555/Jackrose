# Cidre Packaging Index

This document catalogs Arch Linux package definitions (PKGBUILDs) managed within the Cidre repository under `packages/arch/`.

## Packages List

* **niri-cidre**: Custom build configuration of the Niri window manager/compositor adjusted for Asahi Linux display constraints.
* **cidre-session**: Sets up custom display-manager greeter integrations and runs the systemd user service environment wrapper.
* **cidre-config**: Original source config files and desktop wallpapers.
* **cidre-user-setup**: Script orchestrating template configurations deployment.
* **cidre-audio**: Buffering utilities, volume control wrappers, and PipeWire state resets.
* **cidre-welcome**: Script printing TUI dashboard and shortcut hints upon graphical login.
* **cidre-diagnostics**: Renders health audits via `cidre-doctor`.
* **cidre-recovery**: TTY console helper command to roll back composition errors and restore configurations.
* **cidre-firstboot**: Triggers initial login checks and writes status audits.
* **cidre-snapshot**: Takes configuration snapshots and restores backups.
* **cidre-update**: Performs safely staged package update checks.
* **cidre-maintenance**: Handles stale snapshots, log pruning, and configuration drifts.
* **cidre-wallpapers**: Stores Cidre theme wallpapers.
* **cidre-meta-core**: Installs essential systemd services and basic shell requirements.
* **cidre-meta-desktop**: Standard desktop stack (pulls window manager, terminal, Waybar panels, audio routing).
* **cidre-meta-dev**: Development extensions (Fish, base-devel tools).
