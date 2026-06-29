# Wrapper Artifact Fetch and Integrity Verification

This document details the design and schema specifications of the wrapper artifact fetch and integrity verification layers.

---

## 1. Safety Guidelines

> [!WARNING]
> **No Execution**
> Phase 28 does not run the Asahi/ALARM installer.
> Phase 28 does not extract the Jackrose rootfs artifact.
> Phase 28 does not mount or write target disks.
> Do **not** execute bootstrap scripts, install.sh, or curl outputs.
> `verified-artifact.json` is an integrity verification record, **not** an extraction or installation authorization.

---

## 2. Verification Specifications

To verify integrity without unpacking any files, the wrapper fetches the targets and writes a `verified-artifact.json` containing:
- artifact_path, manifest_path, artifact_size_bytes.
- sha256_expected, sha256_actual, sha256_verified=true.
- `extract_allowed: false` (strictly locked).
- `install_allowed: false` (strictly locked).

---

## 3. Usage

To fetch and verify an artifact:

```bash
installer/scripts/jackrose-wrapper-fetch-artifact \
  --selection installer/wrapper/selected-image.json \
  --download-dir /tmp/jackrose-wrapper-artifact \
  --output installer/wrapper/verified-artifact.json
```

To validate the verified file:

```bash
installer/scripts/validate-jackrose-wrapper-artifact \
  --artifact installer/wrapper/verified-artifact.json \
  --require-files
```
