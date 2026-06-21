# Cidre Image Plan

## Base Image

- ALARM minimal image

## Included Cidre Tools

- `git`
- `curl`
- `sudo`
- `base-devel`
- seed/resume tools
- doctor/recovery tools
- firstboot-root prototype

## Rootfs Overlay

- `/usr/lib/cidre`
- `/etc/systemd/system`
- `/var/lib/cidre`

## Firstboot Root OOBE

The first image objective is not a full desktop install. The first objective is:

```text
boot
↓
Cidre firstboot root OOBE starts
↓
user creation
↓
sudo setup
↓
seed/resume
↓
handoff to ./install --resume
```

## Security Model

- root autologin may exist only as a temporary image bootstrap mechanism
- completion must disable or remove bootstrap-only access
- seed/resume data remains non-secret
