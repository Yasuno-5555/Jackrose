# Cidre Safe Mode

Cidre Safe Mode skips the normal desktop startup path and keeps recovery on a shell-first path.

## Design

- primary shell: `bash`
- no dependency on Ghostty, foot, or niri
- recovery actions stay non-destructive

## Useful Commands

- `scripts/cidre-safe-shell`
- `scripts/cidre-recovery-screen`
- `scripts/cidre-doctor --daily`
- `scripts/cidre-state-export`
- `scripts/cidre-exit-plan`

Safe Mode only helps when the main Cidre system still boots.
If it does not, switch to Cidre Rescue Slot.
