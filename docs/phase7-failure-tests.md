# Phase 7: Failure Path Target Validation Test Cases

This checklist details test scenarios designed to verify Jackrose's OOBE error recovery and path validation handlers on the target ALARM platform.

---

## Test Case 1: Missing NetworkManager TUI
- **Setup**: Rename `nmtui-connect` temporary: `sudo mv /usr/bin/nmtui-connect /usr/bin/nmtui-connect.bak`.
- **Action**: Run `sudo jackrose-oobe`.
- **Expected Behavior**: Setup fails during initialization:
  `ERROR: nmtui-connect is not installed. Please install NetworkManager TUI support.`
- **Recovery**: Restore binary: `sudo mv /usr/bin/nmtui-connect.bak /usr/bin/nmtui-connect`.

## Test Case 2: Skipped Network flow
- **Setup**: Run `sudo jackrose-oobe` and select option `3` (Skip network setup).
- **Expected Behavior**: State is set to `network=skipped`. Subsequent custom desktop package installations print warnings explaining that they require network connectivity, preventing errors.
- **Recovery**: Re-run network setup menu inside OOBE.

## Test Case 3: Reserved Usernames Block
- **Setup**: Run `sudo jackrose-oobe`, proceed to account setup, and input `root` or `jackrose` or `alarm`.
- **Expected Behavior**: Entry is rejected with warning: `Username 'X' is a reserved/system name.` Prompt requests a new username.

## Test Case 4: Invalid Username Format
- **Setup**: Input `TestUser` (capitalized) or `user@name` (invalid symbols).
- **Expected Behavior**: Entry is rejected: `Username must be 1-32 chars, lowercase, start with a-z/_, containing only a-z, 0-9, _, -`. Prompt requests a new username.

## Test Case 5: Root-owned Home Directory Files
- **Setup**: Create a root-owned file in user home after useradd but before setup: `sudo touch /home/<username>/.config/rootfile`.
- **Action**: Run OOBE.
- **Expected Behavior**: Permission check warning prints: `WARNING: Found 1 files owned by root in /home/<username>. Fixing ownership...`
- **Verification**: Verify `/home/<username>/.config/rootfile` is now owned by `<username>`.

## Test Case 6: Invalid Completed Marker in Seed Rootfs
- **Setup**: Touch `/var/lib/jackrose/firstboot.done` in the target workspace path.
- **Action**: Run `image/scripts/validate-rootfs --rootfs <target-path>` or `image/scripts/enable-firstboot --rootfs <target-path> --apply`.
- **Expected Behavior**: Execution aborts immediately:
  `Fatal: firstboot.done exists inside the rootfs. Why this matters: jackrose-firstboot.service will not run...`
- **Recovery**: Run `rm <target-path>/var/lib/jackrose/firstboot.done`.

---

## Test Case 7: Ghostty Build Dependency Missing
- **Setup**: Purge build dependencies (like `zig`) or mock missing tools in validation.
- **Action**: Run `jackrose-experience-upgrade --run`.
- **Expected Behavior**: Tool check flags missing tools, writes `ghostty=failed` to `/var/lib/jackrose/experience-upgrade.state`, prints error indicating missing tools, and exits safely without mutating baseline config.

## Test Case 8: niri-jackrose Build Fails
- **Setup**: Induce compiler error in niri-jackrose checkout or select mock build failure mode.
- **Action**: Run `jackrose-experience-upgrade --run`.
- **Expected Behavior**: Upgrade halts on niri-jackrose, records `niri_jackrose=failed` in `.state`, prints logs reference path (`/var/log/jackrose/experience-upgrade.log`), and does NOT create `optimized.done`.
- **Verification**: Session fallback wrapper `jackrose-session` continues launching upstream `niri` successfully.

## Test Case 9: fish Setup Fails
- **Setup**: Mock fish configuration script failure.
- **Action**: Run `jackrose-experience-upgrade --run`.
- **Expected Behavior**: Records `fish=failed` in `.state`. Standard shell environment fallback (`bash`) remains active and user shell defaults are unmodified.

