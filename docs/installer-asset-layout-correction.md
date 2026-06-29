# Installer Asset Layout Correction

This document details the normalization and validation rules of Jackrose installer asset layouts.

---

## 1. Safety Guidelines

> [!WARNING]
> **No Execution**
> Phase 23 does not run the Asahi/ALARM installer.
> Do **not** execute bootstrap scripts, install.sh, or pipe curl outputs into shell.

---

## 2. Asset Layout Policy

Jackrose defines accepted artifact structures in [asset-layout-policy.json](file:///Users/yasuno/Projects/Jackrose/installer/metadata/asset-layout-policy.json):
- **`.tar.zst`** is accepted for Jackrose boundary probing.
- This does **not** prove upstream installer compatibility.

---

## 3. Usage

To normalize generated metadata:

```bash
installer/scripts/normalize-installer-asset-layout \
  --input installer/generated/asahi-installer-data.jackrose.dev.json \
  --output installer/generated/asahi-installer-data.jackrose.dev.normalized.json \
  --repo-base http://127.0.0.1:8765
```

To validate layout:

```bash
installer/scripts/validate-installer-asset-layout \
  --metadata installer/generated/asahi-installer-data.jackrose.dev.normalized.json \
  --repo-base http://127.0.0.1:8765
```
