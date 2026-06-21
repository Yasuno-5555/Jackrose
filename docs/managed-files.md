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
