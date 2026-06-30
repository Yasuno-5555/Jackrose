# Jackrose Doctor Bootstrap / Firstboot Checks

## Purpose

`jackrose-doctor` can inspect the Post-ALARM Bootstrap and Firstboot Welcome lifecycle.

## Commands

- `jackrose-doctor --bootstrap`
- `jackrose-doctor --firstboot`
- `jackrose-doctor --daily`

## What It Checks

### `--bootstrap` Checks

- Verify that commands (`jackrose-bootstrap`, `jackrose-firstboot`, `jackrose-welcome`) exist.
- Verify systemd user service unit exists.
- Verify packaged defaults (`config.kdl`, `default.png`, `desktop-basics.md`, `desktop-basics.ja.md`) exist.
- Verify bootstrap state and report existence.
- Verify configuration deployment results and niri validation results.
- Verify niri baseline configuration conforms to validation rules (no legacy Cidre remnants, does not prefer Ghostty first).

### `--firstboot` Checks

- Verify firstboot command line tool and welcome command exist.
- Verify firstboot systemd user service unit exists and has correct ExecStart.
- Inspect user markers (`firstboot.done` and `firstboot-report.json`).
- Verify bootstrap report accessibility.

### `--daily` Integration

- Summarizes firstboot status and warns if pending, and flags critical failures if the systemd user service is missing.

## What It Does Not Do

- install packages
- enable/disable services
- modify configs
- touch partitions
- mutate boot chain
- run APFS / GRUB / ESP / m1n1 / macOS privileged operations

## Common Outputs

### `--bootstrap` Output Example

```text
Jackrose Bootstrap Health

[OK] jackrose-bootstrap installed
[OK] jackrose-firstboot installed
[OK] jackrose-welcome installed
[OK] firstboot user service installed
[OK] niri baseline config installed
[OK] wallpaper installed
[OK] Welcome desktop basics content installed
[OK] bootstrap state found
[OK] bootstrap report found
[OK] config_deploy completed
[WARN] firstboot has not completed yet
```
