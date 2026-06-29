# Controlled Manual-Boot Install

`v0.35.6` introduces a controlled install mode that keeps payload placement
separate from boot registration.

The design goal is simple: make it possible to prepare a Jackrose install without
quietly mutating the machine's default boot path.

## What This Flow Does

The controlled manual-boot flow is allowed to:

- inspect candidate disks and APFS layout
- generate an install plan for an explicitly selected target
- stage payload metadata and verification material
- generate a manual boot guide for the operator
- record reports that can be reviewed before first boot

## What This Flow Does Not Do

The controlled manual-boot flow does not:

- set Startup Disk
- rewrite the default boot target
- automatically reboot
- claim install completion before boot safety evidence exists

That separation is intentional and is part of the post-incident containment
policy after `DFU_RESTORE_001`.

## Recommended Real-Machine Sequence

1. Build the app bundle from `apps/macos/JackroseApp/build-app-bundle.sh`.
2. Launch `Jackrose.app` and confirm repository selection and preflight status.
3. Review disk layout and choose only an explicitly disposable or non-primary target.
4. Run a live drill first if the target class allows it.
5. Capture before-state evidence and keep the generated plan.
6. Run the controlled install flow to stage payloads.
7. Review the generated manual boot guide before attempting first boot.
8. Capture after-state evidence and run no-default-boot verification.
9. Attempt first boot manually.
10. Return to macOS and verify that normal startup paths still exist.

## Required Evidence

Before considering the test successful, keep:

- install plan output
- install report output
- manual boot guide output
- pre/post disk snapshots
- no-default-boot verification result
- notes about first boot success or failure

## Abort Conditions

Stop immediately if any of the following happen:

- the selected target becomes ambiguous
- protected Apple partition checks fail
- shutdown or finish remains blocked for unexplained reasons
- Startup Options or Recovery behavior looks different from pre-test state
- the app suggests a default boot mutation or automatic restart

If that happens, treat the session as a safety incident and preserve logs before
trying again.
