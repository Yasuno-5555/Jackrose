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
17. **Firstboot OOBE is Shell/TUI Based**:
   - v0.16.0 firstboot OOBE is script/TUI based and does not provide a GUI installer.
18. **Existing ALARM Login Prompts Remain**:
   - v0.16.0 does not automatically remove login prompts on existing ALARM images.
19. **Real Image Boot Not Guaranteed**:
   - v0.16.0 does not require real image boot validation to complete.
20. **Root Autologin is Not Enabled by Default**:
   - v0.16.0 does not enable root autologin by default.
21. **No Password Storage or Management**:
   - v0.16.0 does not store or manage user passwords.

## v0.17.0 limitations

- v0.17.0 does not publish a public bootable Cidre image.
- v0.17.0 does not perform real Apple Silicon boot validation in CI.
- Image mounting may require root privileges and depends on host tools (`mount`, `losetup`).
- Rootfs inspection does not guarantee boot success.
- Boot log collection only works after a successful or partially successful boot.

## v0.18.0 limitations

- v0.18.0 does not distribute public bootable images.
- Image builder integration assumes local run paths and directory existence; nested VM configurations are not fully automated.
- Promotion checks verify boot validation metadata, but do not prevent manual promotion of unverified assets if forced.
- Manifest schemas (v0.18.0) include builder git revisions but do not sign the artifact logs.

## v0.19.0 limitations

- v0.19.0 real image builds are local prototype builds.
- v0.19.0 does not publish public image artifacts.
- Builder execution depends on host environment and may require root privileges.
- Generated images may still fail to boot.
- Mount/inspect success does not guarantee Apple Silicon boot success.


