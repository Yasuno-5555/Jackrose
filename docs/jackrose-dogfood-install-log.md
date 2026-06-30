# Jackrose Dogfood Install Log

## Machine

- Device: MacBook dogfood machine
- OS: Arch Linux ARM
- Kernel: 7.0.13-1-1-ARCH
- Session: niri / Wayland
- Date: 2026-06-30

## Initial State

- Clean Jackrose install: assumed active dogfood baseline
- Missing tools: Ghostty package not yet built; exact missing baseline packages recorded below
- Immediate pain points: official Ghostty package path not yet validated on-device

## Installed Packages

- Existing dogfood machine already had: `fish`, `starship`, `zoxide`, `foot`, `helix`, `firefox`, `fcitx5`, `pandoc`, `mpv`, `gvfs-smb`, and many build tools.
- Baseline `sudo pacman -Syu --needed ...` attempt was blocked in this environment by:
  - `sudo: /etc/sudo.conf is owned by uid 65534, should be 0`
  - `sudo: The "no new privileges" flag is set, which prevents sudo from running as root.`

## Failed Packages

- No root-capable baseline install was possible in this environment.
- Missing baseline packages were recorded in `resources/package-audit/dogfood-missing.tsv`.

## Local Jackrose Packages

### jackrose-paru

- Local artifact found: `packages/arch/jackrose-paru/jackrose-paru-1.0.0-1-any.pkg.tar.xz`
- Local install attempt was blocked by `sudo` restrictions in this environment.
- Existing machine state already has upstream `paru 2.1.0-2` installed at `/usr/bin/paru`.
- This does not change the policy that `jackrose-paru` is not a normal OOBE dependency source.

### jackrose-ghostty

- Real build command succeeded:
  - `JACKROSE_ALLOW_PACKAGE_BUILD=1 scripts/dev/build-jackrose-p0-package --package ghostty --allow-build --artifact-dir /tmp/jackrose-build-artifacts`
- Artifact created:
  - `/tmp/jackrose-build-artifacts/jackrose-ghostty-1.3.1-1-aarch64.pkg.tar.xz`
- Static artifact validation passed.
- Local install attempt was blocked by `sudo` restrictions in this environment.

## J16 Welcome Activation Follow-up

- Safe local Jackrose package batch build completed into `/tmp/jackrose-pkgs`.
- Filtered local install dry-run command was produced successfully.
- Actual `sudo pacman -U` remained blocked by sandbox `no_new_privileges`, so installed command-path validation still needs a real host-root session.
- Welcome firstboot runtime was still probed through repo fallbacks:
  - OOBE-visible packs: `student`, `security`
  - experimental packs: `calvados`
  - `calvados` remained hidden from OOBE and failed `plan --oobe`
  - Student remained default-selected
  - Security remained explicit-confirmation-gated

## J17 Host Install Bugfix Follow-up

- Welcome/pack user-state bug fixed in repo:
  - no direct user creation of `/var/lib/jackrose`
  - no direct user creation of `/var/log/jackrose`
- Doctor user-state expectations fixed in repo:
  - manifest and user logs checked first
  - missing system bootstrap log downgraded when root bootstrap was not run
- Ghostty packaging conflict fixed in repo:
  - bundled `ghostty` terminfo removed
  - `ncurses` dependency added
  - rebuilt as `jackrose-ghostty-1.3.1-2-aarch64.pkg.tar.xz`

## J19 Installed Desktop Acceptance Start

- Rebuilt local J19 acceptance package set into `/tmp/jackrose-pkgs`:
  - `jackrose-config-1.0.0-2-any.pkg.tar.xz`
  - `jackrose-session-1.0.0-1-any.pkg.tar.xz`
  - `jackrose-ghostty-1.3.1-3-aarch64.pkg.tar.xz`
  - `jackrose-diagnostics-1.0.0-3-any.pkg.tar.xz`
  - `jackrose-meta-default-1.0.0-1-any.pkg.tar.xz`
  - `jackrose-user-setup-1.0.0-1-any.pkg.tar.xz`
- Current installed host state before the J19 reinstall:
  - `jackrose-config 1.0.0-1`
  - `jackrose-session 1.0.0-1`
  - `jackrose-ghostty 1.3.1-2`
  - `jackrose-diagnostics 1.0.0-2`
  - `jackrose-meta-default` not installed
  - `jackrose-user-setup` not installed
- Runtime evidence before reinstall still showed the J18 fixes were not yet active on the host:
  - `/usr/share/applications/ghostty.desktop` missing
  - `/usr/share/jackrose/defaults/ghostty/themes/catppuccin-mocha` missing
- User config backups were created under `~/.config/jackrose/backups/`.
- Host `sudo pacman -U` is pending interactive authentication before installed-host acceptance can proceed.

## J19 Installed Desktop Acceptance Results

- Local package reinstall succeeded for:
  - `jackrose-bootstrap-1.0.0-1`
  - `jackrose-firstboot-1.0.0-1`
  - `jackrose-welcome-1.0.0-2`
  - `jackrose-config-1.0.0-2`
  - `jackrose-session-1.0.0-1`
  - `jackrose-ghostty-1.3.1-3`
  - `jackrose-diagnostics-1.0.0-3`
  - `jackrose-user-setup-1.0.0-1`
- `jackrose-meta-default` was not installed because `gh`, `deno`, and `ocrmypdf` were unresolved on the host.
- Runtime redeploy succeeded after normalizing the legacy user-state manifest and running:
  - `jackrose-user-setup apply --force --no-snapshot`
- Installed runtime verification succeeded:
  - `Ghostty` launched with no theme/config warnings
  - `Ghostty` appeared in `fuzzel`
  - `Mod+Return` opened `Ghostty`
  - `jackrose-doctor --daily` completed with only expected WARN items
  - `jackrose-doctor --firstboot` ultimately passed after reconciling stale firstboot failure state
- Follow-up repo fixes identified during acceptance:
  - `jackrose-user-setup` needs legacy manifest normalization in package `1.0.0-2`
  - `jackrose-security` state logging needs user-state handling in `jackrose-welcome 1.0.0-3`

## Manual Usability Checks

- Terminal: `foot` available; `ghostty` artifact built but not installed
- Shell: `fish`, `starship`, and `zoxide` available
- Editor: `helix` available; `micro` missing
- Japanese input: `fcitx5` packages present; interactive text-entry validation not performed here
- PDF: `zathura` missing
- Writing: `pandoc` present; `typst` and `libreoffice-fresh` missing
- File manager: `thunar` present; `gio mount smb://example.invalid` was limited by environment permissions
- Browser: `firefox` present
- Media: `mpv` and `ffmpeg` present; `imagemagick` missing
- Sync/backup: `syncthing`, `rclone`, and `restic` missing

## Promote Candidates

- `fish`
- `foot`
- `helix`
- `pandoc`
- `ghostty` pending local install test

## Defer Candidates

- `zed`
- `zotero`
- `ghostty` promotion until install test is completed in a root-capable environment

## Notes

- Dogfood install results do not automatically promote packages into active `jackrose-meta-default` depends.
