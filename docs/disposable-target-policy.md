# Disposable Target Policy

Cidre only allows destructive mutation tests against explicitly disposable targets.

Blocked targets include:

- the current macOS startup disk or startup container
- `Apple_APFS_Recovery`
- recoveryOS related partitions
- iBoot system containers
- unknown Apple-managed partitions

Allowed targets must be clearly disposable, such as a marked `Cidre Test` target.
