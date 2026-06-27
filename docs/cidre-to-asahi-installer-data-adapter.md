# Cidre-to-Asahi Installer Data Adapter

This document details the prototype adapter mapping Cidre metadata to an Asahi-like `installer_data.json` layout.

---

## 1. Safety Warning

> [!WARNING]
> **Prototype Data**
> The generated adapter files must **not** be used against real systems.
> This phase is for mapping verification and dry-run selection simulation.

---

## 2. Mapping Scheme

The exporter transforms Cidre targets to Asahi-like candidate lists:
- **`os_list`**: The target installer list populated from Cidre image definitions.
- **`_warning`**: Explicit warning parameters appended to all output files.

---

## 3. Usage

To convert Cidre metadata:

```bash
installer/scripts/export-asahi-installer-data \
  --input installer/generated/cidre-installer-data.dev.json \
  --output installer/generated/asahi-installer-data.cidre.dev.json \
  --channel dev
```
