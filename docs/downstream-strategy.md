# Cidre Downstream Strategy

Cidre is moving from a post-install setup project toward a downstream ALARM/Asahi image for Apple Silicon MacBooks.

Cidre is not trying to replace Arch Linux ARM or Asahi Linux.
Cidre is a downstream product layer that turns Apple Silicon MacBooks into a polished niri-based Linux workspace.

## Why post-install scripts are not enough

- users can fail before they ever reach Cidre
- default credentials and raw login prompts are a bad first impression
- firstboot guidance needs image-level ownership

## Upstream tracking policy

- maximum upstream tracking
- minimum downstream delta
- strong Cidre product experience

## What Cidre owns

- installer entry design
- rootfs customization
- firstboot OOBE behavior
- seed/resume integration
- Cidre package overlay
- Cidre desktop/recovery experience

## What Cidre does not own

- ALARM package universe as a whole
- kernel maintenance
- Apple Silicon boot chain reimplementation
- base Arch Linux ARM distribution work
