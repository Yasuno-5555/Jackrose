# Jackrose Local Package Batch Install

## Purpose

This document describes the J16 local build and install flow for activating Welcome/OOBE on the dogfood host.

## Safe Build Set

Logical components:

- `jackrose-bootstrap`
- `jackrose-firstboot`
- `jackrose-welcome`
- `jackrose-doctor` via package `jackrose-diagnostics`
- `jackrose-config`
- `jackrose-session`
- `jackrose-wallpapers`
- `jackrose-shortcuts`
- `jackrose-pack` via package `jackrose-welcome`
- `jackrose-security-base`
- `jackrose-pack-student`
- `jackrose-pack-security`
- `jackrose-ghostty`

Support packages required for dependency closure during local `pacman -U` activation:

- `jackrose-meta-core`
- `jackrose-meta-default`

## Default Exclusions

- `jackrose-zotero`
- `jackrose-zed`
- `jackrose-pack-calvados`

## Build Helper

```sh
scripts/dev/build-jackrose-local-packages --all-safe --output /tmp/jackrose-pkgs
```

## Install Helper

```sh
scripts/dev/install-jackrose-local-packages --input /tmp/jackrose-pkgs --dry-run
sudo pacman -U /tmp/jackrose-pkgs/*.pkg.tar.*
```

## Welcome Runtime

```sh
scripts/dev/run-jackrose-welcome-dogfood --firstboot
```
