# Cidre Installation Profiles

Cidre supports four distinct installation profiles.

| Profile Name | Target Audience | Core Components Installed | Setup Configuration |
| :--- | :--- | :--- | :--- |
| **desktop** | Default desktop users | niri-cidre, Ghostty, fuzzel, Waybar, Fcitx5-Mozc | Deploys standard styling, Japanese IME, panel indicators |
| **developer** | Developers & power users | desktop + Fish shell, starship prompt, base-devel | Custom terminal shell settings and developer prompts |
| **minimal** | Composition-only users | niri-cidre, foot (fallback TTY shell), config templates | Empty panels, minimal background settings, clean config deploy |
| **recovery** | Maintenance/Rescue tasks | Diagnostic/recovery scripts only | System recovery scripts deployed, user-setup maps to minimal |

## Configuration Profile Mappings
When installing with the `recovery` profile, the system copies recovery scripts to `/usr/bin` but avoids shipping heavy user configurations. Therefore, `cidre-user-setup` maps the user config generation aspect of the `recovery` profile to `minimal` templates.
