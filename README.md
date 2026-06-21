<h1 align="center"><img alt="Cidre" src="https://github.com/user-attachments/assets/07d05cd0-d5dc-4a28-9a35-51bae8f119a0"></h1>
<p align="center"><strong>The cider after Homebrew.</strong></p>
<p align="center">Cidre is an opinionated Arch Linux ARM developer environment for Apple Silicon Macs.</p>
<p align="center">
    <a href="https://github.com/Yasuno-5555/Cidre">GitHub</a>
    |
    <a href="./LICENSE">License</a>
</p>

<p align="center">
    <a href="./INSTALL.md">Install Cidre</a> | <a href="./SUPPORTED_HARDWARE.md">Supported Hardware</a> | <a href="./RECOVERY.md">Recovery</a> | <a href="./CONFIGURATION.md">Configuration</a> | <a href="./KNOWN_LIMITATIONS.md">Known Limitations</a> | <a href="./ISSUE_REPORTING.md">Issue Reporting</a> | <a href="./docs/cidre-v1-scope.md">Cidre v1.0 Scope</a> | <a href="./docs/cidre-v1-release-plan.md">Release Plan</a> | <a href="./docs/cidre-v1-release-checklist.md">Release Checklist</a> | <a href="./docs/niri-cidre-config.md">niri-cidre Config Notes</a> | <a href="https://niri-wm.github.io/niri/Getting-Started.html">niri Background Docs</a>
</p>

<img width="1280" height="720" alt="Cidre desktop session on Apple Silicon" src="https://github.com/user-attachments/assets/dea5909e-1859-4aaa-9d88-d37f9663e00b" />

## What Is Cidre?

Cidre is an opinionated Arch Linux ARM developer environment for Apple Silicon Macs.

It exists for people who like MacBook hardware, but want a Linux development machine instead of macOS. The goal is not to recreate macOS. The goal is to turn Apple Silicon Mac hardware into a ready-to-use workstation for development, writing, research, and Linux experimentation.

In short:

> Cidre turns a MacBook into an Arch-style Linux developer machine.

Core direction:

- Asahi Linux on Arch Linux ARM / ALARM as the hardware base
- pacman and AUR for package management
- `niri-cidre` as the standard desktop/compositor component
- `greetd + greetd-tuigreet` as the standard login stack
- Ghostty, fish, Zed, and Helix as the default developer environment
- foot + bash as the recovery path

Target statement:

- built for Apple Silicon Macs running Asahi Linux on Arch Linux ARM / ALARM
- not currently targeting Asahi Fedora

Cidre is aimed at users who want:

- Linux ownership and hackability
- a modern keyboard-first desktop workflow
- a coherent setup instead of rebuilding dotfiles from scratch every time
- strong defaults instead of endless choice paralysis

Cidre is not aimed at users who primarily need:

- iCloud, AirDrop, or Apple service integration
- Adobe workflows
- Logic Pro or Final Cut Pro
- a Mac-like Linux theme without deeper system changes

The tagline is:

> The cider after Homebrew.

## niri-cidre In Cidre

`niri-cidre` is the Cidre desktop component based on `niri`.

It is not the whole Cidre project. It is the standard desktop/compositor experience shipped as part of Cidre.

## Project Structure

Cidre is the full developer environment for Apple Silicon Macs running Asahi ALARM / Arch Linux ARM.

`niri-cidre` is the compositor component shipped with Cidre. It is based on upstream `niri`, but packaged and configured for the Cidre desktop experience.

The Cidre login session starts `niri-cidre` through `cidre-session`.

Upstream-compatible `niri-*` session assets are kept only as compatibility resources and are not part of the standard Cidre install path.

## Cidre-Specific Additions

Cidre builds on the original [niri](https://github.com/niri-wm/niri) project and extends the compositor layer with several Cidre-specific features and experimental effects:

*   **niri-liquid Extensibility Platform (v1.1-1.3, Phase 0-4)**: Adds an extensibility API allowing custom compositor control, rendering modifications, and status event streaming (via the `liquid` event bus).
*   **Scratch Column / Special Workspace**: Added support for toggleable scratch columns/windows and workspace retention to prevent scratch sources from being prematurely cleaned up.
*   **Enhanced Liquid Shaders**: Features custom shader parameters like Fresnel effects, active animation presets parsed directly from configuration, bloom modifiers, edge highlights, and time-based rendering sweeps.
*   **Startup Safe Mode & Crash Detection**:
    *   Automatically detects crash conditions via a runtime directory sentinel file (`niri-crash-sentinel`).
    *   If a crash is detected, the config fails to load, or `--safe-mode` is passed via CLI / `NIRI_SAFE_MODE=1` is set, it falls back to a lightweight, script-disabled, and low-resource animation safe-profile at startup.

## Repository Scope

This repository contains `niri-cidre`, the compositor layer of the broader Cidre environment.

Baseline `niri` fundamentals still apply:

- windows are arranged in columns on an infinite strip going to the right
- opening a new window never causes existing windows to resize
- every monitor has its own separate window strip
- workspaces are dynamic and arranged vertically

This is where Cidre-specific compositor behavior lives:

- power-aware motion and rendering policy
- touchpad gesture integration for MacBook-class hardware
- scratch-column and special-workspace workflow
- liquid/extensible compositor experiments
- recovery-oriented safe mode behavior

## Features

- scrollable tiling desktop workflow
- dynamic workspaces and overview
- Apple Silicon oriented touchpad and gesture tuning
- built-in screenshot UI
- screencasting through `xdg-desktop-portal-gnome`
- tab grouping and configurable layout
- live config reload
- Cidre-specific safe mode, scratch column workflow, and power-aware behavior

## Why This Exists

Cidre is for the case where installing Linux on a MacBook is only the first 20% of the work.

The remaining 80% is usually:

- rebuilding shell setup
- rebuilding editor setup
- rebuilding terminal setup
- rebuilding window-management workflow
- rebuilding recovery tooling
- rebuilding power-saving behavior

Cidre tries to reduce that by shipping a more finished answer instead of a blank Linux install plus homework.

## Who This Is For

Cidre makes the most sense if you:

- like Apple Silicon MacBook hardware
- want Linux for daily development
- prefer Arch-style package management
- want a modern workflow around niri, Ghostty, fish, Zed, and Helix
- are comfortable with terminal-centric setup and debugging

Cidre is a poor fit if you mainly want:

- a generic desktop Linux setup
- macOS feature parity
- a cosmetic Mac theme
- zero-maintenance GUI-only workflows

## Status

Cidre is in an active pre-release shaping phase.

What is already clear:

- the product scope is fixed
- the target platform is fixed
- the standard package profiles are mostly defined
- install, recovery, hardware support, and config docs now exist

What is not fully frozen yet:

- polished install mechanics
- final packaging shape
- documentation and packaging cleanup
- broader hardware validation

For the current release stance, read:

- [Cidre v1.0 Scope](./docs/cidre-v1-scope.md)
- [Cidre v1.0 Release Plan](./docs/cidre-v1-release-plan.md)
- [Cidre v1.0 Release Checklist](./docs/cidre-v1-release-checklist.md)
- [Install Guide](./INSTALL.md)
- [Supported Hardware](./SUPPORTED_HARDWARE.md)
- [Recovery Guide](./RECOVERY.md)
- [Configuration Guide](./CONFIGURATION.md)
- [Known Limitations](./KNOWN_LIMITATIONS.md)
- [Issue Reporting Guide](./ISSUE_REPORTING.md)

## Further Reading

- [NIRI_CIDRE.md](./docs/NIRI_CIDRE.md)
- [UPSTREAM_NIRI.md](./docs/UPSTREAM_NIRI.md)
- [niri-cidre Config Notes](./docs/niri-cidre-config.md)

## Contributing

If you'd like to help with Cidre or `niri-cidre`, start by understanding the current release boundary and support assumptions.

Recommended reading order:

- [README.md](./README.md)
- [Cidre v1.0 Scope](./docs/cidre-v1-scope.md)
- [Install Guide](./INSTALL.md)
- [Supported Hardware](./SUPPORTED_HARDWARE.md)
- [Recovery Guide](./RECOVERY.md)
- [NIRI_CIDRE.md](./docs/NIRI_CIDRE.md)
- [niri-cidre Config Notes](./docs/niri-cidre-config.md)

For contribution mechanics, see [CONTRIBUTING.md](./CONTRIBUTING.md).
