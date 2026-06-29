# Asahi/ALARM Installer Metadata Compatibility Guide

This guide details the gap analysis between Jackrose's installer-facing metadata models and the upstream Asahi/ALARM installer requirements.

---

## 1. Safety Boundary

> [!WARNING]
> **No Execution**
> This compatibility study is for static schema validation and mapping analysis.
> Do **not** execute real installation scripts (`install.sh`, `installer-bootstrap.sh`) inside developer testing environments.

---

## 2. Upstream Architecture

The upstream installer selects target boot images using a centralized descriptor structure:
- **`os_list`**: Lists candidates containing `name`, `boot_files`, and package targets.
- **Relative URLs**: Upstream configurations often rely on relative paths (e.g. `packages/os/...`) rather than absolute URLs.

---

## 3. Compatibility Gaps

Key gaps identified:
- **Image Format**: Jackrose packages seed files directly as `.tar.zst` whereas upstream might expect split components or image package formats.
- **Firstboot variables**: Internal markers like `first_boot.mode` are ignored upstream and must be mapped to post-install setup commands.
