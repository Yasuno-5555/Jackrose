# Jackrose Ghostty Build Notes

## Purpose

This document records the J14 Ghostty packaging work for Jackrose on ALARM / aarch64.

## Current Status

- Phase: `J14`
- Package: `jackrose-ghostty`
- Upstream source: `ghostty-1.3.1.tar.gz`
- Current integration status: `ready-for-build`
- Meta-default status: gated; not enabled in `jackrose-meta-default`

## Source Strategy

Jackrose uses the upstream Ghostty release source tarball rather than a Git checkout.

- Source URL pattern: `https://release.files.ghostty.org/VERSION/ghostty-VERSION.tar.gz`
- Current pinned version: `1.3.1`
- Current tarball sha256: `3349d25600ffbda281197a18314f7d18791969cffe9474f0ff16a45a9ebfccdb`

This follows upstream packaging guidance for distributors and avoids Git-checkout-only preprocessing differences.

## Build Strategy

Current PKGBUILD strategy:

1. Verify the pinned source tarball.
2. Use upstream `nix/build-support/fetch-zig-cache.sh` to prefetch the Zig dependency cache when a real build is permitted.
3. Build with:

```sh
zig build --prefix /usr --system <offline-cache>/p -Doptimize=ReleaseFast -Dcpu=baseline
```

Notes:

- Upstream `PACKAGING.md` states that Ghostty source builds require a matching Zig release and an offline dependency cache populated before the actual build step.
- For `v1.3.1`, `build.zig.zon` declares `minimum_zig_version = "0.15.2"`.
- The controlled J14 helper does not perform a full build unless `--allow-build` or `JACKROSE_ALLOW_PACKAGE_BUILD=1` is set explicitly.
- On the J15 dogfood machine, the first real build attempt failed on the upstream `git+https://github.com/jacobsandlund/uucode` fetch path. The packaging workaround is to prefetch the tarball-backed dependency URLs from `build.zig.zon.txt` and skip `git+` entries during package builds.

## Dependency Discovery

### Build dependency candidates

- `zig`: required by upstream build system; current upstream minimum is `0.15.2`
- `pkgconf`: required for dependency discovery and system library resolution
- `git`: retained as a conservative packaging-time helper dependency
- network access during cache prefetch: required by upstream `fetch-zig-cache.sh` unless the cache is already seeded

### Runtime dependency candidates

- `fontconfig`: dynamic font discovery
- `freetype2`: font rendering
- `glib2`: GTK runtime base
- `gtk4`: Linux application runtime
- `harfbuzz`: text shaping
- `libpng`: icon/image asset handling
- `libxkbcommon`: keyboard handling
- `oniguruma`: regex support used by upstream
- `wayland`: native Linux desktop runtime

### Confirmed dependencies

Confirmed from upstream packaging/build metadata:

- `zig`
- upstream offline Zig cache prefetch step
- resource installation that includes Ghostty resources such as terminfo and shell integration

### Unverified dependencies

- whether ALARM package naming requires additional runtime packages beyond the current conservative set
- whether `gtk4-layer-shell`, `epoxy`, or other transitive graphics libraries need explicit runtime listing in this package

## namcap Warnings

- Historical J11 status was `warn`.
- In the J14 environment, `namcap` is not installed, so warnings cannot be re-evaluated locally.
- PKGBUILD metadata was tightened to remove the empty skeleton shape and pin a real source tarball with checksum.

## aarch64 Notes

- J14 was run on `aarch64`.
- Ghostty upstream now requires Zig `0.15.2` for `1.3.1`.
- The likely aarch64-specific risk is not the package skeleton anymore; it is the real source build path, including Zig cache fetch and any target-specific compiler/runtime issues.

## Desktop Integration

Expected Linux integration outputs from upstream source:

- application desktop entry generated from `dist/linux/app.desktop.in`
- icon name: `com.mitchellh.ghostty`
- optional KDE Dolphin service menu: `ghostty_dolphin.desktop`

J14 package validation treats the following as acceptable evidence when an artifact exists:

- `/usr/share/applications/com.mitchellh.ghostty.desktop`, or
- another Ghostty desktop entry path plus documentation in this file

## terminfo Handling

Upstream ships terminfo source in `src/terminfo/ghostty.zig`.

- preferred names include `xterm-ghostty`, `ghostty`, and `Ghostty`
- J14 expects a validated artifact to either install Ghostty terminfo data or clearly document why terminfo is deferred

## Build Attempt

J14 safe probes completed:

- `makepkg --printsrcinfo`: pass
- `makepkg --verifysource`: pass
- `namcap PKGBUILD`: skipped locally because `namcap` is unavailable

J15 real build completed:

- first attempt failed on upstream `uucode` git dependency fetch in the stock helper path
- second attempt exposed an incorrect static `--system` path expansion in the PKGBUILD
- third attempt exposed that `zig build` was staging to `/usr` during the build step
- after repairing dependency prefetch and build/package staging, the `jackrose-ghostty-1.3.1-1-aarch64.pkg.tar.xz` artifact was produced successfully
- artifact validation passed
- local `pacman -U` install could not be executed in this environment because `sudo` is blocked by `no new privileges`

## Result

The `jackrose-ghostty` package moved from a non-functional skeleton to a real `aarch64` package artifact. The remaining gap is local dogfood install verification in a root-capable environment, not package build feasibility.

## Integration Status

Ghostty remains gated and must not enter `jackrose-meta-default` until a real package artifact is built and validated.
