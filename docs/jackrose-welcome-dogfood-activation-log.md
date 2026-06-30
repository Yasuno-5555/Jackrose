# Jackrose Welcome Dogfood Activation Log

## Purpose

Record the J16 local package build, local package install attempt, Welcome/OOBE runtime checks, and doctor checks.

## Host

- Device: MacBook dogfood host
- OS: Arch Linux ARM
- Session: niri / Wayland
- Date: 2026-06-30

## Local Package Build

- Safe local package batch build completed with:
  - `scripts/dev/build-jackrose-local-packages --all-safe --output /tmp/jackrose-pkgs`
- Built artifacts included:
  - `jackrose-bootstrap`
  - `jackrose-firstboot`
  - `jackrose-diagnostics`
  - `jackrose-config`
  - `jackrose-session`
  - `jackrose-wallpapers`
  - `jackrose-shortcuts`
  - `jackrose-welcome`
  - `jackrose-meta-core`
  - `jackrose-meta-default`
  - `jackrose-security-base`
  - `jackrose-pack-student`
  - `jackrose-pack-security`
  - `jackrose-ghostty`
- `jackrose-ghostty` reused the already validated aarch64 artifact path and did not require a second full build for this phase.

## Local Package Install

- Dry-run install command was generated with:
  - `scripts/dev/install-jackrose-local-packages --input /tmp/jackrose-pkgs --dry-run`
- Non-J16-safe stale artifacts such as `jackrose-audio` and `jackrose-paru` were skipped by the helper.
- Real install did not complete in this environment because `sudo` is sandbox-blocked:
  - `sudo: /etc/sudo.conf is owned by uid 65534, should be 0`
  - `sudo: The "no new privileges" flag is set, which prevents sudo from running as root.`
- Result:
  - host-side `sudo pacman -U /tmp/jackrose-pkgs/*.pkg.tar.*` is still required on the real dogfood session.

## Welcome Runtime

- Installed command availability was not present in this environment:
  - `jackrose-welcome`: unavailable in `PATH`
  - `jackrose-pack`: unavailable in `PATH`
  - `jackrose-doctor`: unavailable in `PATH`
- J16 runtime probe used repo fallbacks through:
  - `scripts/dev/run-jackrose-welcome-dogfood --firstboot`
- Pack model checks:
  - `jackrose-pack list --oobe` returned `security` and `student`
  - `jackrose-pack list --experimental` returned `calvados`
  - `jackrose-pack plan --oobe calvados` failed with `calvados is not OOBE-visible`
- Welcome firstboot behavior:
  - firstboot flow launched successfully from the repo fallback script
  - Student Pack was selected by default
  - Security Pack started unchecked
  - Security flow requires the explicit `ENABLE BLACKARCH REPOSITORY` confirmation phrase before repository enablement
  - Calvados did not appear in firstboot OOBE
  - scripted firstboot run reached the finish screen

## Doctor

- `jackrose-doctor --daily` reported missing installed commands and services
- `jackrose-doctor --bootstrap` failed because Jackrose packages are not installed on this environment
- `jackrose-doctor --firstboot` failed because Jackrose packages are not installed on this environment
- These are runtime consequences of the blocked local install step, not evidence of a Welcome pack-model regression

## J17 Follow-up

- Welcome and `jackrose-pack apply` no longer attempt to create `/var/lib/jackrose` or `/var/log/jackrose` during user OOBE.
- user-state runtime outputs now target:
  - `~/.local/state/jackrose/manifest.json`
  - `~/.local/state/jackrose/firstboot.done`
  - `~/.local/state/jackrose/firstboot.failure`
  - `~/.local/state/jackrose/logs/welcome.log`
- `jackrose-doctor` now prefers user-state manifest and logs and treats missing system bootstrap log as expected when root bootstrap was not run.
- real host reinstall and rerun remain pending outside the agent sandbox.

## Notes

- J16 keeps official `jackrose-meta-default` integration gated.
- Local host install evidence is not the same as distribution promotion.
- No forbidden repository, trust-boundary, or platform-state changes were performed in this phase.
