# Boot Log Collection

Cidre v0.17.0 adds `scripts/cidre-boot-log-collect` for collecting logs after a first boot.

## When to collect

Boot log collection is only meaningful after a boot attempt. Collect logs:

- After a successful first boot (OOBE completed)
- After a partial boot (OOBE started but failed)
- After a boot that showed no output from `cidre-firstboot-root`

## How to collect

On the booted system:

```sh
scripts/cidre-boot-log-collect --output .local/state/cidre/boot-validation/
```

### Dry-run

To see what would be collected without writing anything:

```sh
scripts/cidre-boot-log-collect --dry-run
```

### Skip journal

If `journalctl` is unavailable or too large:

```sh
scripts/cidre-boot-log-collect --no-journal --output <dir>
```

## What is collected

| Output file | Source |
|---|---|
| `journal.txt` | `journalctl -b --no-pager` |
| `cidre-firstboot-root.service.txt` | `systemctl status cidre-firstboot-root.service` |
| `firstboot.log` | `/var/lib/cidre/firstboot-root/firstboot.log` |
| `handoff.txt` | `/var/lib/cidre/firstboot-root/handoff.txt` |
| `doctor-firstboot.txt` | `cidre-doctor --firstboot` |
| `recovery-firstboot-status.txt` | `cidre-recovery firstboot-status` |

## journalctl

Captures the full boot journal, including:

- systemd unit startup order
- `cidre-firstboot-root` output
- OOBE output
- Any crash or timeout messages

## systemctl status

Captures the service status for `cidre-firstboot-root.service`:

- Active state
- Exit code
- Recent log lines

## Firstboot state files

- `firstboot.log`: detailed log written by `cidre-firstboot-root`
- `handoff.txt`: the handoff instruction text shown to the user

If these files are missing, the firstboot script did not reach the log-writing stage.

## doctor/recovery outputs

These confirm whether the system-side state is consistent with what was expected:

- `cidre-doctor --firstboot`: checks scripts, service, and state
- `cidre-recovery firstboot-status`: shows marker state

## How to attach logs to issue/release notes

Compress the output directory and attach or link:

```sh
tar -czf cidre-boot-validation-$(date +%Y%m%d).tar.gz .local/state/cidre/boot-validation/
```

Include in release notes or issue comments as an attachment.
