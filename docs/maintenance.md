# Cidre Maintenance Guide

This document describes how to monitor and maintain your Cidre desktop installation.

## Commands

### Maintenance Status
Check snapshot statistics, log file present status, active profile, and state paths:
```bash
cidre-maintenance status
```

### Snapshot & Log Pruning
Cleanup stale files. By default, `prune` keeps the last 10 snapshots and logs from the last 30 days. The latest snapshot is always protected from deletion.
```bash
cidre-maintenance prune
```

Options:
* `--keep <num>`: Keep specified number of snapshots (default: 10).
* `--dry-run`: View proposed deletions without executing them.
* `--yes`: Skip confirmation prompt.

To prune via the snapshot utility directly:
```bash
cidre-snapshot prune --older-than 30d
```

### Configuration Drift Detection
Compares your home configuration files against the original Cidre configuration templates and your setup manifest to report any local alterations:
```bash
cidre-maintenance drift
```

### Operation Logs
View last log outputs of install, update, setup, and diagnostics:
```bash
cidre-maintenance logs
```
