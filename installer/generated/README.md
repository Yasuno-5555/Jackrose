# Mapped Installer-Facing Metadata Outputs

This directory contains simplified JSON schemas designed to drive future Asahi-style installation workflows.

---

## 1. Schema Validation

To validate the mapped metadata format:

```bash
installer/scripts/validate-exported-installer-metadata installer/generated/cidre-installer-data.local.json
```

---

## 2. Warnings

- All release configurations must compute valid SHA256 checksums and cannot utilize placeholder keys.
- Paths point to local file archives (`file://` schemes) during developer simulation testing.
