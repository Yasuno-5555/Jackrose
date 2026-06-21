# Firstboot Security Notes

## Default Root Credentials

Default root credentials are unsafe and must not be treated as an acceptable long-term state.

## Root Autologin

Root autologin is dangerous.

Cidre treats root autologin as a prototype-image-only bootstrap mechanism, not as a normal feature.

## One-shot Policy

Allowed:

- Cidre-controlled prototype image first boot only
- temporary OOBE bootstrap only
- removed or disabled after completion

Not allowed:

- permanent root autologin
- convenience root autologin on normal systems

## Password Guidance

v0.16.0 does not automatically change or store passwords.

Recommended command:

```sh
passwd root
```

## Seed Privacy

Cidre seed files must not store:

- user passwords
- sudo passwords
- Apple ID data
- SSH private keys
- personal tokens

## Recovery

If firstboot is skipped or fails, recovery should still preserve a clear path back to:

- `cidre-preinstall`
- `cidre-firstboot-handoff`
- `./install --resume`
