# Jackrose Welcome OOBE Contract

## Purpose
This document defines the OOBE (Out-Of-Box Experience) contract for Jackrose Linux. Jackrose Welcome operates in `--firstboot` mode to guide users through the initial configuration of their Jackrose installation.

## Key Principles
1. **Opinionated Defaults**: The core desktop environment (`jackrose-meta-default`) is installed automatically. Users are not given the option to customize terminal utilities, shells, input methods, or terminal clients during the OOBE.
2. **Additional Workload Packs**: Users can selectively enable curated packs like:
   - `Student Pack` (Academic/Scientific/Creative tools, checked by default)
   - `Security Pack` (Security tools requiring external repository enablement, unchecked by default)
   - `Calvados Compatibility Pack` (Windows/legacy application compatibility layers, unchecked by default)
3. **No Direct Package Mutation**: Welcome must call backend utilities (`jackrose-pack`, `jackrose-security`) to formulate installation plans, apply changes, and record states. It does not construct raw `pacman` commands or run strap scripts.
4. **Boot and Disk Safety**: No APFS, partition, m1n1, GRUB, or EFI boot changes are performed under any circumstances.
