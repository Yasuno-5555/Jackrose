# Migration from Cidre to Jackrose

Jackrose is the new name for the project formerly known as Cidre. 

## Migration Steps for Users

For most users, the migration will happen automatically. The first time Jackrose runs or when package upgrades are applied, the system will migrate your configurations.

### Configuration and Data Locations

The following paths are migrated:

- `~/.config/cidre` -> `~/.config/jackrose`
- `~/.local/share/cidre` -> `~/.local/share/jackrose`
- `/etc/cidre` -> `/etc/jackrose` (where applicable)
- `/var/lib/cidre` -> `/var/lib/jackrose` (where applicable)

> [!NOTE]
> System shared assets in `/usr/share/cidre` are owned by the package manager and will not be moved directly. The new packages will populate `/usr/share/jackrose` directly.

### Command Line Interface

The old `cidre` commands are now deprecated. Compatibility wrappers are provided for:
- `cidre` -> forwards to `jackrose`
- `cidre-doctor` -> forwards to `jackrose-doctor`
- `cidre-welcome` -> forwards to `jackrose-welcome`

Please update your scripts and aliases to use `jackrose` instead of `cidre`.
