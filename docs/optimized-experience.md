# Jackrose Welcome Optimized Experience Upgrade Design

This document details the optional desktop upgrade workflow for installing Jackrose's optimized graphical environment components (`Ghostty` terminal, `fish` shell, and `niri-jackrose` compositor).

---

## 1. Safety Guidelines

> [!IMPORTANT]
> **Preserve the Baseline Fallback**
> The upgrade process is optional and time-consuming. Any failure or interruption during compilation or installation of optimized components **must not** damage or remove the baseline fallback desktop (`upstream niri` + `foot` terminal + `bash` shell). The baseline must remain active and functional.

---

## 2. State & Log Markers

To manage state tracking and logging, we define the following paths:

- `/var/lib/jackrose/welcome.done`
  - Created when the graphical Jackrose Welcome setup completes.
- `/var/lib/jackrose/optimized.done`
  - Created only when all optimized components build and deploy successfully.
- `/var/lib/jackrose/experience-upgrade.state`
  - Tracks step-by-step progress to allow retry or resume actions:
    ```ini
    ghostty=done
    fish=configured
    niri_jackrose=failed
    ```
- `/var/log/jackrose/experience-upgrade.log`
  - Captures full compiler, package, and script outputs.

---

## 3. Toolchain & Commands

The upgrade is orchestrated by:
- `jackrose-experience-upgrade`
  - Verification check, network check, and sequencing command.
- `jackrose-build-ghostty`
  - Build helper compiling or deploying Ghostty terminal.
- `jackrose-build-niri-jackrose`
  - Build helper compiling or deploying optimized niri.
- `jackrose-setup-fish`
  - Setup helper configuring fish shell settings.
