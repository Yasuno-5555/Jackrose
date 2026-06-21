# Installing Cidre from macOS

Use this flow when you are starting on macOS with an Apple Silicon Mac and want Cidre to guide the handoff into ALARM/Asahi Linux.

## Requirements

- Apple Silicon Mac
- macOS
- `git`, `curl`, `sh`, `tar`, and `shasum` or `openssl`
- internet access for GitHub, Asahi Linux, and Arch Linux ARM resources

## What Cidre does

- verifies that you are on macOS and Apple Silicon
- checks basic command, network, and repository state
- records the selected Cidre profile
- generates a bootstrap manifest and seed for later continuation
- prints the handoff into the ALARM/Asahi installer

## What Cidre does not do

- resize APFS containers
- modify macOS system volumes
- manage Apple Silicon boot policy directly
- install ALARM automatically
- inject the generated seed into the target rootfs automatically

## Steps

### 1. Clone Cidre

```sh
git clone https://github.com/Yasuno-5555/Cidre
cd Cidre
```

### 2. Run the macOS bootstrap

```sh
./install-macos
```

To preview the flow without writing state:

```sh
./install-macos --dry-run
```

### 3. Run the ALARM/Asahi installer

Follow the installer recommended by the bootstrap handoff. Cidre does not own the low-level disk and boot process in v0.13.0.

### 4. Boot into ALARM

After the base installation completes, boot into the new ALARM environment.

### 5. Run the root-phase helper

```sh
./preinstall --import-seed /path/to/cidre-seed.tar.gz
```

### 6. Run the user-phase installer

Switch to the normal user and run:

```sh
./install --resume
```

## Troubleshooting

- `ERROR: ./install-macos must be run on macOS.`: run the command from macOS, not Linux.
- `ERROR: Apple Silicon arm64 Mac is required`: Intel Macs are out of scope.
- bootstrap warnings about a dirty tree: either commit/stash changes or continue knowing the manifest will record the dirty state.
- network reachability warnings: fix connectivity before relying on the installer handoff.

## Recovery Notes

- Re-run `./install-macos --check` to repeat the readiness checks.
- Re-run `./install-macos --print-handoff` to print the continuation steps again.
- Run `./install-macos --restore-help` to print the current restore and removal guidance.
- Run `./install-macos --restore-check` after returning to macOS.
- Generated state is stored under `.local/state/cidre/macos-bootstrap/`.
