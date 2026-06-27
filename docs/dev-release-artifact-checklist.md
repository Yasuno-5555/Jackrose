# Dev Release Artifact Checklist

This document details the manual steps required to compile, assemble, metadata-bind, upload, and verify a hosted dev release.

---

## 1. Local Staging Steps

1. **Compile packages**:
   ```bash
   scripts/dev/build-cidre-packages --build
   scripts/dev/collect-cidre-packages --clean
   ```
2. **Assemble seed image**:
   ```bash
   image/build-cidre-seed-image.sh --profile cidre-seed --apply
   ```
3. **Bind metadata**:
   ```bash
   installer/scripts/bind-local-seed-artifact \
     --metadata installer/metadata/cidre-seed.local.json \
     --id cidre-seed-aarch64 \
     --image out/cidre-seed-aarch64-v0.10.0.tar.zst \
     --manifest out/cidre-seed-aarch64-v0.10.0.manifest \
     --channel local
   ```
4. **Export installer-facing metadata**:
   ```bash
   installer/scripts/export-installer-metadata \
     --metadata installer/metadata/cidre-seed.local.json \
     --output installer/generated/cidre-installer-data.local.json \
     --channel local
   ```

---

## 2. Release Asset Mapping and Uploading

1. **Map metadata URL endpoints**:
   ```bash
   installer/scripts/prepare-dev-release-assets \
     --layout installer/release/cidre-release-layout.dev.json \
     --metadata installer/generated/cidre-installer-data.local.json \
     --output installer/generated/cidre-installer-data.dev.json \
     --print-gh-command
   ```
2. **Upload assets manually using GitHub CLI**:
   ```bash
   gh release upload v0.10.0-dev \
     out/cidre-seed-aarch64-v0.10.0.tar.zst \
     out/cidre-seed-aarch64-v0.10.0.tar.zst.sha256 \
     out/cidre-seed-aarch64-v0.10.0.manifest \
     installer/generated/cidre-installer-data.dev.json
   ```

---

## 3. Remote Verification

1. **Verify hosted dev metadata fetch**:
   ```bash
   installer/scripts/verify-dev-release-fetch \
     --metadata installer/generated/cidre-installer-data.dev.json \
     --id cidre-seed-aarch64 \
     --strict
   ```
