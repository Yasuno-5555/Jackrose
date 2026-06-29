# Known Limitations

Jackrose is still in a constrained safety posture after `DFU_RESTORE_001`.

## Real Hardware Status

Real-hardware clean install is not yet fully verified.

The current macOS installer and helper tooling are intended to support
controlled validation work, not unattended end-user installation on a primary
machine.

Do not treat a successful UI flow as proof that the machine remains boot-safe.

## Disk Mutation Status

Disk-changing install is disabled by default.

The repository currently assumes:

- protected Apple partitions must remain unchanged
- pre/post disk snapshots must exist before install completion can be trusted
- finish, restart, and shutdown actions must remain blocked until boot safety checks pass
- default boot target mutation is not allowed

## Controlled Manual-Boot Scope

`v0.35.6` separates payload staging from boot registration.

This means the current flow can prepare install artifacts and emit manual boot
instructions, but it does not:

- automatically register Jackrose as the default boot target
- automatically change Startup Disk
- automatically reboot into Jackrose
- prove that the resulting boot path is safe on every Apple Silicon model

## Validation Gaps

The following items still require real-machine evidence:

- disposable-target live drill execution records
- before/after disk snapshot capture from the same hardware session
- no-default-boot verification using real pre/post state
- controlled install report review after payload staging
- successful first boot and return-to-macOS validation

## Operational Guidance

Until those gaps are closed, only test on hardware you can erase and recover.

Prefer this sequence:

1. Generate the `.app` from the checked-in bundle script.
2. Run read-only preflight and gate checks.
3. Run a disposable-target live drill.
4. Capture before/after evidence and review reports.
5. Only then attempt controlled manual-boot install on a non-primary target.
