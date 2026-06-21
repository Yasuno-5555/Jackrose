# Firstboot Verification

This document summarizes the validation rules for the Cidre first boot state.

## Marker File Checking

The initialization system tracks the orchestration flow by writing markers to the state directory:
- `/var/lib/cidre/firstboot-root/started`: Set when the setup process begins.
- `/var/lib/cidre/firstboot-root/completed`: Set on clean completion of OOBE.
- `/var/lib/cidre/firstboot-root/failed`: Set if setup exits with error.

Firstboot verification now includes checking the following additional state parameters and diagnostic outputs:
- `/var/lib/cidre/firstboot-root/retry-requested`: Set when retry is scheduled.
- `/var/lib/cidre/firstboot-root/last-stage`: Records the last executed setup phase stage.
- `/var/lib/cidre/firstboot-root/last-error`: Traps the last logged setup failure error message.
- `/var/lib/cidre/firstboot-root/report.md`: Markdown summary report of firstboot run metrics.
- `/var/lib/cidre/firstboot-root/diagnose.txt`: Diagnostic output summary.
- `/var/lib/cidre/firstboot-root/console.log`: Console logging output.

## Handoff Verification

The handoff target file (`/var/lib/cidre/firstboot-root/handoff.txt`) must include:
- Instructions to change root credentials.
- Instructions to run the user setup resume commands:
  ```bash
  su - <username>
  cd <repo-path>
  ./install --resume
  ```
- Profiles markers matching the manifest definitions.
