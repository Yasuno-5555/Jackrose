# Final Install Contract + Dry-run Staging Plan

This document details the design and schema specifications of the wrapper final install contract and dry-run staging plan layers.

---

## 1. Safety Guidelines

> [!WARNING]
> **No Execution**
> Phase 33 does not stage files to a target disk.
> Phase 33 does not mount, format, or write target disks.
> Phase 33 does not modify boot policy.
> Phase 33 does not run the Asahi/ALARM installer.
> `final-install-contract.json` is a planning contract, **not** staging or installation authorization.
> `dry-run-staging-plan.json` is data only and contains **no** executable permission.

---

## 2. Binding and Dry-run Specifications

To bind validations and generate plan metadata:
- Consumes `rootfs-validation.json`, `install-plan.json`, and `selected-target.json`.
- Asserts that all permissions remain `false`.
- Asserts that target details classify as `safe_candidate` and `eligible=true`.
- Builds dry-run steps where all `execution_allowed` flags are set to `false`.

---

## 3. Usage

To bind final contract:

```bash
installer/scripts/bind-jackrose-final-install-contract \
  --rootfs-validation installer/wrapper/rootfs-validation.json \
  --install-plan installer/wrapper/install-plan.json \
  --selected-target installer/wrapper/selected-target.json \
  --output installer/wrapper/final-install-contract.json
```

To generate dry-run plan:

```bash
installer/scripts/generate-jackrose-dryrun-staging-plan \
  --contract installer/wrapper/final-install-contract.json \
  --output installer/wrapper/dry-run-staging-plan.json
```

To validate contract and plan:

```bash
installer/scripts/validate-jackrose-final-install-contract \
  --contract installer/wrapper/final-install-contract.json \
  --dryrun-plan installer/wrapper/dry-run-staging-plan.json
```
