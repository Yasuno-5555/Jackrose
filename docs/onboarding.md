# Cidre Guided Onboarding

Cidre features a guided onboarding process to verify, preview, and apply configuration settings quickly.

## Recommended Installation Path

Instead of manually managing package steps, clone the repository and run the guided installer entrypoint:

```bash
./install
```

This triggers the orchestration utility (`cidre-installer`), which runs the following phases:
1. **Preflight System Checks**: Verifies that Arch Linux/ALARM is detected and core commands like `pacman`, `systemctl`, and `python3` are ready.
2. **Profile Selection**: Interactive prompt to choose between `desktop` (recommended), `developer`, `minimal`, and `recovery` profiles.
3. **Dry-Run Preview**: Shows planned script actions and configuration templates before making modifications.
4. **Confirmation**: Prompt before applying system modifications.
5. **System Bootstrap**: Safe execution of driver setups, display greeters, and session services using root privileges.
6. **User Configuration Deployment**: Safely backups and deploys Catppuccin-themed user configs (`cidre-user-setup`).
7. **Post-Install Diagnostics**: Audits service integrity through `cidre-doctor`.
