# Jackrose Installation Guide (v0.2.0)

This document describes how to install the Jackrose experience layer on an Apple Silicon Mac running Arch Linux ARM (ALARM) / Asahi Linux.

## Requirements
- An Apple Silicon Mac (M1/M2/M3)
- A clean install of Asahi ALARM / Arch Linux ARM (Minimal image)
- Working internet connection

## Installation Steps

1. Run the bootstrap script:
   ```bash
   curl -L https://raw.githubusercontent.com/Yasuno-5555/Jackrose/main/scripts/bootstrap.sh | sh
   ```
2. Follow the interactive prompts to set up your username and password. The script will:
   - Configure local keyboard layouts (`jp106`)
   - Configure timezone (`Asia/Tokyo`) and locale (`ja_JP.UTF-8` / `en_US.UTF-8`)
   - Update pacman keyrings
   - Install required desktop and IME tools
   - Configure and enable `greetd` and `NetworkManager`
3. Reboot the machine.
4. Log into the system using the username and password created.
5. Deploy configuration defaults into your home directory:
   ```bash
   jackrose-user-setup
   ```

Now your Japanese input layout, Waybar, fuzzel launcher, and Ghostty terminal are ready for use.
