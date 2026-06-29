# Jackrose-to-Asahi Installer Data Adapter

This document details the prototype adapter mapping Jackrose metadata to an Asahi-like `installer_data.json` layout.

---

## 1. Safety Warning

> [!WARNING]
> **Prototype Data**
> The generated adapter files must **not** be used against real systems.
> This phase is for mapping verification and dry-run selection simulation.

---

## 2. Mapping Scheme

The exporter transforms Jackrose targets to Asahi-like candidate lists:
- **`os_list`**: The target installer list populated from Jackrose image definitions.
- **`_warning`**: Explicit warning parameters appended to all output files.

---

## 3. Usage

To convert Jackrose metadata:

```bash
installer/scripts/export-asahi-installer-data \
  --input installer/generated/jackrose-installer-data.dev.json \
  --output installer/generated/asahi-installer-data.jackrose.dev.json \
  --channel dev
```
