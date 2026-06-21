# Cidre Recovery Guide

If your graphical session, sound stack, or user configuration breaks, this guide provides steps to restore your desktop environment.

## Critical Recovery Scenarios

### Scenario 1: Broken Graphical Session / Login Loop
If `greetd` fails to launch or loop-crashes on boot:
1. Switch to console mode with `Ctrl + Alt + F2`.
2. Log in using your standard user account.
3. Turn off graphical booting to restore standard console logins on next boot:
   ```bash
   sudo cidre-recovery disable-greetd
   ```
4. reboot and troubleshoot niri config or session variables in TTY.

### Scenario 2: Broken User Config
If custom window manager or compositor settings prevent niri from booting:
1. Access TTY.
2. List available configuration snapshots:
   ```bash
   cidre-recovery snapshots
   ```
3. Restore files from the latest working configuration snapshot:
   ```bash
   cidre-recovery restore latest
   ```
4. Or target a specific configuration component for reset:
   ```bash
   cidre-recovery reset-niri
   cidre-recovery reset-waybar
   cidre-recovery reset-shell
   ```
5. Or restore all default system configs:
   ```bash
   cidre-recovery reset-user-config
   ```

### Scenario 3: Broken Audio / Popping Noises
If audio fails to produce sound or generates seek popping noises:
1. Reset the user-level WirePlumber/PipeWire cached states:
   ```bash
   cidre-audio reset
   ```
2. Re-apply the stable audio buffer profile:
   ```bash
   cidre-audio profile stable
   ```

### Scenario 4: Activating Safe-Mode
To quickly bypass custom changes, turn off greetd, and restore standard fallback compositor configurations:
```bash
cidre-recovery safe-mode
```

### Scenario 5: Collecting Diagnostics
To collect journal logs, WirePlumber statuses, and local configs into a report for debugging:
```bash
cidre-recovery collect-logs
```
This saves a report at `~/cidre-recovery-report-*.tar.gz`.
