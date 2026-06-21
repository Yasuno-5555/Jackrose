# Uninstalling Cidre

Cidre v0.23.0 adds the first Linux-side uninstall foundation.

## What v0.23.0 can do

- check uninstall readiness
- generate an exit plan
- export Cidre state and reports
- record a read-only partition audit
- generate a macOS restore guide
- classify uninstall risk

v0.24.0 adds macOS-side restore assistant commands.
These commands collect audit information and generate guides, but do not delete anything.
v0.26.0 adds Rescue Slot foundation so export and exit planning can still start when the main Cidre install no longer boots.

## What v0.23.0 cannot do

- delete partitions
- resize APFS containers
- change the default startup disk automatically
- restore macOS automatically

## Recommended Flow

1. Run `scripts/cidre-uninstall-check`.
2. Run `scripts/cidre-state-export --include-logs --include-reports`.
3. Run `scripts/cidre-partition-audit`.
4. Run `scripts/cidre-macos-restore-guide`.
5. Review `scripts/cidre-uninstall-risk`.
6. Use the macOS-side guide for manual cleanup.

## Warning

Partition audit output is advisory only.
Do not delete partitions based only on Linux-side reports.
