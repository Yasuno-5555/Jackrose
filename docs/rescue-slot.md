# Cidre Rescue Slot

- Purpose: provide a separate minimal rescue environment when the main Cidre system no longer boots.
- Use it for kernel, initramfs, boot-file, and rootfs failures.
- Keep Rescue separate from the main Cidre rootfs.
- Recommended size: 6-12 GiB, with 8 GiB as a practical starting point.
- Rescue is read-only first. Export before repair.
- If Rescue cannot recover the system, use macOS Restore Assistant and exit path tools.

v0.27.0 adds boot integration planning, but does not yet create a real bootable Rescue Slot.
