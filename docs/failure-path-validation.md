# Jackrose OOBE Failure-Path Validation Checklist

This checklist defines validation tests for verification of Jackrose OOBE's behavior under abnormal, missing, or corrupt target conditions.

The guiding principle is: **Do not leave the user at a prompt without a clear next step.**

---

## 1. NetworkManager Connection Failures

### 1.1 `nmtui-connect` is Missing
- **What happened**: Target environment lacks NetworkManager TUI support.
- **What Jackrose tried**: Evaluated `command -v nmtui-connect` before launching setup.
- **Next steps**: Output clear instructions: `Please install NetworkManager TUI support or use a Jackrose seed image.` and exit 1.
- **Logs**: `/var/log/jackrose-oobe.log`

### 1.2 NetworkManager Service is Inactive
- **What happened**: `NetworkManager` is not running.
- **What Jackrose tried**: Executed `systemctl enable --now NetworkManager` during package install or OOBE initialization.
- **Next steps**: Output connection warning, verify `systemctl` status, allow user to retry connection test.
- **Logs**: `/var/log/jackrose-oobe.log`, `journalctl -u NetworkManager`

### 1.3 Network Connection is Skipped
- **What happened**: User selected option to skip network setup.
- **What Jackrose tried**: Recorded `network=skipped` in `/var/lib/jackrose/oobe.state`.
- **Next steps**: Allow configuring user account, but block downstream steps requiring internet connectivity (such as custom desktop package installs).
- **Logs**: `/var/log/jackrose-oobe.log`

---

## 2. User Account Creation Failures

### 2.1 Reserved/System Username Input
- **What happened**: User typed a system name (e.g. `root`, `jackrose`, `alarm`, `nobody`, `systemd-test`).
- **What Jackrose tried**: Matched name against validation blocklist.
- **Next steps**: Prompt: `Reserved username. Please choose another.` and request input again.
- **Logs**: `/var/log/jackrose-oobe.log`

### 2.2 Syntax Validation Failures
- **What happened**: Username entered does not match regex `^[a-z_][a-z0-9_-]{0,31}$`.
- **What Jackrose tried**: Validated syntax using match expressions.
- **Next steps**: Print formatting rules and prompt again.
- **Logs**: `/var/log/jackrose-oobe.log`

---

## 3. Configuration & Permission Failures

### 3.1 `jackrose-user-setup` Failure
- **What happened**: Config tool exits with non-zero code during dotfiles deployment.
- **What Jackrose tried**: Evaluated exit code of `runuser -u <user> -- jackrose-user-setup apply`.
- **Next steps**: Do not write `firstboot.done`. Log failure details, instruct user to review errors, and allow OOBE retry.
- **Logs**: `/var/log/jackrose-oobe.log`, `/home/<user>/.local/state/jackrose/setup/history.log`

### 3.2 Root-owned Dotfiles Detected
- **What happened**: Root-owned files exist inside user's home directory.
- **What Jackrose tried**: Scanned files using `find /home/<user> -maxdepth 2 -user root`.
- **Next steps**: Log warnings, automatically apply `chown -R` remediation, and log the correction.
- **Logs**: `/var/log/jackrose-oobe.log`

---

## 4. Marker & Service Instability

### 4.1 Firstboot Completion Marker Missing
- **What happened**: OOBE was interrupted or cut short.
- **What Jackrose tried**: `/var/lib/jackrose/firstboot.done` was not created.
- **Next steps**: Systemd unit remains enabled; system boots directly back to OOBE tty1 on next startup. Idempotent check ensures completed steps are skipped.
- **Logs**: `/var/log/jackrose-oobe.log`, `/var/lib/jackrose/oobe.state`

### 4.2 Completion Marker Incorrectly Staged
- **What happened**: `firstboot.done` exists in raw seed image.
- **What Jackrose tried**: Ran `validate-rootfs` during build.
- **Next steps**: Validator fails built image with error. User must run `rm /var/lib/jackrose/firstboot.done` inside target rootfs before building image.
- **Logs**: Build output
