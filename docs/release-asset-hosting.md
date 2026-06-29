# Release Asset Hosting Guide

This document describes how Jackrose addresses and verifies hosted release assets.

---

## 1. Hosting Strategy

Jackrose utilizes GitHub Releases as the primary hosting model for compiled seed image archives and manifest properties.
- **Metadata**: Distributed via raw repository files or GitHub Pages.
- **Images**: Bound to tag-specific release assets (e.g. `https://github.com/Yasuno-5555/Jackrose/releases/download/...`).

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
  --metadata installer/generated/jackrose-installer-data.dev.json \
  --id jackrose-seed-aarch64
```

---

## 4. Hosted Dev Artifact Fetch

Jackrose utilizes `verify-dev-release-fetch` to query hosted dev release tags (e.g. `v0.10.0-dev`).
It fetches image binaries over HTTPS using `curl -L`, validating sizes and SHA256 checksums before resolving candidates. Strict checking mode rejects placeholder checksum parameters.

---

## 5. Relationship to Asahi/ALARM Installer Data

Jackrose's hosted release assets must ultimately map to the metadata model used by the Asahi/ALARM installer bootstrap flow.
Phase 17 studies this layout to ensure that Jackrose's exported structures can translate into the upstream ecosystem without manual patching.
