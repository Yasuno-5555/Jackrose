# macOS to Cidre Flow

```text
macOS
↓
Cidre bootstrap
↓
ALARM/Asahi installer
↓
fresh ALARM root
↓
Cidre preinstall
↓
normal user
↓
Cidre install
↓
niri-cidre desktop
↓
exit plan / restore path
```

## Phase Ownership

| Phase | Owner | Entry point | Responsibility |
| :--- | :--- | :--- | :--- |
| macOS | Cidre | `./install-macos` | readiness, profile selection, manifest generation, handoff |
| OS install | Asahi/ALARM | installer | disk, boot, rootfs |
| root phase | Cidre | `./preinstall --import-seed` | seed import, user, sudo, base tools |
| user phase | Cidre | `./install --resume` | desktop/profile setup |
| daily phase | Cidre | doctor/recovery/update | maintenance |
| exit phase | Cidre + macOS | uninstall/export/restore guide | leave safely without guessing |
| restore phase | macOS | `./install-macos --restore-*` | review startup disk and disk layout read-only |
