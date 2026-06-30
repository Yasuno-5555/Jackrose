# Jackrose Firstboot Welcome

## Overview

The firstboot welcome flow ensures that upon initial user session login after running `jackrose-bootstrap`, the user is greeted by `jackrose-welcome --firstboot` presenting the status and basic controls of their newly bootstrapped Jackrose desktop environment.

## Installed Paths

- `/usr/bin/jackrose-bootstrap`
- `/usr/bin/jackrose-firstboot`
- `/usr/bin/jackrose-welcome`
- `/usr/lib/systemd/user/jackrose-firstboot.service`
- `/usr/share/jackrose/defaults/niri/config.kdl`
- `/usr/share/jackrose/backgrounds/default.png`
- `/usr/share/jackrose/welcome/content/desktop-basics.md`
- `/usr/share/jackrose/welcome/content/desktop-basics.ja.md`

## Package Structure

- **`jackrose-bootstrap`**: Packages `scripts/jackrose-bootstrap` to conversion入口.
- **`jackrose-firstboot`**: Packages `scripts/jackrose-firstboot` and `components/firstboot/jackrose-firstboot.service`.
- **`jackrose-welcome`**: Packages `scripts/jackrose-welcome` and the content markdown files under `/usr/share/jackrose/welcome/content/`.
- **`jackrose-config`**: Packages default workspace configuration assets (`config.kdl`).
- **`jackrose-wallpapers`**: Packages standard wallpaper assets (`default.png`).

## Systemd User Service Integration

The user service `jackrose-firstboot.service` is triggered on user session startup:

```ini
[Unit]
Description=Jackrose Firstboot Welcome

[Service]
Type=oneshot
ExecStart=/usr/bin/jackrose-firstboot --run

[Install]
WantedBy=default.target
```

It checks for the completion marker `~/.local/state/jackrose/firstboot.done` and runs the welcome flow once.
