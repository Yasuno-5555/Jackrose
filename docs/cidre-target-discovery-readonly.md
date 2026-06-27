# Install Target Discovery and Read-only Validation

This document details the design and schema specifications of the wrapper install target discovery and read-only validation layers.

---

## 1. Safety Guidelines

> [!WARNING]
> **No Target Selection or Mutation**
> Phase 31 does not select an install target.
> Phase 31 does not stage files to a target disk.
> Phase 31 does not mount or write target disks.
> Phase 31 does not run the Asahi/ALARM installer.
> `target-candidates.json` is a read-only discovery record, **not** target selection authorization.

---

## 2. Discovery and Classification Specifications

To safely search for install candidate partitions, the discovery script:
- Invokes read-only queries (`lsblk --json` or `diskutil list`).
- Classifies each candidate as `safe_candidate`, `unsafe_active_system`, `unsafe_efi`, etc.
- Rejects partitions below the 32 GiB (34,359,738,368 bytes) minimum.
- Forbids selection or staging permissions (`target_selected: false`, etc.).

---

## 3. Usage

To run read-only target discovery:

```bash
installer/scripts/cidre-wrapper-discover-targets \
  --install-plan installer/wrapper/install-plan.json \
  --output installer/wrapper/target-candidates.json
```

To validate target candidates config:

```bash
installer/scripts/validate-cidre-target-candidates \
  --candidates installer/wrapper/target-candidates.json
```
