# Naming Policy: Rename Cidre to Jackrose

This document outlines the naming guidelines and policy for the transition from the Cidre project to Jackrose.

## Core Namespaces

| Category | Old Value | New Value |
| --- | --- | --- |
| **Display Name** | Cidre | Jackrose |
| **Lowercase Identifier** | `cidre` | `jackrose` |
| **Uppercase Identifier** | `CIDRE` | `JACKROSE` |
| **Official CLI** | `cidre` / `cidre-*` | `jackrose` / `jackrose-*` |
| **User Configuration** | `~/.config/cidre` | `~/.config/jackrose` |
| **User Local Data** | `~/.local/share/cidre` | `~/.local/share/jackrose` |
| **System Mutable State** | `/etc/cidre` | `/etc/jackrose` |
| **System Mutable Data** | `/var/lib/cidre` | `/var/lib/jackrose` |
| **Package-Owned Assets** | `/usr/share/cidre` | `/usr/share/jackrose` |
| **Systemd Units** | `cidre-*.service` | `jackrose-*.service` |
| **macOS Bundle ID** | `org.cidre.Installer` / `org.cidre.PrivilegedHelper` | `org.jackrose.Installer` / `org.jackrose.PrivilegedHelper` |

## Migration Policy

1. **User Configuration**: User-level configuration directories under `~/.config/cidre` and `~/.local/share/cidre` will be migrated automatically on first boot/run or package installation/upgrade via an idempotent migration script.
2. **System State**: `/etc/cidre` and `/var/lib/cidre` will be migrated where applicable.
3. **Package Assets**: `/usr/share/cidre` will not be moved or modified directly to avoid package manager metadata conflicts. Instead, new packages will deploy assets directly to `/usr/share/jackrose`.
4. **Compatibility Wrappers**: Temporarily, public wrappers for `cidre`, `cidre-doctor`, and `cidre-welcome` will be provided to warn users and forward arguments to `jackrose`.
