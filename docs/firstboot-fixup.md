# Firstboot Fixup

Firstboot failures can hand off to Cidre Recovery Screen.

## Why Firstboot Fixup Exists

During the first boot of a Cidre system, several services must start and execute key steps like user configuration, OOBE flow, and seed/resume verification. However, firstboot processes are historically fragile and prone to failure due to service startup timings, missing configuration directories, network state timeouts, and boot timing variations.

The Cidre Firstboot Fixup Pack provides explicit tools to check status, verify log details, reset states, and repair broken parameters to ensure a robust developer test workflow.

## Common Firstboot Failures

1. **Systemd Unit Ordering Issues**: Timing conflicts when attempting to run before essential targets or waiting indefinitely on `network-online.target`.
2. **Missing State Directory**: Missing configuration keys or files under `/var/lib/cidre/firstboot-root/`.
3. **Execution Errors**: Failures in OOBE script execution, user verification stages, or handoff generation.
4. **Handoff Generation Failures**: Completed runs that fail to save the login and environment resumption guidance commands.

## Diagnose

Run the diagnostics check to verify directory markers:

```bash
scripts/cidre-firstboot-diagnose --root /path/to/rootfs
```

Or via the recovery helper:

```bash
cidre-recovery firstboot-diagnose
```

## Retry

If a firstboot failure is logged but can be retried, reset the failed marker to re-trigger execution:

```bash
scripts/cidre-firstboot-retry --root /path/to/rootfs
```

## Repair

Automate restoration of missing parameters or markers:

```bash
scripts/cidre-firstboot-repair --root /path/to/rootfs --regenerate-handoff
```

Firstboot fixup now hands off to user phase verification and repair tools (`scripts/cidre-user-phase-verify`, `scripts/cidre-user-phase-repair`).

## Service Ordering and Console Visibility

To keep standard boot processes unblocked, systemd ordering constraints have been set conservatively to run after `basic.target` and only optionally wait for network targets. Console output redirection (`StandardOutput=journal+console`) ensures the developer is informed of status directly at boot.
