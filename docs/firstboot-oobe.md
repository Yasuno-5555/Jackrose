# Cidre Firstboot OOBE

## What Firstboot OOBE Is

Cidre firstboot OOBE is the root-phase entrypoint intended for future Cidre-controlled images.

Cidre v0.21.0 improves firstboot visibility, failure reporting, and retry guidance.

Its job is to guide the first boot state toward:

- seed/resume awareness
- basic root-phase readiness
- normal user setup
- clear handoff to the user-phase installer

## Why It Exists

The purpose of firstboot OOBE is to avoid requiring users to know default ALARM credentials such as `root/root`.

## What It Does

- records firstboot state
- checks seed/resume presence
- runs lightweight network and pacman checks
- delegates root-phase setup to `cidre-preinstall`
- writes root-to-user handoff instructions

## What It Does Not Do

- provide a GUI installer
- guarantee bootable public images
- store passwords
- replace `cidre-preinstall`

## State Files

```text
/var/lib/cidre/firstboot-root/
  started
  completed
  failed
  skipped
  handoff.txt
  selected-user
  selected-profile
```

## Handoff

The expected handoff is:

```text
su - <user>
cd <Cidre repo>
./install --resume
```

## Dry-run and Testing

Recommended checks:

```sh
scripts/cidre-firstboot-root --dry-run
CIDRE_SYSTEM_ROOT="$(mktemp -d)" scripts/cidre-firstboot-state mark-started
CIDRE_SYSTEM_ROOT="$(mktemp -d)" scripts/cidre-firstboot-handoff --user testuser --profile developer
```
