# Upstream Repositories

## `asahi-alarm/asahi-alarm-installer`

Purpose:
  ALARM installer flow

Cidre interest:
  Cidre image entry and bootstrap integration

Tracking strategy:
  fork with upstream remote

## `asahi-alarm/asahi-alarm-builder`

Purpose:
  ALARM reference image builder

Cidre interest:
  Cidre rootfs image prototype

Tracking strategy:
  fork or reference clone

## `asahi-alarm/asahi-alarm`

Purpose:
  ALARM package and distribution repository

Cidre interest:
  package overlay, distribution assumptions, docs

Tracking strategy:
  reference clone first, fork only if required

## `AsahiLinux/asahi-installer-data`

Purpose:
  reference installer metadata

Cidre interest:
  metadata structure and installable image entries

Tracking strategy:
  reference only unless needed

## `AsahiLinux/asahi-installer`

Purpose:
  upstream installer implementation

Cidre interest:
  structure understanding only

Tracking strategy:
  read-only reference
