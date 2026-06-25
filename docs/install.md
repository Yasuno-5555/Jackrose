# Cidre Installation Guide

Cidre installs on an existing ALARM (Arch Linux ARM) / Asahi Linux environment on Apple Silicon Macs.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/Yasuno-5555/Cidre/main/install.sh -o cidre-install.sh
bash cidre-install.sh
```

Or from a local clone:

```bash
git clone https://github.com/Yasuno-5555/Cidre.git
cd Cidre
./install.sh
```

## What install.sh does

`install.sh` is the single entry point. It delegates to `scripts/cidre-installer`, which runs through five phases:

```
Phase 0: Entry        Banner, log setup, root guard
Phase 1: Preflight    System checks (Arch, pacman, network, user, sudo)
Phase 2: Plan         Shows planned packages and config changes
Phase 3: Install      System bootstrap + user configuration
Phase 4: Verify       Runs cidre-doctor diagnostics
Phase 5: Next steps   Reboot guide, cidre-welcome prompt
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
./install.sh --doctor       # Run cidre-doctor --daily
./install.sh --repair       # Repair existing install
./install.sh --check        # Preflight checks only (no changes)
./install.sh --dry-run      # Show planned actions (no changes)

# Automation
./install.sh --desktop --yes       # Skip confirmation
./install.sh --desktop --no-confirm # Skip all except dangerous prompts

# Resume (after preinstall)
./install.sh --resume
```

## What Cidre will NOT do

Every install prints this guarantee and confirms before proceeding:

```
Cidre will NOT change:
  - macOS default boot
  - NVRAM boot order
  - boot policy
  - recovery partition
```

This confirmation is never skipped, even with `--no-confirm`.
Cidre does not register itself as the default boot target.

## Fresh ALARM Setup (root phase)

If you're starting from a fresh ALARM install with only root:

```bash
# 1. Clone and enter
git clone https://github.com/Yasuno-5555/Cidre.git
cd Cidre

# 2. Run root-phase preparation
./preinstall

# 3. Switch to normal user
su - <your-username>
cd ~/Cidre

# 4. Run user-phase install
./install.sh
```

`./preinstall` handles:
- Base package installation (git, curl, sudo, base-devel)
- Normal user creation and wheel group membership
- sudo policy configuration (`/etc/sudoers.d/cidre-wheel`)
- Network/pacman readiness checks

## Post-Install

After successful installation:

```bash
# Reboot and select Cidre session at the greeter
sudo reboot

# On first login, start the welcome tour
cidre-welcome

# Daily health checks
cidre-doctor --daily

# Repair if something breaks
cidre-repair --configs
cidre-repair --audio
cidre-repair --session
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
  ~/.local/state/cidre/install-<timestamp>.log
```

Common recovery paths:

| Problem | Recovery |
|---------|----------|
| pacman sync failed | `sudo pacman -Syy` |
| keyring outdated | `sudo pacman -Sy archlinuxarm-keyring` |
| config broken after update | `cidre-repair --configs` |
| audio not working | `cidre-repair --audio` |
| greetd won't start | `cidre-repair --session` |
| full diagnostics | `cidre-doctor --daily` |
| emergency recovery | `cidre-recovery status` |

## macOS Bootstrap (optional)

If you have macOS access and want to prepare a Cidre seed before the ALARM install:

```bash
git clone https://github.com/Yasuno-5555/Cidre
cd Cidre
./install-macos --profile developer
```

This creates a seed at `.local/state/cidre/macos-bootstrap/cidre-seed.tar.gz` that can be imported during the ALARM root phase with `./preinstall --import-seed`.

## See Also

- [INSTALL.md](../INSTALL.md) — Original install instructions
- [docs/installation.md](installation.md) — Detailed installation walkthrough
- [docs/recovery.md](recovery.md) — Full recovery procedures
- [docs/troubleshooting.md](troubleshooting.md) — Common issues
