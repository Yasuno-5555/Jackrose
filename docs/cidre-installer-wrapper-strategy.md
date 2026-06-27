# Cidre Installer Wrapper Strategy

This document details the pivot toward a Cidre-owned installer wrapper strategy.

---

## 1. Safety Guidelines

> [!WARNING]
> **No Execution**
> Phase 26 does not run the Asahi/ALARM installer.
> The Cidre wrapper does not execute bootstrap scripts in this phase.
> Do **not** execute install.sh or curl outputs.
> `WRAPPER_PREFLIGHT_READY` means wrapper-controlled preflight is coherent.
> It does **not** mean installation is safe yet.

---

## 2. Rationale

Since Phase 25 determined `NO_SAFE_MODE` for the upstream bootstrap snapshot (there is no public flag/dryrun support that skips installation), Cidre pivot to owning the installer wrapper. 

The wrapper:
- Runs metadata preparation.
- Verifies checksums, manifests, and structures.
- Prevents mutation calls by running danger guards.

---

## 3. Usage

To evaluate the wrapper plan:

```bash
installer/scripts/cidre-installer-wrapper-plan \
  --policy installer/wrapper/wrapper-policy.json \
  --phase24-result installer/bootstrap/notes/phase24-metadata-only-harness-result.md \
  --phase25-result installer/bootstrap/notes/phase25-safe-mode-probe-result.md
```

To run wrapper preflight validation:

```bash
installer/scripts/validate-cidre-wrapper-preflight \
  --cidre-metadata installer/generated/cidre-installer-data.dev.json \
  --repo-base http://127.0.0.1:8765 \
  --bootstrap-snapshot installer/bootstrap/fixtures/minimal-bootstrap-sample.sh \
  --policy installer/wrapper/wrapper-policy.json
```
