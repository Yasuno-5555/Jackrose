# macOS Restore Guide

Cidre v0.23.0 generates a Linux-side markdown guide for macOS cleanup.

## Goal

Help the user return to macOS without guessing.

## Checklist

1. Boot into macOS.
2. Confirm macOS starts normally.
3. Review Startup Disk settings.
4. Inspect partition layout carefully.
5. Delete only confirmed Linux/Asahi/Cidre partitions.
6. Reboot and verify macOS startup.

## Current Limit

The actual cleanup remains manual in v0.23.0.

## Bridge to v0.24.0

If you are already back in macOS, continue with:

- `./install-macos --restore-check`
- `./install-macos --partition-audit`
- `./install-macos --startup-disk-check`
- `./install-macos --uninstall-guide`
