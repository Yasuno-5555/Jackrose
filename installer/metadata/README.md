# Cidre Installer Metadata Workspace

This directory contains installer metadata schemas, fixtures, and validators.

---

## 1. Schema Validation

To validate the current metadata layout, run the validator script:

```bash
installer/scripts/validate-installer-metadata installer/metadata/cidre-seed.local.json
```

---

## 2. Release Requirements

- A `release` channel entry **must never** use a placeholder checksum like `PLACEHOLDER_SHA256`.
- Only `local` or `dev` channels are permitted to bypass checksum validation warnings.
- The default URL structure uses `file://` schemes for local testing.
