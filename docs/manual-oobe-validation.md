# Manual OOBE Setup Target Validation Guide

This guide provides steps for executing and validating `jackrose-oobe` interactively on the target ALARM (Arch Linux ARM) device.

> [!WARNING]
> Do not execute `jackrose-oobe` casually on a primary daily-use system without understanding the state markers. It can reset your default console display targets or mutate accounts.

---

## 1. Verification Preconditions
1. All Jackrose package sets are installed via `pacman -U` into the target system or a prepared chroot rootfs.
2. Root password login is locked (`passwd -S root` shows `L` or locked state).
3. The marker file `/var/lib/jackrose/firstboot.done` is **absent**.
4. The service `jackrose-firstboot.service` is enabled.

---

## 2. Interactive Setup Test Flow

Run `jackrose-oobe` as root in a text console (tty1) or emulator:

```sh
sudo /usr/bin/jackrose-oobe
```

### Step 2.1: Keyboard Layout Configuration
- Action: Select layout options (`jp106` / `us`).
- Verify: Layout maps correctly to system configuration.
- Check state: `/var/lib/jackrose/oobe.state` should contain `keyboard=done`.

### Step 2.2: Keyboard Input Test
- Action: Type special characters `@ : " - _ / \` on prompt.
- Verify: Typed symbols display correctly. If keys are swapped, answer `n` to reject and restart Step 2.1 layout selection.

### Step 2.3: Network Setup (NetworkManager integration)
- Action: Select option `1` to launch `nmtui-connect`. Connect to a local Wi-Fi / Ethernet profile.
- Action: Select option `2` to retry connection checks (pings `archlinux.org`).
- Verify: Online connectivity passes, setting state `network=done` in `oobe.state`.
- Alternate Path (Offline): Select option `3` to skip network connection. Ensure state is recorded as `network=skipped`.

### Step 2.4: User Account Creation
- Action: Input a new username (e.g. `testuser`).
- Verify: 
  - Typing invalid names (e.g. `root`, `jackrose`, `alarm`, `nobody`, `systemd-test`) is rejected with warnings.
  - Setting password completes without error.
  - State matches `user=created` and `username=testuser` in `oobe.state`.

### Step 2.5: User Setup Application (`runuser`)
- Verify:
  - `jackrose-user-setup apply --profile default` runs under the newly created user privilege.
  - Scans confirm no files in `/home/testuser/` are owned by root (fixed automatically if detected).
  - State matches `user_setup=done` in `oobe.state`.

### Step 2.6: OOBE Completion
- Verify:
  - Marker file `/var/lib/jackrose/firstboot.done` is created.
  - The script prompts for system reboot.
  - Choosing exit does not force a reboot.
