# Cidre Updates Guide

Cidre provides a dedicated updating script `cidre-update` to maintain the desktop config layer and packages safely.

## Commands

### Update Check
Verify update readiness, utility availability, and manifest status:
```bash
cidre-update --check
```

### Dry Run Previews
Preview what packages would be checked and configurations deployed without executing any system changes:
```bash
cidre-update --dry-run
```

### Applying Updates
Performs a safe update using the following sequence:
1. Creates a pre-update config snapshot using `cidre-snapshot`.
2. Syncs pacman databases.
3. Re-applies/updates configurations through `cidre-user-setup`.
4. Executes validation checks using `cidre-doctor --maintenance`.
5. Records the execution log in update history.

```bash
cidre-update --apply
```

## Update Log Locations
All update executions are recorded under:
* `~/.local/state/cidre/update/history.log` (Summary log)
* `~/.local/state/cidre/update/last-update.log` (Verbose terminal output of last update)
