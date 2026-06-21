# Cidre Diagnostics Guide

Cidre provides built-in system checks to verify desktop environment health.

## The `cidre-doctor` Command

To analyze the state of your session, configurations, system services, and missing dependencies, run:

```bash
cidre-doctor [options]
```

### Options
- `--daily`: Run the daily driver check suite (checks battery, brightness tooling, screenshot commands, network, and logs).
- `--summary`: Show a condensed status overview (e.g., `Cidre Health: OK=12, WARN=2, FAIL=0`).
- `--verbose`: Display detailed diagnostic parameters.

This runs without root privileges by default. It outputs three check status markers:
- `[OK]`: Component is configured and active.
- `[WARN]`: Non-critical config issues or inactive optional services.
- `[FAIL]`: Critical check failures (missing essential configs, inactive core packages, or invalid session setups).

## Handled Checks

1. **Wayland Session Type**: Detects if `XDG_SESSION_TYPE` is correctly loaded.
2. **Config File Presence**: Ensures Niri, Waybar, Ghostty, Fish shell, and Cidre setup manifests exist.
3. **IME User Service**: Validates Fcitx5 systemd user service status.
4. **Speaker Safety service**: Checks `speakersafetyd` status.
5. **Real-time Scheduling**: Checks if `rtkit-daemon` scheduling prioritizer is active.
6. **Core executables availability**: Verifies presence of `ghostty`, `fuzzel`, `waybar`, `starship`, and `fcitx5`.
7. **Daily Driver Checks** (when using `--daily` or `--verbose`):
   - **Brightness Tool**: Checks presence of `brightnessctl`.
   - **Screenshot Utilities**: Checks presence of `grim` and `slurp`.
   - **Battery Status**: Inspects `/sys/class/power_supply` for battery devices.
   - **Input Method**: Queries `fcitx5-remote` availability.
   - **Network Command**: Checks for `nmcli` availability.
   - **Firstboot State**: Verifies if `firstboot-done` marker is present.
   - **Installation Logs**: Confirms presence of `/var/log/cidre/bootstrap.log`.
