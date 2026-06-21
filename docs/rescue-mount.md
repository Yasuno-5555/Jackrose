# Rescue Mount

- Scan likely main Cidre roots with `scripts/cidre-rescue-mount --scan --dry-run`
- Default policy: read-only
- Read-write requires explicit confirmation
- Suggested mount points:
  - `/mnt/cidre-main`
  - `/mnt/cidre-main-boot`
  - `/mnt/cidre-main-efi`
  - `/mnt/cidre-export`
- Do not treat advisory scans as proof that a partition is safe to modify
