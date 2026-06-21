# State Export

Cidre state export preserves the information needed for later debugging or reinstall.

## Included by default

- image-build state
- boot-test state
- exit state
- user-phase state
- doctor state
- seed/resume/firstboot state when present

## Excluded by default

- raw disk images
- compressed image artifacts
- token-like files
- cache-like files

## Output

- `~/.local/state/cidre/exit/current/cidre-state-export.tar.gz`
- `~/.local/state/cidre/exit/current/state-export-manifest.json`

## Privacy Note

Review the manifest before sharing the archive externally.
