# Jackrose Installation Guide

Jackrose installs on an existing ALARM (Arch Linux ARM) / Asahi Linux environment on Apple Silicon Macs.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/Yasuno-5555/Jackrose/main/install.sh -o jackrose-install.sh
bash jackrose-install.sh
```

Or from a local clone:

```bash
git clone https://github.com/Yasuno-5555/Jackrose.git
cd Jackrose
./install.sh
```

## What install.sh does

`install.sh` is the single entry point. It delegates to `scripts/jackrose-installer`, which runs through five phases:

```
Phase 0: Entry        Banner, log setup, root guard
Phase 1: Preflight    System checks (Arch, pacman, network, user, sudo)
Phase 2: Plan         Shows planned packages and config changes
Phase 3: Install      System bootstrap + user configuration
Phase 4: Verify       Runs jackrose-doctor diagnostics
Phase 5: Next steps   Reboot guide, jackrose-welcome prompt
```

## Profiles

| Flag | Profile | Contents |
|------|---------|----------|
| `--desktop` | Desktop | Niri, Ghostty, waybar, fcitx5 Mozc, audio profiles |
| `--dev` | Developer | Desktop + fish, starship, dev toolchain |
| `--student` | Student | Lightweight desktop, educational focus |
| `--minimal` | Minimal | Core session manager and niri config only |

If no flag is given, an interactive menu lets you choose.

## Command Reference

```bash
# Full install (interactive profile selection)
./install.sh

# Direct profile install
./install.sh --desktop
./install.sh --dev
./install.sh --student
./install.sh --minimal

# Diagnostics and repair
./install.sh --doctor       # Run jackrose-doctor --daily
./install.sh --repair       # Repair existing install
./install.sh --check        # Preflight checks only (no changes)
./install.sh --dry-run      # Show planned actions (no changes)

# Automation
./install.sh --desktop --yes       # Skip confirmation
./install.sh --desktop --no-confirm # Skip all except dangerous prompts

# Resume (after preinstall)
./install.sh --resume
```

## What Jackrose will NOT do

Every install prints this guarantee and confirms before proceeding:

```
Jackrose will NOT change:
  - macOS default boot
  - NVRAM boot order
  - boot policy
  - recovery partition
```

This confirmation is never skipped, even with `--no-confirm`.
Jackrose does not register itself as the default boot target.

## Fresh ALARM Setup (root phase)

If you're starting from a fresh ALARM install with only root:

```bash
# 1. Clone and enter
git clone https://github.com/Yasuno-5555/Jackrose.git
cd Jackrose

# 2. Run root-phase preparation
./preinstall

# 3. Switch to normal user
su - <your-username>
cd ~/Jackrose

# 4. Run user-phase install
./install.sh
```

`./preinstall` handles:
- Base package installation (git, curl, sudo, base-devel)
- Normal user creation and wheel group membership
- sudo policy configuration (`/etc/sudoers.d/jackrose-wheel`)
- Network/pacman readiness checks

## Post-Install

After successful installation:

```bash
# Reboot and select Jackrose session at the greeter
sudo reboot

# On first login, start the welcome tour
jackrose-welcome

# Daily health checks
jackrose-doctor --daily

# Repair if something breaks
jackrose-repair --configs
jackrose-repair --audio
jackrose-repair --session
```

## Failure Recovery

Every failure message follows a consistent pattern:

```
[FAILED] <what happened>

Likely causes:
  - <reason 1>
  - <reason 2>

Try:
  <recovery command 1>
  <recovery command 2>

Log:
  ~/.local/state/jackrose/install-<timestamp>.log
```

Common recovery paths:

| Problem | Recovery |
|---------|----------|
| pacman sync failed | `sudo pacman -Syy` |
| keyring outdated | `sudo pacman -Sy archlinuxarm-keyring` |
| config broken after update | `jackrose-repair --configs` |
| audio not working | `jackrose-repair --audio` |
| greetd won't start | `jackrose-repair --session` |
| full diagnostics | `jackrose-doctor --daily` |
| emergency recovery | `jackrose-recovery status` |

## macOS Bootstrap (optional)

If you have macOS access and want to prepare a Jackrose seed before the ALARM install:

```bash
git clone https://github.com/Yasuno-5555/Jackrose
cd Jackrose
./install-macos --profile developer
```

This creates a seed at `.local/state/jackrose/macos-bootstrap/jackrose-seed.tar.gz` that can be imported during the ALARM root phase with `./preinstall --import-seed`.

## See Also

- [INSTALL.md](../INSTALL.md) — Original install instructions
- [docs/installation.md](installation.md) — Detailed installation walkthrough
- [docs/recovery.md](recovery.md) — Full recovery procedures
- [docs/troubleshooting.md](troubleshooting.md) — Common issues
