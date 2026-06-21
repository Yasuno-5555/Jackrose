# Image Build Validation

## Validation Scope

v0.15.0 validates the prototype image artifact flow, not a production image release.

## Validation Tasks

- shell syntax checks for image build scripts
- overlay sync validation
- overlay tarball generation
- overlay tarball checksum generation
- image manifest generation
- overlay tarball listing
- overlay directory inspection
- optional mounted rootfs inspection

## Boot Validation

Boot validation is explicitly deferred.

The presence of a prototype artifact does not imply:

- public image readiness
- guaranteed bootability
- production installer integration

## Recommended Commands

```sh
scripts/cidre-image-build --dry-run --profile developer
scripts/cidre-image-build --sync-overlay
scripts/cidre-image-build --overlay-only --inspect
scripts/cidre-image-inspect --overlay downstream/rootfs-overlay
python3 -m json.tool .local/state/cidre/image-build/cidre-image-manifest.json
```
