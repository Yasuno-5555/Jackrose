# Dev Release Artifact Checklist

This document details the manual steps required to compile, assemble, metadata-bind, upload, and verify a hosted dev release.

---

## 1. Local Staging Steps

1. **Compile packages**:
   ```bash
   scripts/dev/build-jackrose-packages --build
   scripts/dev/collect-jackrose-packages --clean
   ```
2. **Assemble seed image**:
   ```bash
   image/build-jackrose-seed-image.sh --profile jackrose-seed --apply
   ```
3. **Bind metadata**:
   ```bash
   installer/scripts/bind-local-seed-artifact \
     --metadata installer/metadata/jackrose-seed.local.json \
     --id jackrose-seed-aarch64 \
     --image out/jackrose-seed-aarch64-v0.10.0.tar.zst \
     --manifest out/jackrose-seed-aarch64-v0.10.0.manifest \
     --channel local
   ```
4. **Export installer-facing metadata**:
   ```bash
   installer/scripts/export-installer-metadata \
     --metadata installer/metadata/jackrose-seed.local.json \
     --output installer/generated/jackrose-installer-data.local.json \
     --channel local
   ```

---

## 2. Release Asset Mapping and Uploading

1. **Map metadata URL endpoints**:
   ```bash
   installer/scripts/prepare-dev-release-assets \
     --layout installer/release/jackrose-release-layout.dev.json \
     --metadata installer/generated/jackrose-installer-data.local.json \
     --output installer/generated/jackrose-installer-data.dev.json \
     --print-gh-command
   ```
2. **Upload assets manually using GitHub CLI**:
   ```bash
   gh release upload v0.10.0-dev \
     out/jackrose-seed-aarch64-v0.10.0.tar.zst \
     out/jackrose-seed-aarch64-v0.10.0.tar.zst.sha256 \
     out/jackrose-seed-aarch64-v0.10.0.manifest \
     installer/generated/jackrose-installer-data.dev.json
   ```

---

## 3. Remote Verification

1. **Verify hosted dev metadata fetch**:
   ```bash
   installer/scripts/verify-dev-release-fetch \
     --metadata installer/generated/jackrose-installer-data.dev.json \
     --id jackrose-seed-aarch64 \
     --strict
   ```
