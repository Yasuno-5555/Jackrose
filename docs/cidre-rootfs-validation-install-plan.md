# Extracted Rootfs Validation + Install Plan

This document details the design and schema specifications of the wrapper rootfs content validation and review-only install plan generation layers.

---

## 1. Safety Guidelines

> [!WARNING]
> **No Target Mutation**
> Phase 30 does not discover real install targets.
> Phase 30 does not stage files to a target disk.
> Phase 30 does not mount or write target disks.
> Phase 30 does not run the Asahi/ALARM installer.
> `install-plan.json` is a review-only planning artifact, **not** an installation authorization.

---

## 2. Validation Specifications

To evaluate the sandbox-extracted rootfs as a Cidre desktop seed:
- Validates conventions (`usr/`, `etc/`, `var/`, `usr/share/cidre/defaults/`).
- Validates baseline components (`cidre-welcome`, `cidre-doctor`, `cidre-session`).
- Validates Wayland session specifications (`usr/share/wayland-sessions/niri.desktop` or similar).
- Rejects completed setup flags (e.g. `firstboot.done`).

---

## 3. Usage

To validate rootfs contents:

```bash
installer/scripts/validate-cidre-extracted-rootfs-content \
  --extracted installer/wrapper/extracted-rootfs.json \
  --output installer/wrapper/rootfs-validation.json
```

To generate a review plan:

```bash
installer/scripts/generate-cidre-install-plan \
  --rootfs-validation installer/wrapper/rootfs-validation.json \
  --output installer/wrapper/install-plan.json
```

To validate the plan:

```bash
installer/scripts/validate-cidre-install-plan \
  --plan installer/wrapper/install-plan.json \
  --require-rootfs
```
