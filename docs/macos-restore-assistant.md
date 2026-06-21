# macOS Restore Assistant

Cidre v0.24.0 adds a macOS-side restore assistant layer.

## Purpose

- collect read-only disk layout information
- generate restore guidance
- classify restore risk
- prepare a future guided uninstaller

## Read-only Policy

The restore assistant does not:

- delete partitions
- resize APFS containers
- change startup disk settings
- run destructive `diskutil` commands

## Commands

- `./install-macos --restore-help`
- `./install-macos --restore-check`
- `./install-macos --partition-audit`
- `./install-macos --startup-disk-check`
- `./install-macos --uninstall-guide`
- `./install-macos --restore-report`

## State Layout

- `.local/state/cidre/macos-restore/current/`
- `.local/state/cidre/macos-restore/history/`

## Future Direction

These artifacts are designed to feed a future dry-run guided uninstaller.

Recovery Screen can point users to macOS Restore Assistant when local recovery is not enough.
If Rescue Slot cannot recover main Cidre or the user wants to leave Cidre, use macOS Restore Assistant and exit path tools.
macOS Restore Assistant can report Rescue Slot planning status.
