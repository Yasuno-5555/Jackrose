# Jackrose Firstboot Welcome

This component runs the interactive first-login welcome dashboard after `jackrose-bootstrap` finishes.

## Files

* `jackrose-firstboot.service` -> Copied to `/usr/lib/systemd/user/jackrose-firstboot.service`
* `/usr/bin/jackrose-firstboot` -> System wrapper script

## Manual run

If firstboot Welcome doesn't start automatically:

```bash
jackrose-firstboot --run
```
