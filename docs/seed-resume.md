# Cidre Seed & Resume

## What is a Cidre seed?

A Cidre seed is a small archive generated on macOS that records non-secret installation context for later import on a fresh ALARM system.

## What it contains

- `manifest.json`
- `resume.env`
- `checksum.txt`
- `handoff.txt`
- `repo-info.txt`

## What it does not contain

- passwords
- Apple ID data
- Wi-Fi credentials
- SSH private keys
- personal tokens

## Create a seed on macOS

```sh
./install-macos --profile developer
```

Generated files:

```text
.local/state/cidre/macos-bootstrap/cidre-seed.tar.gz
.local/state/cidre/macos-bootstrap/manifest.json
.local/state/cidre/macos-bootstrap/resume.env
```

## Move the seed to fresh ALARM

Use USB storage, `scp`, or a fresh clone plus manual copy.

```sh
cp .local/state/cidre/macos-bootstrap/cidre-seed.tar.gz /Volumes/USB/
```

## Import the seed as root

```sh
./preinstall --import-seed /path/to/cidre-seed.tar.gz
```

This verifies the archive, stores it under `/var/lib/cidre/`, and prepares resume state for the user phase.

## Resume as the normal user

```sh
./install --resume
```

Cidre v0.22.0 extends seed/resume into a user-phase handoff state. Before executing `./install --resume`, normal users can verify the imported handoff state using `scripts/cidre-user-handoff --verify` and `scripts/cidre-user-phase-verify`.

## Troubleshooting

- `ERROR: seed file not found`: confirm the path and mount point.
- `ERROR: invalid profile: unknown`: the seed contents were changed or corrupted.
- `ERROR: unsafe path in seed archive`: reject the archive and regenerate it from macOS.
- `ERROR: no Cidre resume state found.`: import the seed first or run `./install` normally.

## Security Notes

- The seed is intentionally limited to non-secret installation metadata.
- Import rejects obvious unsafe archive paths.
- Manual transfer is still required in v0.13.0.
