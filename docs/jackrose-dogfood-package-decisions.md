# Jackrose Dogfood Package Decisions

## Purpose

This document records which packages were actually needed on the dogfood Jackrose MacBook and whether they should stay local-only, move toward promotion, or remain deferred.

## Promote Candidates

- `fish`: shell experience is already part of actual dogfood use.
- `foot`: fallback terminal remains practical and low-risk.
- `helix`: immediately usable editor on the dogfood machine.
- `pandoc`: already available and part of real writing workflow.
- `ghostty`: candidate only after local install test passes in a root-capable environment.

## Deferred

- `zed`: build complexity remains unnecessary while `helix` covers the current workflow.
- `zotero`: still blocked on license/source packaging review.
- `jackrose-paru`: keep as `manual-only` until a later integration decision, even though it remains useful for developer recovery workflows.

## Missing / Broken

- baseline root install operations are blocked in this environment by `sudo` restrictions
- missing baseline packages are tracked in `resources/package-audit/dogfood-missing.tsv`
- `ghostty` package content is no longer blocked; only local install verification remains
- Welcome/doctor installed-command runtime validation is still blocked on a real host-root local package install

## Policy Notes

- Dogfood install evidence is stronger than wishlist planning.
- Dogfood success is not the same as official `jackrose-meta-default` promotion.
- A package may remain `manual-only` even if it is useful on the maintainer machine.
