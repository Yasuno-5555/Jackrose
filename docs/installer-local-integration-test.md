# Installer Metadata Local Integration Test Guide

This document describes the simulation testing framework designed to verify that Jackrose's installer metadata can drive future Asahi-style installation workflows.

---

## 1. Safety Rules

> [!WARNING]
> **No Mutations**
> Phase 12 validation is a mock simulation and **does not** touch real storage devices, modify macOS boot policy configs, change partitions, or write files to disk.

---

## 2. Test Commands

To perform local integration checks:

```bash
# Validate local entries matching constraints
installer/scripts/list-installer-entries --metadata installer/metadata/jackrose-seed.local.json

# Run all test pipelines (positive/negative verification)
installer/scripts/run-local-integration-tests
```
