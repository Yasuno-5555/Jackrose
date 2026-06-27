# Artifact Structure Inspection + Safe Extraction Sandbox

This document details the design and schema specifications of the wrapper artifact structure inspection and sandbox extraction layers.

---

## 1. Safety Guidelines

> [!WARNING]
> **No Execution**
> Phase 29 does not run the Asahi/ALARM installer.
> Phase 29 does not stage files to a target disk.
> Phase 29 does not mount or write target disks.
> Phase 29 extracts only into a temporary sandbox directory.
> `extracted-rootfs.json` is a sandbox validation record, **not** an installation authorization.

---

## 2. Extraction Sandbox Specifications

To safely inspect and verify the contents of the archive before target execution, the wrapper does:
- Lists target files and inspects rootfs pathways.
- Rejects paths containing absolute/relative traversals (`/`, `..`).
- Rejects forbidden firstboot markers.
- Unpacks only into a controlled sandbox directory.

---

## 3. Usage

To inspect an archive:

```bash
installer/scripts/cidre-wrapper-inspect-artifact \
  --artifact installer/wrapper/verified-artifact.json \
  --output installer/wrapper/artifact-structure.json
```

To extract to a temporary sandbox:

```bash
installer/scripts/cidre-wrapper-extract-sandbox \
  --artifact installer/wrapper/verified-artifact.json \
  --structure installer/wrapper/artifact-structure.json \
  --sandbox-dir /tmp/cidre-wrapper-extract \
  --output installer/wrapper/extracted-rootfs.json
```

To validate the extracted rootfs:

```bash
installer/scripts/validate-cidre-wrapper-extracted-rootfs \
  --extracted installer/wrapper/extracted-rootfs.json \
  --require-files
```
