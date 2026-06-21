# Cidre (v0.7.0 Stability & Rollback Pack)

Cidre is an Apple Silicon Mac-oriented Linux experience layer built on ALARM (Arch Linux ARM) / Asahi Linux.

> [!IMPORTANT]
> **Cidre is not a niri fork.**
> Cidre is a full integration layer that manages installer scripts, configuration deployment, system recovery, sound optimization, and desktop session profiles. The compositor itself is managed under a separate component called `niri-cidre`.

## Installation

From a clean ALARM / Asahi Minimal install, clone the repository and run:

```bash
git clone https://github.com/Yasuno-5555/Cidre.git
cd Cidre
./install
```

Follow the on-screen guided prompts to check the system compatibility, select your profile (`desktop`, `developer`, `minimal`, `recovery`), preview config changes, and install the environment.

## Documentation Guides

- [Guided Onboarding](./docs/onboarding.md)
- [Installation Guide (Advanced)](./docs/installation.md)
- [Recovery Guide](./docs/recovery.md)
- [Diagnostics Guide](./docs/diagnostics.md)
- [Configuration Management Guide](./docs/config-management.md)
- [v0.7.0 Release Notes](./docs/v0.7.0-stability-rollback.md)
- [v0.6.0 Release Notes](./docs/v0.6.0-daily-driver-polish.md)
- [v0.5.0 Release Notes](./docs/v0.5.0-guided-onboarding.md)
