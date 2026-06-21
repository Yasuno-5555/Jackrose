# Cidre Managed Files Inventory

Cidre deploys and monitors configuration templates to keep the user experience predictable and consistent.

## Target Managed Locations

All user configuration files managed under `cidre-user-setup` and `cidre-snapshot` include:

* **Niri Compositor**:
  * `~/.config/niri/config.kdl`
  * `~/.config/niri/config.cidre.kdl`
* **Ghostty Terminal**:
  * `~/.config/ghostty/config`
* **Waybar Panels**:
  * `~/.config/waybar/config`
  * `~/.config/waybar/style.css`
* **Fuzzel Launcher**:
  * `~/.config/fuzzel/fuzzel.ini`
* **Input Method Editor (IME)**:
  * `~/.config/fcitx5/profile`
  * `~/.config/environment.d/90-cidre-ime.conf`
* **Shell configurations**:
  * `~/.config/fish/config.fish`
  * `~/.config/starship/starship.toml`
* **MIME Associations**:
  * `~/.config/mimeapps.list`
* **Desktop Assets**:
  * `~/.local/share/backgrounds/cidre-wallpaper.png`
  * `~/.local/share/applications/com.mitchellh.ghostty.desktop`

## Manifest State
Every deployment records state under `~/.local/state/cidre/manifest.json`, which tracks target file hashes, deployment status, and current profile settings. The `cidre-maintenance drift` command parses this manifest file to detect deviations.

## Seed & Resume State

System-level imported seed and resume state are stored under:

- `/var/lib/cidre/seed/manifest.json`
- `/var/lib/cidre/seed/resume.env`
- `/var/lib/cidre/seed/checksum.txt`
- `/var/lib/cidre/seed/handoff.txt`
- `/var/lib/cidre/seed/import.log`
- `/var/lib/cidre/resume/resume.env`

User-level resume apply state is stored under:

- `~/.local/state/cidre/resume/manifest.json`
- `~/.local/state/cidre/resume/applied-profile`
- `~/.local/state/cidre/resume/applied-at`
- `~/.local/state/cidre/resume/resume.log`
