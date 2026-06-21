# Cidre Image Prototype

## What v0.15.0 Builds

v0.15.0 builds a prototype overlay artifact flow for a future Cidre image.

The first milestone is not a public bootable image.
The first milestone is a reproducible rootfs overlay artifact that contains:

- Cidre firstboot-root
- seed/resume tools
- doctor/recovery tooling
- the prototype firstboot-root systemd unit
- required `/var/lib/cidre` state directories

## What It Does Not Build

- a public installable image
- production installer metadata integration
- a guaranteed bootable image
- a fully integrated desktop image

## Prototype Artifact Layout

Default output:

```text
.local/state/cidre/image-build/
  cidre-rootfs-overlay.tar.gz
  cidre-rootfs-overlay.tar.gz.sha256
  cidre-image-manifest.json
  build.log
  inspect.log
```

## Rootfs Overlay

The prototype overlay lives under `downstream/rootfs-overlay/`.

Its core layout is:

```text
usr/lib/cidre/
etc/systemd/system/
var/lib/cidre/
```

## Firstboot-root Service

`cidre-firstboot-root.service` is included in the overlay and enabled through
`multi-user.target.wants/`.

The service remains a safe prototype in v0.15.0.
It does not implement the full firstboot OOBE yet.

The prototype overlay now includes firstboot OOBE scripts.
The image is still not public or boot-validated.

## Seed / Resume Tools

The overlay sync flow copies these tools into `/usr/lib/cidre/`:

- `cidre-seed`
- `cidre-seed-verify`
- `cidre-seed-import`
- `cidre-resume`

## Inspection Flow

Typical prototype validation:

```sh
scripts/cidre-image-build --overlay-only --inspect
scripts/cidre-image-inspect --tar .local/state/cidre/image-build/cidre-rootfs-overlay.tar.gz
```

## Known Limitations

- boot validation is deferred
- builder execution is still wrapper-first
- no public Cidre image is shipped in v0.15.0

## v0.17.0: Boot readiness checks

v0.17.0 introduces boot readiness checks.

A prototype image is not considered ready for controlled boot validation until:

- `scripts/cidre-rootfs-inspect --rootfs <rootfs>` passes
- `scripts/cidre-image-boot-readiness --rootfs <rootfs>` passes

These checks confirm that Cidre components are present, firstboot service is enabled,
and firstboot state is clean.
