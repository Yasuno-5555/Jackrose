# TTY Recovery

If the normal desktop cannot start, use a TTY-first recovery flow.

## Start Here

- `scripts/cidre-recovery-screen --reason desktop-session-failed --non-interactive`
- `scripts/cidre-safe-shell --reason desktop-session-failed`

## Common Commands

- `scripts/cidre-doctor --daily`
- `scripts/cidre-recovery status`
- `scripts/cidre-state-export --include-logs --include-reports`
- `scripts/cidre-exit-plan --include-partition-audit --include-macos-guide`

If TTY recovery is unavailable because the main system does not boot, use Cidre Rescue Slot instead.
