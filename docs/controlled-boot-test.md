# Controlled Boot Test

This document describes how to execute controlled boot tests on target Apple Silicon MacBook systems using the Cidre prototype image framework.

## Purpose

The primary goal of controlled boot validation is to observe the system initialization flow, OOBE startup parameters, temporary autologin scripts, and user handover markers without relying on unvalidated boot policies.

## Test Workflow

1. **Preflight Checks**:
   Check file integrity and manifest states:
   ```bash
   scripts/cidre-boot-preflight --artifact .local/state/cidre/image-build/registered/cidre-prototype-rootfs.img
   ```

2. **Test Environment Preparation**:
   Generate configuration templates and checklists:
   ```bash
   scripts/cidre-controlled-boot-test --prepare --artifact .local/state/cidre/image-build/registered/cidre-prototype-rootfs.img
   ```

3. **Observe Screen Output**:
   Manually boot the system and write observation logs:
   ```bash
   scripts/cidre-boot-observe \
     --firstboot-visible yes \
     --oobe-visible yes \
     --handoff-visible yes \
     --output .local/state/cidre/boot-test/current/observation.md
   ```

4. **Verify Markers**:
   Inspect state files inside rootfs:
   ```bash
   scripts/cidre-firstboot-verify --root / --expect-started
   ```

5. **Generate Summary**:
   Write the execution reports:
   ```bash
   scripts/cidre-controlled-boot-test --report --status success
   ```

## Failure Recovery (v0.21.0)

If a boot test fails or stalls, run the diagnosis and reporting scripts to categorize the failure and log state metrics:
```bash
scripts/cidre-firstboot-diagnose --root /path/to/rootfs
scripts/cidre-firstboot-report --root /path/to/rootfs --output report.md
```
Or via recovery subcommands:
```bash
cidre-recovery firstboot-diagnose
cidre-recovery firstboot-report
```

Controlled boot tests should verify not only firstboot OOBE, but also user phase handoff readiness (using `scripts/cidre-user-handoff --verify` and `scripts/cidre-user-phase-verify`).

Rescue Slot readiness is tracked separately and should remain a warning until dedicated rescue boot integration exists.
