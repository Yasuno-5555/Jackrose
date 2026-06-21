# Cidre Downstream Workspace

This directory tracks the work required to move Cidre from a post-install setup project toward a downstream ALARM/Asahi image for Apple Silicon MacBooks.

## Purpose

- record upstream repositories and tracking strategy
- define the prototype Cidre image layout
- capture installer metadata examples
- keep rootfs overlay notes close to the main Cidre repository

## Relationship to the main repository

The main `Cidre` repository remains the source of truth for scripts, docs, configs, recovery tools, seed/resume tooling, and firstboot prototypes.

This `downstream/` area exists to make the future image work concrete without pretending that a production image already exists.
