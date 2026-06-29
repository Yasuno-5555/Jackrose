# Jackrose Configuration Guide

This file is the public entry point for Jackrose configuration guidance.

For the actual fork-specific config structure and options, read:

- [docs/niri-jackrose-config.md](./docs/niri-jackrose-config.md)

Recommended reading order:

1. [docs/jackrose-v1-scope.md](./docs/jackrose-v1-scope.md)
2. [INSTALL.md](./INSTALL.md)
3. [RECOVERY.md](./RECOVERY.md)
4. [docs/niri-jackrose-config.md](./docs/niri-jackrose-config.md)

Current Jackrose config layering:

- `~/.config/niri/config.kdl`
- `~/.config/niri/config.jackrose.kdl`
- `~/.config/niri/config.jackrose.local.kdl`

Role split:

- `config.kdl`: upstream-compatible base
- `config.jackrose.kdl`: Jackrose entrypoint
- `config.jackrose.local.kdl`: fork-only and local overrides

Validation workflow:

```bash
/usr/bin/niri-jackrose validate -c ~/.config/niri/config.kdl
~/Projects/niri/target/release/niri-jackrose validate -c ~/.config/niri/config.jackrose.kdl
```

Recovery-first rule:

- keep the base config as clean as possible
- put fork-only behavior in Jackrose-specific config layers
- do not make recovery depend on your fanciest local tweaks
