# ALARM Fork Strategy

## Candidate Repositories

- `asahi-alarm/asahi-alarm-installer`
- `asahi-alarm/asahi-alarm-builder`
- `asahi-alarm/asahi-alarm`
- `AsahiLinux/asahi-installer-data`
- `AsahiLinux/asahi-installer`

## Fork Policy

- fork when Cidre needs to carry installer entry or image prototype patches
- track read-only when structure understanding is enough
- keep upstream remotes intact for sync visibility

## Remote Naming

- `upstream`: original project
- `origin`: Cidre fork

## Branch Naming

- `cidre/main`
- `cidre/image-prototype`
- `cidre/installer-entry`

## Patch Policy

- keep downstream deltas small
- prefer additive metadata and overlay hooks
- avoid invasive rewrites unless required for product flow
