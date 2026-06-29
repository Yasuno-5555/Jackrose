# No Default Boot Mutation Policy

Jackrose must not silently replace the machine's normal boot path.

This policy exists because a GUI-driven install path previously led to a boot
failure severe enough to require DFU recovery.

## Policy Rules

During controlled install testing, Jackrose must not:

- set Startup Disk to a Jackrose target
- modify the machine's default boot container or root identifier
- auto-restart into a newly staged install
- report install completion solely because payload staging succeeded

## Enforcement Points

The repository currently enforces this policy through:

- controlled install planning that keeps boot registration out of scope
- `scripts/jackrose-app-no-default-boot-check`
- finish and before-shutdown gates
- documentation and operator review checkpoints

## Verification Model

The current verification model compares pre/post machine state and expects the
default boot identifiers to remain unchanged.

When testing on real hardware:

1. capture a before snapshot
2. complete the controlled install staging flow
3. capture an after snapshot
4. run the no-default-boot check against both snapshots
5. preserve the result with the install report

If the check reports a changed root identifier, the session must be treated as a
failure even if payload staging otherwise succeeded.

## Operator Expectations

The operator should expect to make the first boot choice manually.

If the current flow ever appears to:

- pick a startup disk on its own
- queue an automatic restart
- imply that no manual boot choice is required

that is a bug and should block further testing.
