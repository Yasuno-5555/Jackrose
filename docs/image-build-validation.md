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

## Firstboot OOBE Validation

- `cidre-firstboot-root --dry-run`
- `cidre-firstboot-root --status` with a simulated root
- `cidre-firstboot-state mark-started`
- `cidre-firstboot-state mark-completed`
- `cidre-firstboot-state mark-skipped`
- handoff generation
- overlay inspection

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

## v0.17.0: Boot validation extension

v0.17.0 extends validation from overlay artifacts to mounted rootfs and boot readiness.

New validation layers:

- Builder status check (`scripts/cidre-builder-status`)
- Image mount/unmount (`scripts/cidre-image-mount`, `scripts/cidre-image-unmount`)
- Rootfs inspection (`scripts/cidre-rootfs-inspect`)
- Boot readiness aggregation (`scripts/cidre-image-boot-readiness`)
- Boot checklist generation (`scripts/cidre-boot-checklist`)
- Boot log collection (`scripts/cidre-boot-log-collect`)
