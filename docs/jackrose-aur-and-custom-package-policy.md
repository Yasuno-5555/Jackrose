# Jackrose AUR and Custom Package Policy

## Principles
1. **Core Pacman Dependency**: Normal system OOBE installations must utilize pacman, Jackrose custom repositories, and official BlackArch repositories only.
2. **Explicit AUR Action**: `paru` is integrated solely as a recovery and developer escape hatch. It must never run silently during firstboot OOBE setup or inside PKGBUILD installation stages.
3. **No Automatic AUR Installs**: Post-installation hooks must not trigger package compile steps via AUR.

## jackrose-paru
`jackrose-paru` is provided as a custom package built using Jackrose recovery configurations.
It must not:
- Run AUR installations automatically or silently behind the scenes.
- Be executed or invoked during firstboot welcome OOBE walkthrough pages.
- Act as the default pacman package resolution backend in OOBE setup configurations.

It may be used by:
- Developer recovery commands or debug prompts.
- App Center Experimental with explicit confirmation dialogue screens.
- Manual user terminal workflows.
