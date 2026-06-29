# Jackrose Seed Image Assembly Guide

This document describes the design and operations for generating local Jackrose seed image candidates from base ALARM (Arch Linux ARM) rootfs tarballs.

---

## 1. Safety Constraints

> [!IMPORTANT]
> **Host Safety First**
> Assembling real rootfs directories requires root privileges (`sudo`) and chroot mounts. To ensure host stability:
> 1. The builder will reject any commands targeting the host root directory `/`.
> 2. All temporary workspaces must be inside the repository-scoped build directory.
> 3. Overwriting existing workspaces is blocked unless `--force-clean` is passed.

---

## 2. Extraction & Packaging Rules

### 2.1. Supported Formats
The `prepare-rootfs` script supports standard tar archives:
- `.tar`
- `.tar.gz`
- `.tar.xz`
- `.tar.zst`

Custom disk image formats (like `.img` or `.iso`) are unsupported and will trigger immediate failure.

### 2.2. Package Set Selection
A complete baseline desktop profile is installed via Pacman into the target rootfs:
- Custom Jackrose helper packages (welcome, configuration, update, healthcheck).
- Base graphical environment tools (upstream `niri`, `foot`, `fuzzel`, `waybar`, `firefox`, `fcitx5`).
- The system is configured to boot directly into `greetd` graphical session launching `jackrose-session`.

### 2.3. Forbidden State Markers
Seed images must remain uninitialized. The validation process will fail immediately if any of these markers are found in the rootfs:
- `/var/lib/jackrose/firstboot.done`
- `/var/lib/jackrose/welcome.done`
- `/var/lib/jackrose/optimized.done`

---

## 3. Relationship to Installer Metadata

- **Phase 10** produces local image artifacts.
- **Phase 11** describes those artifacts in a unified JSON layout format.
- Exposing installer metadata does not imply the image has been published to a public mirror.
- A release channel entry must never use `PLACEHOLDER_SHA256` under any circumstances.

