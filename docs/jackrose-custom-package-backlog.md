# Jackrose Custom Package Backlog

## Purpose
This document tracks critical packages required for the complete Jackrose desktop experience that are currently unavailable, fragile, or unverified on ALARM / aarch64.

## Priority Model
- **P0**: Default identity blockers.
- **P1**: Security workflow high-value packages.
- **P2**: Student Pack high-value tools.
- **P3**: Heavy academic or engineering-specific platforms.
- **EXP**: Experimental compatibility layer utilities.

## Backlog

### P0 Default Identity Blockers
- **ghostty**: Default Jackrose terminal. Strategy: custom `jackrose-ghostty` packaging.
- **zotero**: Academic research/writing helper. Strategy: custom repackaging.
- **zed**: Modern GUI editor. Strategy: custom packaging and verify build steps.

### P1 Security High-Value
- **trivy**: Container vulnerability scanner.
- **zizmor**: GitHub Actions static analyzer.
- **hadolint**: Dockerfile linter.
- **opengrep**: Code security analysis tool.

### P2 Student Pack High-Value
- **julia**: High performance numerical computing runtime.
- **quarto-cli**: Scientific publishing platform.
- **texlive**: Full TeX document formatting utilities.
- **obsidian**: Knowledge workspace client.
- **logseq**: Privacy-first knowledge management.
- **sagemath**: Open-source mathematical system.

### EXP Calvados Compatibility
Calvados is marked experimental and hidden from firstboot OOBE. It is App Center Experimental only.
- **wine**: Windows program loader compatibility runtime.
- **fex-emu**: Fast x86/x86_64 emulator configurations.
- **muvm**: MicroVM graphics redirection system.
- **umu-launcher**: Steam Proton game compatibility utility.
- **lutris**: Game client management platform interface.
