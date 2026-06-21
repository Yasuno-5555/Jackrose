# macOS Startup Disk Check

Startup disk state matters before any uninstall flow.

## Why it matters

You should know that macOS boots normally before touching any Linux-related partition.

## v0.24.0 behavior

- provides guidance only
- does not change startup disk settings
- does not call `bless --setBoot`

## Manual Review

Check Startup Disk from System Settings and confirm macOS is selected before any future cleanup.
