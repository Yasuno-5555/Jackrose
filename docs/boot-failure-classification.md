# Boot Failure Classification

This document maps error logs and observations to specific failure categories.

## Categories

1. **artifact**:
   The image file or checksum is missing, corrupt, or does not match manifest profiles.
2. **bootloader**:
   Early firmware (m1n1, U-Boot, GRUB) errors before loading the kernel.
3. **kernel**:
   Panic outputs, root filesystem mounting failures, or DTB mismatch.
4. **systemd**:
   Systemd target ordering fails, blocking `cidre-firstboot-root.service`.
5. **firstboot**:
   Firstboot root scripts fail to execute or loop indefinitely.
6. **OOBE**:
   Visual console OOBE prompts do not render.
7. **seed/resume**:
   Bootstrap seeds under `/var/lib/cidre/seed/` are missing or corrupted.
8. **handoff**:
   Normal user account is not created or `install --resume` targets are missing.

## Firstboot Subcategories (v0.21.0)

Cidre v0.21.0 adds detailed classification subcategories:
* **firstboot-service-missing**: The systemd firstboot service unit file is missing or not installed.
* **firstboot-service-not-started**: The firstboot service was scheduled but never initiated execution (no started marker).
* **firstboot-service-failed**: The firstboot setup process crashed or aborted with a non-zero exit code (failed marker present).
* **firstboot-output-not-visible**: The setup outputs did not write to standard terminal displays.
* **firstboot-state-incomplete**: Setup began execution but never reached completion or explicit failure states.
* **firstboot-repeated**: Setup completed but ran again due to missing execution prevention conditions.
* **handoff-missing**: Firstboot completed but failed to generate the required user phase configuration handoff.
* **resume-state-missing**: Execution failed because the bootstrap seed or installer resumption states could not be resolved.
