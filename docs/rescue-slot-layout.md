# Rescue Slot Layout

- main Cidre and rescue Cidre should remain logically separate
- rescue should not depend on main kernel, initramfs, or rootfs
- recommended size: 8 GiB, with 6 GiB as the minimum planning floor
- metadata should record slot type, profile, boot integration state, and validation status
- non-goals: automatic partition creation, ESP mutation, destructive operations
