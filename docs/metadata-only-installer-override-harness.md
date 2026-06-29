# Metadata-only Installer Override Harness

This document details the design and execution bounds of the metadata-only installer override harness.

---

## 1. Safety Guidelines

> [!WARNING]
> **No Execution**
> Phase 24 does not run the Asahi/ALARM installer.
> Do **not** execute bootstrap scripts, install.sh, or pipe curl outputs into shell.
> `A_SAFE_METADATA_PATH` means Jackrose’s metadata-only override chain is coherent.
> It does **not** prove real installer compatibility.

---

## 2. Override Harness

The harness encapsulates:
- Exporter and Normalizer steps.
- Local HTTP serve.
- Controlled Boundary Probe step.
- Variable block prints on success.

---

## 3. Usage

To run the harness:

```bash
installer/scripts/metadata-only-installer-override-harness \
  --jackrose-metadata installer/generated/jackrose-installer-data.dev.json \
  --repo-base http://127.0.0.1:8765 \
  --port 8765 \
  --bootstrap-snapshot installer/bootstrap/fixtures/minimal-bootstrap-sample.sh
```
