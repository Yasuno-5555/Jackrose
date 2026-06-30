# Jackrose Host Install Bugfix Log

## Purpose

Record the J17 bugfix pass for the first real host-install issues discovered after running the installed Welcome/OOBE stack.

## Host

- Device: MacBook dogfood machine
- OS: Arch Linux ARM
- Session: niri / Wayland
- Date: 2026-06-30

## Fixed Bugs

### J17-001 / J17-002 Welcome user-state paths

- `jackrose-welcome` no longer relies on user-created `/var/lib/jackrose` or `/var/log/jackrose`.
- user-writable runtime paths now resolve under:
  - `${XDG_STATE_HOME:-$HOME/.local/state}/jackrose`
  - `${XDG_STATE_HOME:-$HOME/.local/state}/jackrose/logs`
  - `${XDG_STATE_HOME:-$HOME/.local/state}/jackrose/reports`
- Welcome now writes:
  - `manifest.json`
  - `firstboot.done`
  - `firstboot.failure`
  - `logs/welcome.log`

### J17-003 / J17-004 Doctor manifest and log expectations

- `jackrose-doctor` now checks user-state manifest and firstboot markers first.
- missing system bootstrap log no longer causes a warning-only false alarm for user-firstboot expectations.
- doctor now treats system bootstrap log absence as expected when root bootstrap did not run.

### J17-005 Ghostty terminfo conflict

- `jackrose-ghostty` now depends on `ncurses`.
- the package no longer ships `usr/share/terminfo/g/ghostty`.
- `pkgrel` bumped from `1` to `2`.

### J17-006 Fcitx5 service warning

- retained as warning-level follow-up
- doctor now suggests:
  - `systemctl --user start fcitx5`

## Rebuild Results

- rebuilt:
  - `jackrose-welcome-1.0.0-2-any.pkg.tar.xz`
  - `jackrose-diagnostics-1.0.0-2-any.pkg.tar.xz`
  - `jackrose-ghostty-1.3.1-2-aarch64.pkg.tar.xz`
- copied refreshed artifacts into:
  - `/tmp/jackrose-pkgs`
  - `/tmp/jackrose-build-artifacts` for Ghostty

## Validation

- `scripts/dev/run-firstboot-welcome-tests`: pass
- `scripts/dev/run-doctor-bootstrap-firstboot-tests`: pass
- `scripts/dev/validate-jackrose-user-state-paths`: pass
- `scripts/dev/validate-jackrose-ghostty-terminfo`: pass
- `scripts/dev/run-host-install-bugfix-tests`: pass

## Host Reinstall Status

- real host `pacman -U` reinstall still pending outside the agent sandbox
- real host rerun still pending:
  - `jackrose-welcome --firstboot`
  - `jackrose-doctor --daily`
  - `jackrose-doctor --firstboot`
  - `ghostty --version`

## Notes

- no `pacman.conf` mutation
- no BlackArch enablement
- no AUR automation
- no boot or disk state mutation
