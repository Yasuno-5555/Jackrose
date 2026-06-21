# Cidre Known Limitations

This document lists all known limits, caveats, and risk factors regarding the Cidre desktop layer.

## Caveats & Limits

1. **Hardware Verification Status**:
   - **real-hardware clean install not yet fully verified**: Real hardware testing on Apple Silicon Macs is currently deferred to the v1.0.0 milestone. All present tests utilize static analysis, sandboxes, and simulated dry-runs.
2. **Composition & Compositor Limits**:
   - Cidre configures `niri` settings tailored for standard Asahi display constraints but does not modify bootloaders, device tree blocks (DTBs), or m1n1 variables.
3. **No Full System Rollback**:
   - `cidre-snapshot` and `cidre-recovery` manage user-level configurations under the Home directory. They do **not** provide full filesystem transactional updates, root rollbacks, or Snapper/Timeshift/Btrfs-level OS rollback hooks.
4. **Input Method (fcitx5)**:
   - IME activation is managed through systemd user units. Startup behavior depends on standard pam-session loading and environment configs, which can fail to map if launching nested wayland compositors.
5. **Audio Buffer pop-noise prevention**:
   - Pop-noise mitigations depend on specific speakersafetyd and PipeWire versions. Real hardware outputs may vary depending on firmware versions.
6. **Installer Automation (v0.13.0 Limitation)**:
   - Cidre now provides `./install-macos`, `./preinstall --import-seed`, and `./install --resume`, but it still does **not** replace the standard ALARM/Asahi installer, disk partitioning, bootloader work, APFS changes, or m1n1/DTB configuration.
7. **Manual Seed Transfer Required**:
   - v0.13.0 does not automatically inject the generated seed into the ALARM rootfs. Users must manually move the seed into the fresh ALARM environment.
8. **Offline Guarantees Not Provided**:
   - v0.13.0 does not guarantee offline installation unless all required packages are already available locally.
9. **No Public Cidre Image Yet**:
   - Cidre v0.14.0 does not ship a public Cidre image or production installer metadata.
10. **Existing ALARM Login Prompt Still Exists**:
   - Cidre v0.14.0 documents the root/root problem and provides firstboot-root prototypes, but it does not remove the login prompt from existing ALARM images.
11. **firstboot-root Prototype Only**:
   - `cidre-firstboot-root` and the autologin example are prototypes and are not installed or enabled by default.
12. **Prototype Artifact Only**:
   - v0.15.0 artifacts are prototype inspection targets, not public installable images.
13. **Boot Validation Deferred**:
   - v0.15.0 does not require prototype artifacts to boot successfully.
14. **Builder Integration Remains Environment-Dependent**:
   - The image build flow depends on external ALARM builder behavior and currently centers on overlay artifact generation.
15. **Installer Metadata Still Not Production-Integrated**:
   - v0.15.0 does not yet connect prototype artifacts to production installer metadata.
16. **Partition Growth and UUID Behavior Not Verified**:
   - v0.15.0 does not guarantee root partition growth or root UUID scrambling behavior.
