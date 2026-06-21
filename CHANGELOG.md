# Changelog

All notable changes to the Cidre project will be documented in this file.

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
