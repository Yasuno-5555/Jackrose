# Contributing to Jackrose and niri-jackrose

Thanks for your interest in contributing.

This repository contains the Jackrose environment, including installer, recovery, rescue tooling, documentation, package metadata, and the `niri-jackrose` desktop layer.

Before contributing, read these first:

- [README.md](./README.md)
- [docs/jackrose-v1-scope.md](./docs/jackrose-v1-scope.md)
- [INSTALL.md](./INSTALL.md)
- [SUPPORTED_HARDWARE.md](./SUPPORTED_HARDWARE.md)
- [RECOVERY.md](./RECOVERY.md)
- [KNOWN_LIMITATIONS.md](./KNOWN_LIMITATIONS.md)
- [ISSUE_REPORTING.md](./ISSUE_REPORTING.md)
- [docs/niri-jackrose-config.md](./docs/niri-jackrose-config.md)

## What This Repository Is

This repository contains the Jackrose environment, including installer, recovery, rescue tooling, documentation, package metadata, and the `niri-jackrose` desktop layer.

`niri-jackrose` is the desktop/compositor component shipped as part of Jackrose. It is not the whole project.

That distinction matters when discussing scope, bugs, documentation, and release expectations.

## Contribution Priorities

Right now, the highest-value contributions are usually:

- Apple Silicon stability improvements
- install and recovery hardening
- `niri-jackrose` integration bugs
- power-aware behavior improvements
- touchpad and session polish
- documentation that reduces user footguns

## Issues and Discussions

When filing or triaging issues, first identify which layer the problem belongs to:

- `Jackrose` product/documentation/install issue
- `niri-jackrose` compositor issue
- upstream `niri` behavior
- upstream Asahi/platform issue
- application issue
- local configuration issue

That split is more important here than in a typical single-layer project.

Useful triage questions:

- Does it reproduce with packaged upstream `niri`?
- Does it reproduce only with local Jackrose config?
- Does it reproduce only on specific Apple Silicon hardware?
- Did it start after a local build, config edit, or package update?
- Is it actually an application bug?

If the issue is really:

- an app bug
- an unsupported hardware situation
- an Asahi platform bug
- a local broken config

then say so clearly instead of pretending it is a Jackrose core defect.

## Reviewing and Testing Pull Requests

Testing and review should reflect the actual Jackrose release boundary.

When testing, pay attention to:

- session startup
- config validation and reload
- touchpad behavior
- power-profile behavior
- recovery path safety
- regression risk on supported Apple Silicon hardware

Useful test categories:

- build succeeds
- session starts from a clean login
- `jackrose-session` path works
- user systemd override behavior is sane
- Jackrose config layering still validates
- safe mode is still reachable

For bug fixes:

1. reproduce the issue first
2. verify the fix
3. probe nearby edge cases
4. note any recovery implications

For reviews:

- check scope discipline
- look for accidental breakage of the recovery path
- make sure Jackrose-specific docs are updated when needed
- check that upstream compatibility is preserved where intended

## Writing Pull Requests

Please keep pull requests focused.

Guidelines:

- keep the change to one problem or feature
- avoid unrelated cleanup in the same PR
- prefer small, reviewable commits
- test by hand, not only by compilation
- update docs when behavior, install flow, or config changes
- do not silently expand the public support promise

Especially important for this repo:

- if you add fork-only config behavior, document it
- if you change install or recovery expectations, update `INSTALL.md` or `RECOVERY.md`
- if you change support assumptions, update `SUPPORTED_HARDWARE.md` or `KNOWN_LIMITATIONS.md`

## Documentation Changes

Docs are not secondary here. They are part of the product.

If your change affects:

- installation
- recovery
- support scope
- config structure
- package profile expectations

then update the relevant doc in the same change.

## Upstream vs Jackrose-Specific Changes

When making a change, be clear whether it is:

- strictly Jackrose-specific
- a clean candidate for upstream `niri`
- temporary compatibility glue

Avoid mixing these casually in one patch without explanation.

## AI Contributions

If you use LLMs, the output is still your responsibility.

That means:

- verify every technical claim
- remove unnecessary verbosity
- remove hallucinated architecture
- make sure docs match the code that actually exists

For code or docs that read as mostly unverified AI output, expect much harsher review.

## Communication

Upstream `niri` community spaces are still useful for compositor internals and baseline behavior:

- Matrix: https://matrix.to/#/#niri:matrix.org
- Discord: https://discord.gg/vT8Sfjy7sx

Jackrose-specific public communication channels are not yet fully separated. Until they are, be explicit about whether you are discussing:

- upstream `niri`
- `niri-jackrose`
- Jackrose product scope

## Practical Rule

If a contribution makes Jackrose easier to install, recover, understand, or trust on supported Apple Silicon hardware, it is probably valuable.
