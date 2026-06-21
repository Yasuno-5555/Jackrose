# Installer Threat Model

## Cidre does not directly manage APFS

Cidre must not directly resize APFS containers, modify macOS system volumes, or manipulate Apple Silicon boot policy.

## No password storage

Cidre seed manifests must not store user passwords, sudo passwords, Apple ID information, Wi-Fi passwords, SSH private keys, or personal tokens.

## Clear handoff boundaries

Cidre must clearly distinguish between:

- macOS bootstrap
- ALARM/Asahi installation
- Cidre root phase
- Cidre user phase

## Recoverability

Before reboot or handoff, Cidre must display:

- what has been created
- where logs or state are stored
- how to resume manually
- where documentation is located

## Verification

Cidre should record:

- selected profile
- source commit
- dirty tree status
- generated manifest checksum

## Uninstall and Exit Path Risks

- wrong partition deletion
- boot target confusion
- missing state export
- confirmation fatigue
- assuming Linux-side tools can fully restore macOS state
