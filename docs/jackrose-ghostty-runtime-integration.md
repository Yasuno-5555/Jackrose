# Jackrose Ghostty Runtime Integration

## J18 Summary

- The default Ghostty config keeps `theme = catppuccin-mocha`.
- Jackrose now ships the corresponding theme file in repo resources and packaged defaults.
- Jackrose now ships a standard `ghostty.desktop` entry for launcher discovery.
- `jackrose-ghostty` now installs `ghostty.desktop` into `/usr/share/applications`.
- `jackrose-ghostty` now installs an upstream icon into the hicolor icon tree.

## User Deploy Path

- System defaults:
  - `/usr/share/jackrose/defaults/ghostty/config`
  - `/usr/share/jackrose/defaults/ghostty/themes/catppuccin-mocha`
- User targets:
  - `~/.config/ghostty/config`
  - `~/.config/ghostty/themes/catppuccin-mocha`

## Validation

- No `hx ...` shell command lines are allowed in Ghostty config.
- `ghostty.desktop` must use `Exec=ghostty`.
- `jackrose-ghostty` must not reintroduce a bundled `ghostty` terminfo payload.
