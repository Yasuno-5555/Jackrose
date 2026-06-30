# Jackrose Installed Desktop Acceptance

## Phase

- J19: Installed Desktop Acceptance and Default Promotion Review

## Scope

- Reinstall the J18-fixed desktop packages on the dogfood host.
- Redeploy user-facing Ghostty and Niri defaults with backup.
- Verify the installed runtime rather than only repo-side validators.

## Acceptance Rules

- A component is accepted only after local package install, runtime redeploy, and host verification.
- Manual checks such as fuzzel visibility and `Mod+Return` launch behavior must be recorded explicitly.
- Optional future components such as `quickshell` stay informational until the shell exists.

## Evidence Targets

- `resources/package-audit/installed-desktop-acceptance.tsv`
- `resources/package-audit/desktop-runtime-results.tsv`
- `resources/package-audit/local-install-results.tsv`
- `resources/package-audit/dogfood-installed.tsv`

## Current Review State

- J18 repo/package fixes are implemented and validated in-repo.
- J19 host acceptance is recorded in the acceptance matrix and promotion review tables.
