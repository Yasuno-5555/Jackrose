# User Phase State

## State Directory

User phase configurations and marker tracking properties are located inside the home directory state tree:
* `~/.local/state/cidre/user-phase/`

## Markers

Execution status is determined via timestamped marker files:
* `started`: Setup initialization timestamp.
* `completed`: Set on clean completion of all user setup scripts.
* `failed`: Created if any sub-stage exits with error.
* `handoff-imported`: Marks successful import of root phase configurations.

## Stage Tracking

The current stage is serialized inside `~/.local/state/cidre/user-phase/last-stage`:
* `init`
* `handoff-import`
* `resume-check`
* `profile-check`
* `repo-check`
* `installer-start`
* `profile-setup`
* `config-apply`
* `desktop-setup`
* `complete`
* `failed`

Error details are tracked in `~/.local/state/cidre/user-phase/last-error`.

## Repair Policy

Minor configuration drift, missing markers, or report compilations can be repaired using `scripts/cidre-user-phase-repair`. Destructive config overwriting, root-level package manager queries, or user privilege modifications are strictly avoided.
