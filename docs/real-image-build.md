# Real Image Build

Cidre v0.19.0 introduces local prototype real image build workflows. It allows executing the ALARM image builder, staging custom configurations, registering produced prototype images into local state directories, verifying checksums/manifests, and generating markdown build/failure reports.

## Command Flow

1. Check build environment:
   ```bash
   scripts/cidre-build-environment --strict
   ```

2. Invoke image build orchestrator:
   ```bash
   scripts/cidre-real-image-build \
     --builder ../asahi-alarm-builder \
     --profile developer \
     --run
   ```

## Standard Directory Layout
- `.local/state/cidre/image-build/registered/`: Link/copy of the registered prototype images and checksums.
- `.local/state/cidre/image-build/logs/`: Capture traces of builder execution and registration actions.
- `.local/state/cidre/image-build/build-report.md`: SUCCESS metrics and properties summary.
- `.local/state/cidre/image-build/build-failure-report.md`: FAILURE details if builder execution errors out.
