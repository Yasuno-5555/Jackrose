# Jackrose Niri Baseline

## Policy

Jackrose keeps niri's upstream keybinding model mostly intact.

Jackrose only adds or adjusts baseline desktop entrypoints:

- terminal
- launcher
- bar
- wallpaper
- Japanese keyboard defaults
- Welcome-visible shortcuts

## Baseline Applications

- Terminal: foot
- Launcher: fuzzel
- Bar: waybar
- Wallpaper: swaybg
- Input: fcitx5 managed outside niri config

## Preserved Upstream Areas

Jackrose does not redesign:

- core focus movement
- workspace movement
- column movement
- tiling/floating model
- overview
- screenshots
- fullscreen/maximize behavior

## Jackrose Adjustments

- Japanese keyboard layout: jp / jp106
- Caps as Ctrl: ctrl:nocaps
- touchpad tap / natural-scroll / dwt
- Terminal binding: Mod+Enter launches foot
- Launcher binding: Mod+D launches fuzzel
- Wallpaper path uses /usr/share/jackrose/backgrounds/default.png
- Mod+Shift+R reloads niri config

## Optional Future Presets

- Ghostty preset
- fish preset
- opinionated power-user preset

These are not part of the MVP baseline.
