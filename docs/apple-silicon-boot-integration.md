# Apple Silicon Boot Integration

> **Status**: Verified on macOS 26.5.1 (Darwin 25.6) / MacBookAir10,1 (J313AP)
> **Reference implementation**: [Asahi Linux installer](https://github.com/AsahiLinux/asahi-installer)
> **Last updated**: 2026-06-23

## Overview

Apple Silicon Macs use a fundamentally different boot mechanism from Intel Macs.
The Startup Options picker (hold power button at boot) discovers bootable OS
installations by scanning **APFS Volume Groups** that have valid **LocalPolicy**
files in a **Preboot volume**.

This document captures the complete knowledge required to make a non-macOS
volume appear in the Apple Silicon Startup Options picker.

---

## Architecture

### Required APFS Volume Structure

Each bootable OS needs a **Volume Group** consisting of four APFS volumes
in the same container:

| Role     | diskutil flag | Purpose |
|----------|---------------|---------|
| **Data** | `D`           | Provides the Volume Group UUID (VGID). The VGID = Data volume UUID. |
| **System** | `S`         | Holds `System/Library/CoreServices/SystemVersion.plist` and `boot.efi`. Displayed in the boot picker. |
| **Preboot** | `B`         | Holds boot objects (iBoot, kernelcache, firmware, LocalPolicy). Scanned by firmware. |
| **Recovery** | `R`        | Required by bputil/bless for policy management. Can be minimal. |

### The Volume Group UUID

The VGID is the **Data volume's UUID**. This is the identifier used by:
- `bputil -v <vgid>` for policy management
- `diskutil apfs listVolumeGroups` for enumeration
- The firmware for matching Preboot entries

### Preboot Volume Structure

```
<Preboot mount>/<VGID>/
├── boot/
│   ├── active                        # Boot snapshot reference
│   └── <nsih>/                       # Next Stage Image4 Hash directory
│       ├── System/Library/Caches/
│       │   ├── apticket.der          # APTicket (personalized)
│       │   └── com.apple.kernelcaches/
│       │       └── kernelcache       # Kernel cache (30+ MB)
│       └── usr/standalone/firmware/
│           ├── iBoot.img4            # Apple iBoot
│           ├── devicetree.img4       # Device tree
│           ├── Firmware/             # Platform firmware
│           └── *.img4                # Signed firmware images
├── restore/                          # Restore bundle (from macOS)
│   ├── BuildManifest.plist           # Build manifest (73 KB binary plist)
│   ├── RestoreVersion.plist
│   ├── SystemVersion.plist
│   ├── apticket.*.im4m               # APTicket manifests
│   ├── kernelcache.release.*         # Restore kernel cache
│   ├── Firmware/                     # Firmware files
│   ├── Bootability/
│   └── usr/standalone/bootcaches.plist  # Boot cache configuration (22 KB)
├── System/Library/CoreServices/
│   ├── boot.efi                      # Bootloader (text stub or real EFI)
│   └── SystemVersion.plist
└── usr/standalone/firmware/          # Custom firmware (m1n1.bin for Asahi)
```

---

## Boot Policy Creation Flow

### Correct Order of Operations

The order matters critically:

```
1. Create Volume Group (Data → System(groupWith) → Preboot → Recovery)
2. Write SystemVersion.plist + boot.efi to System volume
3. Copy restore bundle to Preboot volume
4. bless --setBoot <System volume>  ← Creates boot structure + LocalPolicy
5. [Verify policy with bputil -e]
6. bless --setBoot <macOS>          ← Restore macOS default
```

### Key Finding: bless creates LocalPolicy automatically

`bless --setBoot` on Apple Silicon:
1. Writes the NVRAM boot preference
2. **Copies the macOS boot chain** (iBoot, kernelcache, firmware) to the target Preboot
3. **Creates a LocalPolicy** with Security Mode: Full
4. Generates the `boot/<nsih>/` directory structure

This means `bputil -g` is **NOT required** for the initial LocalPolicy creation.
`bless --setBoot` handles it implicitly.

### bputil -g: Limitations

`bputil -g` (Reduced Security) has a critical restriction:
- **It only works on the currently booted OS's Volume Group**
- Error "AP boot mode (11)" with `com.apple.bootpolicy Code=11` means the target
  VG is not the active boot OS
- This is why Asahi Linux runs `bputil -g` from step2 (booted into the stub)

### Security Modes

| Mode | flag | Effect |
|------|------|--------|
| **Full Security** | (default) | Only Apple-signed boot.efi and kernelcache allowed |
| **Reduced Security** | `bputil -g` | Allows custom bootloader (m1n1) with valid signature |
| **Permissive Security** | `bputil -n` | Allows unsigned kernel extensions |

For Jackrose/Linux to actually boot, **Reduced Security** is required. This can be:
1. Set via `bputil -g` from within the booted Jackrose environment
2. Set via Startup Security Utility in macOS Recovery
3. Set via Asahi's custom bputil fork (see below)

---

## Diskutil Commands Reference

### Create Volume Group

```bash
# 1. Ensure existing volume has Data role
diskutil apfs changeVolumeRole <disk> D

# 2. Create System volume grouped with Data (this forms the Volume Group)
diskutil apfs addVolume <container> APFS "<name>" -role S -groupWith <data_disk>

# 3. Create Preboot volume
diskutil apfs addVolume <container> APFS Preboot -role B

# 4. Create Recovery volume
diskutil apfs addVolume <container> APFS Recovery -role R
```

### Verify Volume Group

```bash
diskutil apfs listVolumeGroups -plist
```

### Inspect Preboot

```bash
diskutil apfs updatePreboot <system_disk>   # Sync Preboot (macOS volumes only)
```

---

## Error Codes Reference

### bputil errors (BYErrorDomain)

| Code | Message | Meaning | Solution |
|------|---------|---------|----------|
| 603 | (null) | Missing Preboot/Recovery volumes in container | Create Preboot (role B) and Recovery (role R) |
| 112 | Preserved restore bundle in preboot is missing | No restore bundle on Preboot | Copy macOS restore bundle (BuildManifest.plist, etc.) |
| 113 | Preserved restore bundle in preboot is invalid | Missing BuildManifest.plist or bootcaches.plist | Copy macOS restore bundle; ensure usr/standalone/bootcaches.plist exists |
| 401 | Failed to create local policy / AP boot mode (11) | Target VG is not the current boot OS | Must be booted into the target OS; use bless first |

### bless errors (BYErrorDomain)

| Code | Message | Meaning |
|------|---------|---------|
| 103 | Owner authentication is required | Needs `--user <username> --stdinpass` |

### updatePreboot errors

| Code | Message | Meaning |
|------|---------|---------|
| -69572 | Subject Volume UUID directory not found | Preboot volume doesn't have VGID directory |
| -69808 | Some information unavailable | Volume is not a proper macOS installation (no OD, no crypto users) |

---

## Privilege Model

### Two Separate Authentication Requirements

| Type | Purpose | How to obtain |
|------|---------|---------------|
| **Administrator (root)** | Write to protected paths, run diskutil mutations | `osascript do shell script with administrator privileges` |
| **Owner** | Sign boot policy changes, access signing key | `bless --user <user> --stdinpass`, `bputil -u <user> -p <pass>` |

### osascript stdin limitation

`osascript do shell script` does **NOT** forward stdin to the child process.
Workaround: write password to temp file (chmod 600), use shell redirect:

```bash
pw_file="$(mktemp /tmp/jackrose-bless-pw.XXXXXX)"
printf '%s' "$password" > "$pw_file"
chmod 600 "$pw_file"
osascript -e "do shell script \"cat ${pw_file} | bless --setBoot ... --stdinpass\" with administrator privileges"
rm -f "$pw_file"
```

---

## Known Limitations

### 1. bputil cannot create Reduced Security policy for non-booted VG

Apple's `bputil -g` requires the target Volume Group to be the currently booted OS.
For a stub that cannot yet boot (no valid bootloader), this is a chicken-and-egg problem.

**Workarounds:**
- Use `bless --setBoot` to create a Full Security policy (shows in boot picker,
  but can't boot unsigned bootloader)
- Set Reduced Security from macOS Recovery (Startup Security Utility)
- Use [Asahi Linux's bputil fork](https://github.com/AsahiLinux/bputil) which
  can create policies for non-booted VGs

### 2. System Preboot vs Container Preboot

- **System Preboot** (`/System/Volumes/Preboot`, disk4s2): SIP-protected, stores
  LocalPolicy files. Only writable by Apple-signed tools (bless, bputil).
- **Container Preboot** (per-container, role B): NOT SIP-protected. Stores boot
  objects (iBoot, kernelcache). Can be written with admin privileges.

`bless --setBoot` writes boot objects to the **container Preboot**. LocalPolicy
metadata is managed by Apple's framework.

### 3. text-stub boot.efi is insufficient for boot

A text placeholder boot.efi allows Volume Group creation and bless to work,
but the actual boot requires a valid EFI executable:
- **m1n1.bin** from Asahi Linux (stage-1 bootloader for Apple Silicon)
- Or a proper EFI application built for aarch64

Without a real bootloader, selecting Jackrose in Startup Options will fall through
to the next bootable volume (macOS) or show an error.

### 4. changeVolumeRole limitations

`diskutil apfs changeVolumeRole` can set the **Data** role on most volumes,
but **System** role assignment may fail with error -69599 on encrypted or
already-provisioned volumes. Use `addVolume -role S -groupWith <data>` for
new volumes instead.

---

## Asahi Linux Reference

The Asahi Linux installer (`asahi-installer`) is the reference implementation.
Key architectural differences from Jackrose's current approach:

| Aspect | Asahi | Jackrose (current) |
|--------|-------|-----------------|
| Bootloader | m1n1.bin (real stage-1) | Text stub |
| Volume creation | 4 volumes at creation time | Single volume, then backfill |
| bputil | Ran from step2 (booted stub) | Attempted from macOS |
| Credentials | getpass in Python | osascript + temp file |
| Restore bundle | Full macOS restore bundle | Copied from macOS |

### Key files in asahi-installer

- `src/stub.py` → `prepare_volume()` — creates System/Data/Preboot/Recovery
- `src/stub.py` → `install_files()` — writes boot files, restore bundle
- `src/main.py` → `set_reduced_security()` — calls bputil
- `src/main.py` → `bless()` — blesses stub (step2 context)

---

## Script Architecture (Jackrose)

### jackrose-app-boot-policy-create

The unified script that handles everything (can be called from GUI wizard):

```
Phase 1: Discovery — check existing Volume Group, volumes, roles
Phase 2: Volume Group setup — create missing Data/System/Preboot/Recovery
Phase 3: Boot files — write SystemVersion.plist + boot.efi to System volume
Phase 4: Restore bundle — copy macOS restore bundle to Jackrose Preboot
Phase 5: bless --setBoot Jackrose → bputil -g → bless --setBoot macOS
Phase 6: Report — JSON output with status
```

All admin operations use `osascript do shell script with administrator privileges`.
Owner authentication (for bless) uses temp file + shell redirect.

### GUI Integration Points

The script accepts `--owner-user` and `--owner-password` arguments for GUI
integration. In the GUI wizard flow:

1. Collect admin credentials during "privileged preparation" step
2. Pass credentials via `--owner-user` / `--owner-password`
3. osascript dialogs appear naturally for admin auth
4. bless owner auth handled via stdin redirect

---

## Verification Checklist

After running `jackrose-app-boot-policy-create`:

- [ ] `diskutil apfs listVolumeGroups` shows Jackrose VG with VGID
- [ ] Jackrose Preboot has `boot/<nsih>/` with iBoot, kernelcache, firmware
- [ ] Jackrose Preboot has `restore/` with BuildManifest.plist, bootcaches.plist
- [ ] `bputil -e` shows LocalPolicy for Jackrose VGID
- [ ] `bputil -e` shows `Pairing Integrity: Valid`
- [ ] `bless --getBoot` returns macOS (not Jackrose — we restored it)
- [ ] Reboot + hold power button → Jackrose visible in Startup Options

---

## m1n1 Bootloader Acquisition

Jackrose uses m1n1 from Asahi Linux as the stage-1 bootloader for Apple Silicon.

### Building from source

```bash
# Requires: Rust (rustup), git
git clone --recurse-submodules https://github.com/AsahiLinux/m1n1.git
cd m1n1
make RELEASE=1 CHAINLOADING=1
```

Output: `build/m1n1.macho`

**Known issue**: m1n1 may fail to compile with Rust >= 1.96 due to dependency
API changes. If you encounter `cargo` errors, try Rust 1.85 (the version
used by Asahi's CI). Use `rustup default 1.85` before building.

### Placing the binary

```bash
cp build/m1n1.macho <jackrose-repo>/libexec/m1n1.macho
```

The `jackrose-app-m1n1-acquire` script searches for m1n1 in:
1. `--m1n1-path` (explicit CLI argument)
2. `libexec/m1n1.macho` (bundled with Jackrose)
3. `~/.local/share/jackrose/m1n1/cached/m1n1.macho` (cached from download)
4. Debian sid arm64 package (automatic download)

### Creating a fake Mach-O for testing

For testing the boot policy flow without a real m1n1:

```bash
python3 -c "
import struct
# Minimal Mach-O header (aarch64)
header = struct.pack('<7I', 0xfeedfacf, 0x0100000c, 0, 0x00000002, 0x00000028, 0, 0x00000001)
with open('libexec/m1n1.macho', 'wb') as f:
    f.write(header + b'\x00' * 1024)
"
```

**Warning**: This creates a fake Mach-O that will NOT boot. It only satisfies
basic validation checks. Use only for development/testing.

---

## References

- [Asahi Linux installer](https://github.com/AsahiLinux/asahi-installer)
- [Asahi Linux bputil fork](https://github.com/AsahiLinux/bputil)
- [m1n1 bootloader](https://github.com/AsahiLinux/m1n1)
- `man bless`, `man bputil`, `man diskutil`
- Apple Platform Security documentation
