# User Phase Handoff

User phase failure can set a recovery reason and show safe mode guidance.

## Why User Phase Handoff Exists

The transition between root-level bootstrap and normal user configuration represents a critical boundary. User Phase Handoff establishes a robust, structured protocol to pass parameters from root context (first boot execution) to normal user session configuration.

## Root Phase vs. User Phase Responsibility

* **Root Phase Responsibility**:
  - Sets up normal user accounts and sudo configurations.
  - Verification of bootstrap seed packages.
  - Creation of seed resume states.
  - Serialization of user handoff variables in machine-readable formats.

* **User Phase Responsibility**:
  - Importing handoff parameters.
  - Environment preflight validation checks.
  - Resuming the installer under normal user privileges.
  - Configuration of home files, session components, and dotfiles.

## Handoff State Files

Root bootstrap writes handoff metrics inside the system state tree:
* `/var/lib/cidre/handoff/user-phase.env`: Variables configuration file.
* `/var/lib/cidre/handoff/user-phase.json`: Machine-readable metadata schema.
* `/var/lib/cidre/handoff/handoff.txt`: Guided login walkthrough.

### user-phase.env

```sh
CIDRE_SELECTED_USER=yasuno
CIDRE_SELECTED_PROFILE=developer
CIDRE_REPO_PATH=/home/yasuno/Projects/Cidre
CIDRE_RESUME_STATE_PATH=/var/lib/cidre/resume/resume.env
CIDRE_HANDOFF_CREATED_AT=2026-06-21T00:00:00Z
```

### user-phase.json

```json
{
  "schema_version": 1,
  "selected_user": "yasuno",
  "selected_profile": "developer",
  "repo_path": "/home/yasuno/Projects/Cidre",
  "resume_state_path": "/var/lib/cidre/resume/resume.env",
  "handoff_created_at": "2026-06-21T00:00:00Z",
  "root_phase_completed": true,
  "user_phase_started": false,
  "user_phase_completed": false
}
```

## Install Resume Flow

1. Normal user logs into system.
2. Checks handoff validation metrics: `scripts/cidre-user-handoff --verify`.
3. Runs installer resumption: `./install --resume`.
