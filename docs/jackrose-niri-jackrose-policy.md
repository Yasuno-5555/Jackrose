# Jackrose niri-jackrose Policy

## Current Rule

`niri-jackrose` is tracked as a P0 compositor candidate, not as a required runtime dependency.

## Runtime Constraint

- Shipped Jackrose config must parse on upstream `niri`.
- Shipped Jackrose config must not call `niri-jackrose`.
- Shipped Jackrose config may prefer `ghostty`, but must fall back to `foot`.

## Tracking

- `recovery.tsv`: tracked as `niri-jackrose`
- `build-plan.tsv`: tracked against future `jackrose-niri`
- `p0-feasibility.tsv`: tracked as unprobed / blocked
