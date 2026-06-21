# Cidre (v0.2.0 Bootstrap Release)

Cidre is an Apple Silicon Mac-oriented Linux experience layer built on ALARM (Arch Linux ARM) / Asahi Linux.

> [!IMPORTANT]
> **Cidre is not a niri fork.**
> Cidre is a full integration layer that manages installer scripts, configuration deployment, system recovery, sound optimization, and desktop session profiles. The compositor itself is managed under a separate component called `niri-cidre`.

## Installation (v0.2.0 Bootstrap)

From a clean ALARM / Asahi Minimal install, run:

```bash
curl -L https://raw.githubusercontent.com/Yasuno-5555/Cidre/main/scripts/bootstrap.sh | sh
```

Or clone the repository and run the script locally:

```bash
git clone https://github.com/Yasuno-5555/Cidre
cd Cidre
./scripts/bootstrap.sh
```

After the bootstrap installer finishes:
1. Reboot the system.
2. Log in through the graphical `greetd` greeter.
3. Run the user setup tool to safely deploy config defaults into your home directory:
   ```bash
   cidre-user-setup
   ```

## Repository Structure

- **Yasuno-5555/Cidre** (This repository): Contains the installers, default configs, recovery scripts, and packages.
- **Yasuno-5555/niri-cidre**: Contains the compositor code and patches based on upstream `niri`.

## Key Commands

- `cidre-user-setup`: Deploys default configurations for niri, Ghostty, fcitx5-mozc, Waybar, fuzzel, fish, and starship to your home directory safely.
- `cidre-recovery`: Command-line interface to assist in recovery.
  - `cidre-recovery disable-greetd`
  - `cidre-recovery reset-niri-config`
  - `cidre-recovery reset-user-config`
  - `cidre-recovery reset-audio`
  - `cidre-recovery collect-logs`
  - `cidre-recovery safe-mode`
- `cidre-audio`: Audio configuration and status diagnostics.
  - `cidre-audio doctor`
  - `cidre-audio diagnose`
  - `cidre-audio reset`
  - `cidre-audio profile <stable|balanced|low-latency>`
