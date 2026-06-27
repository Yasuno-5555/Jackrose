# Compatibility Gaps Report

This document outlines structural blockers between Cidre's definitions and upstream Asahi installer requirements.

## 1. Seed Image Archive Format
- **Description**: Cidre packs rootfs as single `.tar.zst` files.
- **Risk**: Upstream installers may enforce multi-part split layers or rootfs images formats.
- **Solution**: Study target validation formats before forking real code blocks.

## 2. Relative URLs
- **Description**: Cidre specifies absolute `url` paths. Upstream may expect relative layout offsets from repository base roots.
- **Solution**: Apply path rewrites during adapter transformations phases.

---

## 3. Phase 18 Adapter Findings

- **Prototype Mappings**: The adapter can generate an Asahi-like `os_list` entry. However, the output remains prototype-only.
- **Archive format**: Real installer package/archive expectations remain unresolved.
- **Cidre extensions**: `first_boot_mode` is Cidre-specific and may not be consumed by the upstream installer.
