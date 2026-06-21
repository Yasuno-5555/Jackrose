# Builder Runbook

This document describes how to execute the ALARM builder manually and debug typical integration script failures.

## Recommended Builder Execution Path

```bash
# Execute dry-run first
scripts/cidre-real-image-build --builder ../asahi-alarm-builder --profile developer --dry-run

# Run full execution
scripts/cidre-real-image-build --builder ../asahi-alarm-builder --profile developer --run
```

## Common Failure Points

1. **Permission Denied**: Staging tree syncing preserves owners/permissions which may require root/sudo access during overlay extraction.
2. **Missing Entrypoint**: Ensure the builder repository contains either `build.sh` or `scripts/build.sh`.
3. **Zstandard Tools Missing**: Compression steps rely on a local `zstd` binary. Install using your host package manager.
4. **Failure logs**: Inspect `.local/state/cidre/image-build/build-failure-report.md` for environmental status and builder outputs.
