# Cidre Installation Guide

This document describes how to bootstrap the Cidre experience layer on an Apple Silicon Mac running Arch Linux ARM (ALARM) / Asahi Linux.

## Requirements
- An Apple Silicon Mac (M1/M2/M3)
- A clean install of Asahi ALARM / Arch Linux ARM (Minimal image)
- Working internet connection

## Installer Command reference

The `bootstrap.sh` script provides multiple execution modes to check dependencies and dry-run the installation safely:

### 1. Help Menu
To see all available options:
```bash
./scripts/bootstrap.sh --help
```

### 2. Preflight Dependency Checks
To verify the system architecture and required CLI tools (`pacman`, `sed`, `locale-gen`, etc.) without altering the system:
```bash
./scripts/bootstrap.sh --check
```

### 3. Dry-Run Installation
To inspect all commands that would be executed (including keymaps, locale generation, package installations, and config copying) without changing the state:
```bash
./scripts/bootstrap.sh --dry-run
```

### 4. Direct Installation
To run the full setup:
```bash
sudo ./scripts/bootstrap.sh --install
```
Follow the interactive prompts to define your username and login credentials.

## Post-Install User Environment Setup

After the bootstrapper completes:
1. Reboot the system.
2. Log into the desktop session.
3. Deploy configuration profiles to your home directory:
   ```bash
   # Deploys standard developer tools (fish, starship prompt, waybar, fcitx5 Mozc, fuzzel)
   cidre-user-setup apply --profile developer
   ```
