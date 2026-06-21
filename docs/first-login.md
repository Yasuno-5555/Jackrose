# First Login

## Post-Bootstrap Flow

Upon completion of the first boot root bootstrap stage, the developer console outputs login parameters and instructions. Logging in as the specified normal user starts the user setup phase.

## Handoff Verification

Before starting installations, verify that the user environment satisfies all pre-conditions:

```bash
# Verify handoff states
scripts/cidre-user-handoff --verify

# Run user phase checks
scripts/cidre-user-phase-verify
```

## Running Install Resume

Once validated, change to the Cidre repository directory and run installer resumption:

```bash
cd ~/Projects/Cidre
./install --resume
```

## Troubleshooting Failures

If the installation halts or fails:
* Check status: `scripts/cidre-user-phase-state status`
* Read logs: `cat ~/.local/state/cidre/user-phase/install.log`
* Compile reports: `scripts/cidre-user-phase-report`
* Run doctor diagnoses: `cidre-doctor --user-phase`
