# Controlled Installer Boundary Probe

This document details the design and execution bounds of the controlled installer boundary probe.

---

## 1. Safety Guidelines

> [!WARNING]
> **No Execution**
> Phase 22 does not run the Asahi/ALARM installer.
> Do **not** execute bootstrap scripts, install.sh, or pipe curl outputs into shell.

---

## 2. Decision Matrix

The probe parses the environment configuration and emits one of three decisions:
- **`A_SAFE_METADATA_PATH`**: Safe selection and fetch path verified.
- **`B_NO_SAFE_DRYRUN_PATH`**: Forbidden commands (mutations) required or discovered.
- **`C_ADAPTER_OR_LAYOUT_MISMATCH`**: Schema formats or packages properties mismatch.

---

## 3. Usage

To run the boundary probe:

```bash
installer/scripts/controlled-installer-boundary-probe \
  --installer-data-url http://127.0.0.1:8765/asahi-installer-data.jackrose.dev.json \
  --repo-base http://127.0.0.1:8765 \
  --bootstrap-snapshot installer/bootstrap/upstream/asahi-bootstrap-dev.snapshot.sh
```
