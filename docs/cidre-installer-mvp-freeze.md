# Controlled Staging Apply + First Boot Handoff + Installer MVP Freeze

This document details the design and schema specifications of the wrapper controlled staging apply, post-staging validation, first-boot/recovery handoff, and MVP freeze layers.

---

## 1. Safety Guidelines

> [!WARNING]
> **MVP Safety Restrictions**
> Phase 34 does not format partitions.
> Phase 34 does not modify boot policy.
> Phase 34 does not change default boot.
> Phase 34 does not run the upstream Asahi/ALARM installer.
> Controlled staging apply may write to the selected target only when `--apply` and the exact confirmation string (`APPLY JACKROSE STAGING TO SELECTED TARGET`) are provided.

---

## 2. Staging Apply and Validation Specifications

To perform rootfs staging:
- Validates inputs `final-install-contract.json` and `dry-run-staging-plan.json`.
- Requires exact confirmation string match.
- Mounts target, stages rootfs (`rsync` or `cp`), syncs, and unmounts target.
- Post-staging validation confirms rootfs directory layout (`usr/`, `etc/`, `var/`, `usr/share/jackrose/defaults/`) and core scripts.

---

## 3. Usage

To run target staging apply:

```bash
installer/scripts/jackrose-wrapper-stage-target \
  --contract installer/wrapper/final-install-contract.json \
  --dryrun-plan installer/wrapper/dry-run-staging-plan.json \
  --confirm "APPLY JACKROSE STAGING TO SELECTED TARGET" \
  --output installer/wrapper/staging-result.json \
  --apply
```

To run post-staging validation:

```bash
installer/scripts/validate-jackrose-staged-target \
  --staging-result installer/wrapper/staging-result.json \
  --output installer/wrapper/staged-target-validation.json
```

To generate first-boot handoff contract:

```bash
installer/scripts/generate-jackrose-firstboot-handoff \
  --staged-validation installer/wrapper/staged-target-validation.json \
  --output installer/wrapper/firstboot-handoff.json
```

To freeze installer MVP:

```bash
installer/scripts/freeze-jackrose-installer-mvp \
  --staging-result installer/wrapper/staging-result.json \
  --staged-validation installer/wrapper/staged-target-validation.json \
  --firstboot-handoff installer/wrapper/firstboot-handoff.json \
  --output installer/wrapper/installer-mvp-freeze.json
```
