# Builder Integration

This document describes how the Cidre overlay, boot validation, and diagnostic tools integrate with the ALARM image builder to generate the final public/prototype bootable system images.

## Staging & Injection Flow

1. **Staging Configuration**: `cidre-builder-config` is used to load build profiles and setup environment directories.
2. **Overlay Injection**: `cidre-builder-integrate` maps and copies rootfs overlay files (e.g., configurations, hooks, OOBE helpers) directly into the builder's stage area.
3. **Execution Planning**: `cidre-builder-invoke` plans the exact build wrapper commands (using simulated environment steps if builder scripts are unavailable) and tracks output.
4. **Log Analysis**: `cidre-builder-log` processes build logs, highlights warnings/failures, and identifies configuration gaps.
5. **Artifact Scanning & Registration**: `cidre-builder-artifacts` scans target image output paths, computes digests, and registers the produced prototype files to the image manifests.
6. **Promotion**: `cidre-image-promote` transitions verified prototype image outputs to formal distribution points.

## Command Reference

- `cidre-image-build --builder-config` loads and runs configuration steps.
- `cidre-recovery builder-status` queries active staging parameters.
- `cidre-doctor --builder` checks builder repository health and workspace state.
