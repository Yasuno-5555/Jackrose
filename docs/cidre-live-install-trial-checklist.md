# Cidre Live Install Trial Checklist

This checklist defines verification protocols for running a live install trial using the integrated GUI installer shell.

---

## 1. Preconditions

- Verified Cidre rootfs sandbox matches current release.
- At least one partition target of size >= 32 GiB is available.
- Active system, recovery, and EFI partitions are fully operational and untouched.

---

## 2. Manual Verification Checklist

- [ ] **GUI Launches**: GUI starts and opens welcome view.
- [ ] **Image / Artifact Verification**: Verification step completes and returns rootfs validation status.
- [ ] **Target Selection**: Partition candidates populate, and the safe target is selected successfully.
- [ ] **Final Review**: Binds install plan and contract JSON configurations.
- [ ] **Staging Apply**: Confirm confirmation string, execute staging, validate layout, and freeze pipeline status.
- [ ] **Safety Verification**: Ensure `installer-mvp-freeze.json` maps `"installer_mvp_complete": true` and locks remain false.
- [ ] **Boot Preservations**: Confirm macOS default boot policy was not mutated.
- [ ] **Startup Options Handoff**: Manually reboot system, select Cidre target, and confirm Cidre Welcome wizard launches on first startup.
