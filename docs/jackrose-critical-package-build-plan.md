# Jackrose Critical Package Build Plan

## Purpose
This document defines custom package build configurations and recovery steps for P0 Jackrose Default critical tools on ALARM / aarch64.

## P0 Tools
- **paru**: AUR helper and development recovery escape hatch.
- **ghostty**: Default GPU-accelerated terminal emulator interface.
- **zotero**: Essential reference manager for research workflows.
- **zed**: Modern graphical coding editor candidate.

## Build Plan Status
All critical packaging definitions undergo standard integration validation gating levels before being promoted into `jackrose-meta-default`:
1. **Planned**: Backlog entry defined.
2. **Packaged**: PKGBUILD skeleton created.
3. **Validated**: Build validation checks pass.
4. **Enabled**: Hard dependency active in default.

## J14 ghostty status
- **jackrose-paru**: Validated. Artifact generated, provides paru, conflicts defined cleanly. Meta integration gated as candidate-for-meta-default.
- **jackrose-ghostty**: Source pinned to upstream `1.3.1` release tarball with checksum. Real dogfood build now passes on `aarch64`, and artifact validation passes. J17 removed the bundled terminfo conflict with `ncurses` and rebuilt the package as `1.3.1-2`. Local install test remains blocked by the current environment's `sudo` restrictions, so official meta integration remains gated.
- **jackrose-zotero**: Planned.
- **jackrose-zed**: Planned.
