# Cidre v0.15.0 Validation Matrix

The following matrix documents the verification scopes completed on Cidre before the v1.0.0 release.

## Verification Status

| Feature / Area | Static Analysis | Dry-Run | Sandboxed HOME | Live Session | Real Hardware | Notes |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **preinstall setup** | Yes | Yes | N/A | Partial | No | Checks dashboard/wizard flow, fallback backend logic, user/sudo handoff, and network/pacman readiness |
| **macOS bootstrap** | Yes | Planned | N/A | No | No | POSIX shell syntax, Linux rejection path, profile validation, and seed generation paths checked statically |
| **seed verify/import/resume** | Yes | Partial | N/A | No | No | Valid seed verification, invalid profile rejection, unsafe path rejection, non-root import rejection, and resume path wiring checked |
| **downstream foundation** | Yes | Partial | N/A | No | No | Downstream docs exist, installer entry example validates as JSON, rootfs overlay layout exists, and firstboot-root prototype passes syntax checks |
| **image prototype** | Yes | Yes | N/A | No | No | Image build scripts parse, overlay sync runs, overlay tarball and checksum generate, manifest writes, and overlay inspection passes |
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
