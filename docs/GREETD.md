# Jackrose Login Stack

This document defines the standard login stack for `Jackrose v1.0`.

## Standard Choice

Jackrose v1.0 standard login stack:

- `greetd`
- `greetd-tuigreet`

This is not an optional recommendation for the default desktop profile.

For the standard Jackrose desktop experience, `jackrose-meta-desktop` should own the login path and include:

- `niri-jackrose`
- `jackrose-session`
- `jackrose-config`
- `greetd`
- `greetd-tuigreet`
- the Jackrose wayland session entry
- `jackrose.service`
- `jackrose-shutdown.target`

Current draft package skeleton:

- `packages/arch/niri-jackrose`
- `packages/arch/jackrose-meta-desktop`
- `packages/arch/jackrose-session`
- `packages/arch/jackrose-config`

## Why This Is Standard

Jackrose is trying to ship a coherent Apple Silicon Linux developer workstation, not just a compositor binary.

That means the login experience is part of the product surface.

If `tuigreet` is missing from the default desktop profile, users do not get the intended Jackrose session selection and login flow by default.

## Package Ownership

Recommended responsibility split:

- `jackrose-meta-core`
  - base system
  - Asahi platform stack
  - recovery and boot baseline
- `jackrose-meta-desktop`
  - `niri-jackrose`
  - `greetd`
  - `greetd-tuigreet`
  - session files
  - desktop runtime dependencies
- `jackrose-meta-dev`
  - developer tooling

In other words:

> If a user installs `jackrose-meta-desktop`, they should get a working Jackrose login session path rather than just "some compositor-related packages".

## Minimum Runtime Expectation

The standard path should be:

```text
greetd
└─ tuigreet
   └─ Jackrose
      └─ jackrose-session
         └─ jackrose.service
            └─ niri-jackrose
```

## Documentation Rule

Whenever the default desktop profile is described, it should treat `greetd + greetd-tuigreet` as part of the baseline rather than an optional extra.
