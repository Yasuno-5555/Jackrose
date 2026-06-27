# Release Asset Hosting Guide

This document describes how Cidre addresses and verifies hosted release assets.

---

## 1. Hosting Strategy

Cidre utilizes GitHub Releases as the primary hosting model for compiled seed image archives and manifest properties.
- **Metadata**: Distributed via raw repository files or GitHub Pages.
- **Images**: Bound to tag-specific release assets (e.g. `https://github.com/Yasuno-5555/Cidre/releases/download/...`).

---

## 2. Dev Serving Mock

For local development simulation, a Python HTTP server is started inside the workspace folder:

```bash
installer/scripts/serve-local-release-assets --directory out --port 8765
```

---

## 3. URL Verification

Hosted assets can be validated using the remote verification tool:

```bash
installer/scripts/verify-hosted-release-assets \
  --metadata installer/generated/cidre-installer-data.dev.json \
  --id cidre-seed-aarch64
```
