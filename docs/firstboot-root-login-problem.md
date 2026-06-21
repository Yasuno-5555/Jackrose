# Firstboot Root Login Problem

## Problem Statement

Existing ALARM images may boot to a raw login prompt that expects the user to know default credentials such as `root/root` or `alarm/alarm`.

## Why this is a bad user experience

- users stall before reaching Cidre
- the most fragile phase is outside the current product flow
- default credentials feel unsafe and unfinished

## Why Cidre cannot fix this after login

Cidre cannot help a user who never gets past the login prompt. The solution has to exist at the image level.

## Cidre image-level direction

- boot into a Cidre-controlled firstboot-root entrypoint
- create or verify the normal user
- change or lock bootstrap credentials
- hand off to the user-phase installer

## One-shot autologin policy

- only for Cidre-controlled images
- only for first boot
- removed or disabled after completion
- never enabled by default on existing systems

## Security concerns

Prototype autologin is dangerous if left behind. It must never become a normal operating mode.

v0.16.0 introduces a firstboot OOBE layer intended for future Cidre-controlled images.

This does not change existing ALARM images, but it defines and implements the Cidre-side firstboot path.
