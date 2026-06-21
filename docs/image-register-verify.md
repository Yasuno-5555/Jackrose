# Image Register and Verify

This document outlines the validation rules applied during artifact registration and verification phases.

## Standard Layout Registration

The registration wrapper scans raw build outputs for candidate system images (`.img`, `.img.zst`, `.tar.gz`, `.raw`).
Standard output layout resolves relative symlinks to:
- `.local/state/cidre/image-build/registered/`

## Image Verification Criteria

When running `cidre-image-verify`:
- **Image File**: Must exist at the registered target path.
- **SHA256 Checksum**: Checksum file must exist and match the artifact contents.
- **Manifest Properties**: JSON schema must include version fields, git commits, and ALARM builder metadata revisions.
