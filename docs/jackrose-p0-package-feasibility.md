# Jackrose P0 Package Feasibility

## Purpose
This document records the results of non-destructive feasibility probes for Jackrose P0 critical recovery packages on ALARM / aarch64.

## Feasibility Matrix
Static PKGBUILD metadata parameters, source fetch URLs, and dependency tracking structures are mapped under [p0-feasibility.tsv](file:///home/yasuno/Projects/Jackrose/resources/package-audit/p0-feasibility.tsv).

## Package Details

### jackrose-paru
- **Source strategy**: repackage from AUR.
- **Build feasibility**: High (clean Go/Rust tools base).
- **Redistribution issues**: None.

### jackrose-ghostty
- **Source strategy**: upstream release tarball from `release.files.ghostty.org`.
- **Build feasibility**: Medium/High after J15 artifact build success on `aarch64`; J17 removed the bundled terminfo conflict by depending on `ncurses` and rebuilding as `1.3.1-2`. Install test still pending a root-capable dogfood run.
- **Redistribution issues**: None.

### jackrose-zotero
- **Source strategy**: manual repackaging from official binary tarball.
- **Build feasibility**: Low (upstream binary does not target aarch64 natively; requires Electron bundle modifications).
- **Redistribution issues**: Requires upstream license review.

### jackrose-zed
- **Source strategy**: upstream rust source compilation.
- **Build feasibility**: Low/Medium (heavy C++ / rust GPU framework dependencies).
- **Redistribution issues**: None.

## J12 Build Feasibility Status
- **jackrose-paru**: Build verified. Static checks completed on compiled package file successfully. Status changed to build-validated.
- **jackrose-ghostty**: Real build verified on dogfood `aarch64`. J17 rebuilt the artifact without ncurses-owned terminfo content and validation passed. Local `pacman -U` install remains blocked by the current environment's root restrictions rather than by package content.
- **jackrose-zotero**: Probed. Requires upstream redistributability and license validation manual checks.
- **jackrose-zed**: Probed. Static metadata only.
