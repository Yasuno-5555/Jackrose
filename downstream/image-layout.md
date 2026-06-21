# Cidre Image Layout

The prototype Cidre image should treat ALARM minimal as the base and add a small downstream overlay.

## Expected Layout

```text
/usr/lib/cidre/
  cidre-firstboot-root
  cidre-seed
  cidre-seed-verify
  cidre-seed-import
  cidre-resume

/etc/systemd/system/
  cidre-firstboot-root.service

/var/lib/cidre/
  seed/
  resume/
  firstboot-root/
```

## Notes

- firstboot-root remains a prototype in v0.14.0
- root autologin is example-only and must not be enabled by default
- seed/resume tooling should be present in the image even before the desktop layer is complete
