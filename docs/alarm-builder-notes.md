# ALARM Builder Integration Notes

This document captures architecture notes, dependency considerations, and build-time assumptions when running under or next to the ALARM (Arch Linux ARM) image builder.

## Git Revision & Status Matching

To ensure complete traceability of builder outputs:
- The builder git revision is captured from the downstream or custom ALARM builder directory.
- This revision is embedded directly inside the `builder_revision` parameter of the Cidre image manifest.
- Working trees are checked for dirty states (untracked/uncommitted changes) to tag experimental builds appropriately.

## Staging Tree Constraints

- Staged configurations are layered on top of the base target distribution roots.
- Absolute permissions (`/usr`, `/etc`, `/var`) are preserved by packing overlays in `tar.gz` and decompressing inside the builder root.
- The standard user setup script and OOBE markers are injected into `/var/lib/cidre/firstboot-root/` directories.
