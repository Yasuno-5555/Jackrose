# Installer Metadata Convention

This document outlines the naming conventions, structures, and schemas designed to expose Cidre seed images to ALARM-style installer frameworks.

---

## 1. Naming Conventions

### 1.1. Local Image Artifacts
Assembled images are tagged with version numbers and architectures to ensure clear upgrade tracking:

- **Image Archive**: `cidre-seed-aarch64-v<version>.tar.zst`
- **Checksum Reference**: `cidre-seed-aarch64-v<version>.tar.zst.sha256`
- **Manifest Metadata**: `cidre-seed-aarch64-v<version>.manifest`

Example layout for version `0.10.0`:
- `cidre-seed-aarch64-v0.10.0.tar.zst`
- `cidre-seed-aarch64-v0.10.0.tar.zst.sha256`
- `cidre-seed-aarch64-v0.10.0.manifest`

---

## 2. Channels

Cidre metadata defines three distinct release channels:
- `local`: Internal developer builds utilizing local file targets (`file://` schemes).
- `dev`: Pre-releases staging environments.
- `release`: Stable builds featuring finalized, non-placeholder cryptographic checksums.
