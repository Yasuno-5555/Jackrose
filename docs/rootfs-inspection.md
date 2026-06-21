# Rootfs Inspection

Cidre v0.17.0 adds `scripts/cidre-rootfs-inspect` for inspecting a mounted rootfs.

## How to mount an image read-only

If you have a raw `.img` file, mount it read-only:

```sh
scripts/cidre-image-mount <image.img>
```

This mounts the image at `.local/state/cidre/mount/<image-name>` by default.

After inspection, unmount with:

```sh
scripts/cidre-image-unmount .local/state/cidre/mount/<image-name>
```

**Note:** Image mounting requires root privileges and host tools (`mount`, `losetup`).

## How to inspect a mounted rootfs

```sh
scripts/cidre-rootfs-inspect --rootfs <path-to-mounted-rootfs>
```

You can use the `downstream/rootfs-overlay` directory as a surrogate for testing:

```sh
scripts/cidre-rootfs-inspect --rootfs downstream/rootfs-overlay
```

### Strict mode

```sh
scripts/cidre-rootfs-inspect --rootfs <path> --strict
```

Strict mode also checks:

- Scripts are executable
- Systemd service symlink exists

## Required Cidre paths

### Scripts (`/usr/lib/cidre/`)

| Script | Purpose |
|---|---|
| `cidre-firstboot-root` | Root firstboot orchestrator |
| `cidre-oobe` | OOBE guided setup |
| `cidre-firstboot-state` | Firstboot state tracking |
| `cidre-firstboot-handoff` | Root-to-user handoff |
| `cidre-seed` | Seed management |
| `cidre-resume` | Resume state |
| `cidre-preinstall` | Root phase preinstall |
| `cidre-installer` | User phase installer |

### Systemd

| Path | Purpose |
|---|---|
| `/etc/systemd/system/cidre-firstboot-root.service` | Service unit |
| `/etc/systemd/system/multi-user.target.wants/cidre-firstboot-root.service` | Enable symlink |

### State directories (`/var/lib/cidre/`)

| Directory | Purpose |
|---|---|
| `seed/` | Imported seed state |
| `resume/` | Resume state |
| `firstboot-root/` | Firstboot tracking |

## Systemd service validation

The service unit must exist at:

```text
/etc/systemd/system/cidre-firstboot-root.service
```

And the enable symlink at:

```text
/etc/systemd/system/multi-user.target.wants/cidre-firstboot-root.service
```

In strict mode, the symlink target is verified.

## Firstboot state validation

A clean image must not have:

- `/var/lib/cidre/firstboot-root/completed`
- `/var/lib/cidre/firstboot-root/skipped`

If these exist, it means the image was used in a previous boot. Reset or regenerate the image before next boot testing.

## Safety notes

- Always mount images read-only (`scripts/cidre-image-mount` defaults to `--read-only`)
- Write mounts require explicit `--write --yes`
- Always unmount after inspection to avoid stale loop devices
- Do not inspect host system paths as rootfs targets unless intentional
