# Cidre Recovery Screen

Cidre Recovery Screen is the TTY/TUI-facing recovery entrypoint for desktop or session startup failures.

## Purpose

- fail visibly
- explain what happened
- offer safe local recovery actions
- point to exit path and macOS restore guidance when needed

## What it can do

- open safe shell guidance
- run doctor and recovery actions
- export state
- generate exit plan
- show macOS restore guidance

## What it cannot do

- recover kernel-level boot failures
- repair a missing root filesystem
- replace a future Rescue Slot

If the main Cidre system no longer boots far enough to show Recovery Screen,
use Cidre Rescue Slot.
