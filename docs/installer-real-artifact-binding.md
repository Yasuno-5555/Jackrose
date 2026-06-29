# Installer Real Artifact Binding Guide

This guide details the integration verification processes for linking assembled local image archives to installer metadata configurations.

---

## 1. Prerequisites

Before binding, ensure Phase 10 has generated the required target artifacts:
- `out/jackrose-seed-aarch64-v0.10.0.tar.zst`
- `out/jackrose-seed-aarch64-v0.10.0.manifest`

---

## 2. Binding Workflow

### 2.1. Executing Updates
The binding utility computes sizes and sha256 checksums from the build artifacts, backing up the current metadata state:

```bash
installer/scripts/bind-local-seed-artifact \
  --metadata installer/metadata/jackrose-seed.local.json \
  --id jackrose-seed-aarch64 \
  --image out/jackrose-seed-aarch64-v0.10.0.tar.zst \
  --manifest out/jackrose-seed-aarch64-v0.10.0.manifest \
  --channel local
```

### 2.2. Validating Selection Contracts
Validate matching parameters using the simulator in strict real-artifact checking mode:

```bash
installer/scripts/simulate-installer-selection \
  --metadata installer/metadata/jackrose-seed.local.json \
  --id jackrose-seed-aarch64 \
  --verify-artifact \
  --require-real-artifact
```
