# Installer Integration

## Scope

- macOS bootstrap
- Asahi/ALARM installer handoff
- Cidre image entry
- installer metadata examples
- future image URLs and checksums

## Current Position

v0.14.0 does not publish production installer metadata.
It defines where Cidre needs to integrate and what shape that metadata probably needs.

v0.15.0 adds prototype rootfs overlay generation, artifact manifests, and checksums.
It still does not connect those artifacts to production installer metadata.

## Risks

- upstream schema changes
- image naming drift
- branding and icon expectations
- mismatch between installer metadata and real image capabilities
