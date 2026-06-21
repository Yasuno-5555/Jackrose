# Cidre v0.18.0 Validation Matrix

The following matrix documents the verification scopes completed on Cidre before the v1.0.0 release.

## Verification Status

| Feature / Area | Static Analysis | Dry-Run | Sandboxed HOME | Live Session | Real Hardware | Notes |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **preinstall setup** | Yes | Yes | N/A | Partial | No | Checks dashboard/wizard flow, fallback backend logic, user/sudo handoff, and network/pacman readiness |
| **macOS bootstrap** | Yes | Planned | N/A | No | No | POSIX shell syntax, Linux rejection path, profile validation, and seed generation paths checked statically |
| **seed verify/import/resume** | Yes | Partial | N/A | No | No | Valid seed verification, invalid profile rejection, unsafe path rejection, non-root import rejection, and resume path wiring checked |
| **downstream foundation** | Yes | Partial | N/A | No | No | Downstream docs exist, installer entry example validates as JSON, rootfs overlay layout exists, and firstboot-root prototype passes syntax checks |
| **image prototype** | Yes | Yes | N/A | No | No | Image build scripts parse, overlay sync runs, overlay tarball and checksum generate, manifest writes, and overlay inspection passes |
| **firstboot OOBE** | Yes | Yes | N/A | No | No | firstboot-root dry-run and status work, state transitions and handoff generation work under simulated roots, doctor/recovery report state, and overlay inspection includes OOBE scripts |
| **builder integration** | Yes | Yes | N/A | No | No | Builder configuration check, staging tree layout, script integration, artifact registration and promotion paths |
| **bootstrap system** | Yes | Yes | N/A | Partial | No | System commands and pacman dependencies simulated |
| **user config apply** | Yes | Yes | Yes | Partial | No | Sandboxed user home file deployment fully tested |
| **diagnostics (doctor)** | Yes | Yes | Yes | Partial | No | Script parsing & maintenance checks verified |
| **niri configuration** | Yes | No | N/A | Partial | No | KDL configuration syntax static parsing verified |
| **audio profile settings** | Yes | No | N/A | Partial | Partial | Verified buffering variables, hardware pop pops popping tests deferred |
| **snapshot & prune** | Yes | Yes | Yes | Partial | No | Pruning chronological ranges and latest protection verified |
| **updates (update)** | Yes | Yes | Yes | Partial | No | Safe pacman synchronization checks verified |
| **maintenance status**| Yes | Yes | Yes | Partial | No | Verified log summaries, path checks, drift metrics |

* **Live Session**: Compositions and greeter tests on standard VMs.
* **Real Hardware**: Apple Silicon Mac environment validation is **deferred** until v1.0.0 clean-install validation.

## Image boot validation (v0.17.0)

| Check | Command |
|---|---|
| Builder status | `scripts/cidre-builder-status` |
| Image mount read-only | `scripts/cidre-image-mount <image>` |
| Rootfs inspect | `scripts/cidre-rootfs-inspect --rootfs <rootfs>` |
| Firstboot service enabled | Check `etc/systemd/system/multi-user.target.wants/` |
| Firstboot state clean | Verify `completed`/`skipped` markers absent |
| Boot readiness | `scripts/cidre-image-boot-readiness --rootfs <rootfs>` |
| Boot checklist | `scripts/cidre-boot-checklist --output checklist.md` |
| Boot log collection | `scripts/cidre-boot-log-collect --dry-run` |
| Doctor boot check | `scripts/cidre-doctor --boot` |
| Recovery boot status | `scripts/cidre-recovery boot-status` |

## Builder Integration Pack (v0.18.0)

| Check | Command |
|---|---|
| Builder config status | `scripts/cidre-builder-config` |
| Overlay injection | `scripts/cidre-builder-integrate --dry-run` |
| Build execution wrap | `scripts/cidre-builder-invoke --dry-run` |
| Build log analysis | `scripts/cidre-builder-log` |
| Artifact registration | `scripts/cidre-builder-artifacts` |
| Image promotion | `scripts/cidre-image-promote` |
| Doctor builder check | `scripts/cidre-doctor --builder` |
| Recovery builder check | `scripts/cidre-recovery builder-status` |

