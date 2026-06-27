# Installer Metadata Wiring Guide

This document describes the adapter layer that maps Cidre internal installer metadata formats into simplified installer-facing layouts.

---

## 1. Safety Rules

> [!WARNING]
> **No Mutations**
> Phase 14 validation is a mock simulation and **does not** touch real storage devices, modify macOS boot policy configs, change partitions, or write files to disk.

---

## 2. Adapter Execution

To export simplified installer-facing metadata configurations:

```bash
installer/scripts/export-installer-metadata \
  --metadata installer/metadata/cidre-seed.local.json \
  --output installer/generated/cidre-installer-data.local.json \
  --channel local
```

To validate the generated output:

```bash
installer/scripts/validate-exported-installer-metadata \
  installer/generated/cidre-installer-data.local.json
```
