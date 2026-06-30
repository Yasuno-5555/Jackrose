# Jackrose Ghostty Real Build Log

## Purpose

Record the first real Ghostty build attempt on dogfood Jackrose.

## Source

- upstream: `https://release.files.ghostty.org/1.3.1/ghostty-1.3.1.tar.gz`
- version: `1.3.1`
- checksum: `3349d25600ffbda281197a18314f7d18791969cffe9474f0ff16a45a9ebfccdb`

## Build Environment

- machine: MacBook dogfood machine
- architecture: `aarch64`
- Zig: `0.15.2`
- makepkg: `7.1.0`
- kernel: `7.0.13-1-1-ARCH`

## Command

```sh
JACKROSE_ALLOW_PACKAGE_BUILD=1 \
scripts/dev/build-jackrose-p0-package \
  --package ghostty \
  --allow-build \
  --artifact-dir /tmp/jackrose-build-artifacts
```

## Result

- final build status: pass
- intermediate failures repaired during J15:
  - upstream dependency cache path initially failed on `uucode` fetch handling
  - PKGBUILD had a static `--system` path expansion bug
  - PKGBUILD build step initially staged into `/usr` instead of a writable build prefix

## Artifact

- `/tmp/jackrose-build-artifacts/jackrose-ghostty-1.3.1-1-aarch64.pkg.tar.xz`

## Validation

- `scripts/dev/validate-jackrose-ghostty-package --artifact /tmp/jackrose-build-artifacts/jackrose-ghostty-1.3.1-1-aarch64.pkg.tar.xz`
- result: pass
- notes:
  - desktop entry detected
  - terminfo payload detected
  - `namcap` still unavailable locally

## Install Test

- local install not completed
- `sudo -n pacman -U /tmp/jackrose-build-artifacts/jackrose-ghostty-1.3.1-1-aarch64.pkg.tar.xz` failed because:
  - `/etc/sudo.conf` ownership is invalid in this environment
  - `sudo` is blocked by `no new privileges`

## Remaining Issues

- run `pacman -U` on a root-capable dogfood machine
- verify `ghostty --version`
- verify manual launch under Niri
- verify launcher and keybinding behavior after install

## J17 Follow-up

- observed host install bug:
  - `jackrose-ghostty: /usr/share/terminfo/g/ghostty exists in filesystem (owned by ncurses)`
- fix applied:
  - removed bundled Ghostty terminfo payload from package
  - added `ncurses` runtime dependency
  - bumped `pkgrel` to `2`
- rebuilt artifact:
  - `/tmp/jackrose-build-artifacts/jackrose-ghostty-1.3.1-2-aarch64.pkg.tar.xz`
- validation:
  - package no longer contains `usr/share/terminfo/g/ghostty`
  - `scripts/dev/validate-jackrose-ghostty-terminfo`: pass
