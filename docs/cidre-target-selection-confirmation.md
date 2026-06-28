# Target Selection Gate + Confirmation Contract

This document details the design and schema specifications of the wrapper target selection and confirmation contract layers.

---

## 1. Safety Guidelines

> [!WARNING]
> **No Target Mutation**
> Phase 32 does not stage files to a target disk.
> Phase 32 does not mount, format, or write target disks.
> Phase 32 does not run the Asahi/ALARM installer.
> `selected-target.json` is a selection record, **not** staging or installation authorization.

---

## 2. Selection and Confirmation Specifications

To safely commit an eligible partition for future steps:
- Resolves candidates using `target-candidates.json`.
- Matches exactly one `safe_candidate` partition matching the provided `--target-id`.
- Requires exact confirmation string: `SELECT CIDRE TARGET ONLY - NO INSTALL`.
- Emits locks (`mount_allowed=false`, `format_allowed=false`, etc.).

---

## 3. Usage

To run target selection:

```bash
installer/scripts/cidre-wrapper-select-target \
  --candidates installer/wrapper/target-candidates.json \
  --target-id disk-example-1 \
  --confirm "SELECT CIDRE TARGET ONLY - NO INSTALL" \
  --output installer/wrapper/selected-target.json
```

To validate the selected target:

```bash
installer/scripts/validate-cidre-selected-target \
  --selected-target installer/wrapper/selected-target.json
```
