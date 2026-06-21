# Cidre Repository Separation Plan

This document outlines the migration plan to separate the Cidre experience layer repository (`Cidre`) from the compositor implementation repository (`niri-cidre`).

## 1. Current State (Monorepo-like Fork)
Currently, `Cidre` exists as a fork of the `niri` repository:
- It contains `src/`, `Cargo.toml`, `niri-*` rust crates, and the entire `niri` Git history.
- It also contains `packages/`, `docs/`, `resources/`, and draft `scripts/`.
- This causes confusion since Cidre is not merely a `niri` fork, but a full experience layer integrating many components.

## 2. Separation Target State

```text
Yasuno-5555/Cidre (This Repository)
├── README.md
├── ROADMAP.md
├── INSTALL.md
├── UNINSTALL.md
├── docs/                     # Project-wide documentation
├── config/                   # Default configuration assets (niri, fuzzel, waybar, fcitx5, ghostty, etc.)
├── scripts/                  # Bootstrap and user setup scripts (bootstrap.sh, cidre-user-setup)
├── packages/                 # Arch Linux ARM (ALARM) PKGBUILDs and package metadata
│   └── arch/
│       ├── cidre-config/
│       ├── cidre-session/
│       ├── cidre-meta-core/
│       ├── cidre-meta-desktop/
│       ├── cidre-meta-dev/
│       ├── cidre-audio/      # Sound tools
│       └── cidre-recovery/   # Recovery tools
└── tools/                    # Tool sources for cidre-recovery, cidre-audio, etc.

Yasuno-5555/niri-cidre (Compositor Repository)
├── src/                      # Compositor rust source code
├── Cargo.toml
└── ...                       # niri upstream tracking & compositor specific patches
```

## 3. Migration Steps

### Step 3.1: Repository Split
1. **Initialize `niri-cidre`**:
   - Clone the current repository to a new remote named `niri-cidre`.
   - Remove the packaging drafts (`packages/`), scripts (`scripts/`), installer planning, and high-level docs.
   - Retain the compositor code, `Cargo.toml`, `Cargo.lock`, and composer-specific history.

2. **Clean up `Cidre` (This Repository)**:
   - Remove all Rust source files: `src/`, `niri-*`, `Cargo.toml`, `Cargo.lock`, `build.rs`, `rustfmt.toml`, `clippy.toml`, `typos.toml`.
   - Remove the `target/` directory.
   - Retain and reorganize `docs/`, `packages/`, `scripts/`, `resources/` (moved to `config/`), etc.
   - Add new components: `scripts/bootstrap.sh`, `scripts/cidre-user-setup`, `config/`, tools like `cidre-recovery`, etc.

### Step 3.2: Package Source Update
- In `Cidre` repository, the PKGBUILD for `niri-cidre` will be updated to pull directly from the remote `Yasuno-5555/niri-cidre` (via Git source or release tarball), removing the local folder dependency (`_repo_root`).
- Standardize all package versions to line up with the v0.2.0 release milestones.
