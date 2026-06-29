# Target Package & Rootfs Integration Validation Guide

This guide describes the procedure for validating the built Jackrose packages, collecting them, and installing them into a target ALARM (Arch Linux ARM) or Arch Linux rootfs.

> [!IMPORTANT]
> **Validation Target Environment**
> This validation must be run on an active ALARM/Arch-like target system (or QEMU/chroot environment running Arch).
> It is intentionally deferred if target hardware is unavailable or not ready. Do not run destructive rootfs operations on your active workstation.

---

## 1. Prerequisites

Verify that the following tools are available on the target validation host:
- `makepkg` (from `pacman` development chain)
- `pacman`
- `arch-chroot` or `chroot`
- `tar` / `bsdtar`

---

## 2. Package Build Workflow

Run the custom developer build script from the repository root:

```sh
# Verify package setup and metadata syntax
scripts/dev/build-jackrose-packages --printsrcinfo-only

# Build all packages sequentially in the expected dependency order
scripts/dev/build-jackrose-packages --build
```

The expected build sequence is:
1. `jackrose-config`
2. `jackrose-user-setup`
3. `jackrose-welcome`
4. `jackrose-healthcheck`
5. `jackrose-firstboot`
6. `jackrose-safe-session`
7. `jackrose-seed`

---

## 3. Package Collection and Rootfs Assembly

Collect the built `.pkg.tar.zst` files into the output staging area:

```sh
# Collect packages
scripts/dev/collect-jackrose-packages
```

All package archives will be placed under `packages/out/`. This layout is consumed by the seed image builder.

---

## 4. Install into Test Rootfs

To dry-run the installation of the package set into a target rootfs workspace:

```sh
image/scripts/install-local-packages --rootfs <target-rootfs-path> --packages packages/out --dry-run
```

To apply the packages:

```sh
image/scripts/install-local-packages --rootfs <target-rootfs-path> --packages packages/out --apply
```

---

## 5. Enable Firstboot Systemd Units

To configure systemd startup units without running the services (dry-run):

```sh
image/scripts/enable-firstboot --rootfs <target-rootfs-path> --dry-run
```

To commit settings:

```sh
image/scripts/enable-firstboot --rootfs <target-rootfs-path> --apply
```

This will:
- Enable `NetworkManager.service`
- Enable `jackrose-firstboot.service` (capturing tty1 on next boot)
- Disable `greetd.service` (to prevent early graphical sessions before OOBE completes)
- Ensure root account password logins are locked (`passwd -l root`)

---

## 6. Validate Rootfs Configuration

Perform sanity validations on the target rootfs:

```sh
image/scripts/validate-rootfs --rootfs <target-rootfs-path>
```

This ensures:
- All required command paths and systemd units exist.
- `/var/lib/jackrose/firstboot.done` **does not** exist. If present, validation fails immediately.
