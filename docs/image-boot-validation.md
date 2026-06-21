# Image Boot Validation

Cidre v0.17.0 introduces image boot validation tooling.

## Why boot validation exists

Overlay inspection (v0.15.0) verified that Cidre scripts are bundled into the rootfs overlay artifact.
Firstboot OOBE (v0.16.0) added the guided setup flow that runs on first boot.

Boot validation (v0.17.0) bridges the gap between artifact generation and actual boot testing.

The goal is to verify:

- Required Cidre components are present in a mounted rootfs
- Firstboot service is enabled in the image
- Firstboot state is clean (not previously completed)
- All necessary tooling for controlled boot testing is in place

## Difference between overlay validation and boot validation

| Layer | What it checks |
|---|---|
| Overlay inspection | Scripts present in the overlay tarball |
| Mounted rootfs inspection | Scripts present in an actual mounted rootfs |
| Boot readiness | All pre-boot conditions are met |
| Real boot test | First boot successfully runs OOBE |

Boot validation is the step between overlay inspection and actual real-hardware boot testing.

## Required artifacts

- `cidre-rootfs-overlay.tar.gz`: the overlay artifact
- `cidre-rootfs-overlay.tar.gz.sha256`: checksum
- `cidre-image-manifest.json`: image manifest

## Rootfs inspection

Mount the image (if applicable), then run:

```sh
scripts/cidre-rootfs-inspect --rootfs <mounted-rootfs>
```

Or use the overlay directory as a surrogate:

```sh
scripts/cidre-rootfs-inspect --rootfs downstream/rootfs-overlay
```

## Firstboot service checks

The following must be present in the rootfs:

- `/etc/systemd/system/cidre-firstboot-root.service`
- `/etc/systemd/system/multi-user.target.wants/cidre-firstboot-root.service`

The following must NOT exist in a clean image:

- `/var/lib/cidre/firstboot-root/completed`
- `/var/lib/cidre/firstboot-root/skipped`

## Boot checklist

Generate a checklist before real boot testing:

```sh
scripts/cidre-boot-checklist --profile developer --output checklist.md
```

## Known failure points

- Image format mismatch prevents loop mounting
- Missing host tools (`mount`, `losetup`) block image mounting
- Completed/skipped markers from a previous test run block clean OOBE
- Missing `cidre-firstboot-root.service` symlink in `multi-user.target.wants`

## What counts as success

Boot readiness validation succeeds when:

- Rootfs inspection passes (all required scripts present)
- Firstboot service is present and enabled
- Firstboot state is clean

Real boot success (v1.0.0 requirement) means:

- OOBE appears on first boot console
- User is not required to know `root/root`
- Firstboot completion markers are written after OOBE completes
- `./install --resume` works after handoff

## What remains pending

- Real Apple Silicon boot validation
- ALARM installer metadata integration
- Public bootable image release
