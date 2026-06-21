# Firstboot Retry and Repair

## When Retry is Safe

Firstboot retry is safe when:
* The OOBE flow or package staging failed due to temporary network issues.
* Package dependencies were incorrectly updated, but have since been repaired.
* State files or directories are intact, but no completion marker exists.
* The system is booted in recovery or rescue mode where state modifications can be verified.

## When Retry is Unsafe

Firstboot retry is unsafe or blocked when:
* The `completed` marker file exists. Forcing a retry on a completed setup can overwrite existing user configurations, duplicate user accounts, or corrupt already initialized repositories.
* Host filesystems are mounted read-only.

## Marker Policies

The fixup tools manage specific state file rules:
* `started`: Indicates setup has run at least once.
* `failed`: Created if any sub-stage exits with a non-zero status code.
* `completed`: Standard finish indicator. Must be missing to trigger a retry.
* `retry-requested`: Explicit developer trigger that clears previous failure metrics.

## Handoff Regeneration

If the firstboot setup completed but the final handoff documentation was not generated or was corrupted, run the repair script with `--regenerate-handoff` to recreate the handoff command metrics:

```bash
scripts/cidre-firstboot-repair --root /path/to/rootfs --regenerate-handoff --yes
```
