# Image Build Notes

## Builder Focus

- identify the builder repository
- document build dependencies
- define rootfs customization points

## Overlay Expectations

- seed/resume tooling present in image
- firstboot-root unit file present in image
- state directories available

## Artifact Expectations

- predictable artifact naming
- checksums generated
- test matrix recorded

## v0.15.0 Prototype Flow

- set `CIDRE_ALARM_BUILDER_DIR` when a local builder checkout exists
- run `scripts/cidre-image-build --dry-run`
- run `scripts/cidre-image-build --sync-overlay`
- run `scripts/cidre-image-build --overlay-only --inspect`
- inspect the overlay with `scripts/cidre-image-inspect`

## Deferred Areas

- boot validation
- production installer integration
- root partition growth
- root UUID behavior

v0.15.0 documents and generates prototype artifacts without claiming that a production image is already built.
