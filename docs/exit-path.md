# Exit Path

Cidre should be easy to try and easy to leave.

## Philosophy

Try the system, inspect the state, keep what matters, and leave without guessing.

## Linux-side flow

1. Audit the current Cidre state.
2. Export logs and reports.
3. Record the current partition layout read-only.
4. Generate a macOS restore guide.
5. Generate a human-readable exit plan.

## macOS-side flow

1. Run the macOS restore check.
2. Collect a `diskutil`-based audit.
3. Review startup disk guidance.
4. Generate the macOS uninstall guide.
5. Generate the restore report.

The exit path now has two sides:

Linux/Cidre side:
  state export, exit plan, partition audit

macOS side:
  restore check, diskutil audit, uninstall guide, restore report

Recovery Screen can generate exit plans and state exports before uninstall.
Rescue Slot can also prepare exports and exit decisions when the main system will not boot.

## Future Direction

Later releases will add a macOS restore assistant and a guided uninstaller with dry-run defaults.
