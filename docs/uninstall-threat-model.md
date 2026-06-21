# Uninstall Threat Model

## Primary Risks

- accidental macOS partition deletion
- wrong partition identification
- missing state export before cleanup
- boot target confusion between Linux and macOS
- confirmation fatigue during destructive flows

## Why v0.23.0 stays read-only

Destructive automation is deferred because Linux-side tooling cannot safely guarantee the full macOS restore state on its own.

## Required Foundation

- exact identifiers
- state export
- restore checklist
- risk classification
- repeated confirmation in future destructive flows

## macOS-side risks

- false positive partition candidate
- protected recovery partition confusion
- user follows advisory report as deletion instruction
- startup disk ambiguity
- Disk Utility or `diskutil` output format changes
