# Cidre Desktop Seed Pivot Design

This document details the architectural pivot of Cidre's firstboot onboarding experience from a text-only TTY-first model to a graphical desktop-first Welcome model.

---

## 1. Product Decision

> [!IMPORTANT]
> **A Merely Working System is Not Enough**
> A bare text console (TTY1) is unacceptable as the primary first-use onboarding path for a premium system. The first visible environment must feel like Cidre: custom, guided, and visually complete.

### Previous Model (TTY OOBE)
```text
Boot → TTY1 → cidre-oobe TUI → User/Network Setup → Graphical Session (later)
```

### New Model (Desktop Welcome)
```text
Boot → Graphical Session (Baseline) → Cidre Welcome autostart → User/Network Setup → Option to build Optimized Session
```

### Fallback/Rescue Path
If the graphical server fails to launch, the system falls back to TTY1 and launches `cidre-oobe` as a rescue installer.

---

## 2. Baseline vs. Optimized Desktop

To achieve a graphical environment instantly on first boot, we define two tiers of components.

### 2.1. Baseline Desktop (Seed Image Level)
Components that can be installed directly from pre-built ALARM repository packages without long build times:
- **Compositor**: `upstream niri`
- **Terminal**: `foot`
- **Launcher**: `fuzzel`
- **Bar**: `waybar`
- **Browser**: `firefox`
- **Input**: `fcitx5` + `fcitx5-mozc`
- **Shell**: `bash`

### 2.2. Optimized Experience (Upgrade Path)
Preferred custom elements that require compilation or local custom builds. These will be offered inside Cidre Welcome as an optional upgrade path:
- **Compositor**: `niri-cidre`
- **Terminal**: `ghostty`
- **Shell**: `fish`

---

## 3. State Markers Design

We separate markers to isolate low-level initialization from desktop-level user configuration completion:

- `/var/lib/cidre/firstboot.done`
  - Purpose: Tracks low-level system initialization status.
- `/var/lib/cidre/welcome.done`
  - Purpose: Tracks completion of the desktop first-run Welcome guide.
