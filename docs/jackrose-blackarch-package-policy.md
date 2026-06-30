# Jackrose BlackArch Package Policy

## Principles
1. **Security Isolation**: BlackArch package repository integration is strictly isolated to Security workload packs.
2. **No Core Dependency**: `jackrose-meta-default`, `jackrose-pack-student`, and `jackrose-pack-calvados` must never require or enable BlackArch.
3. **Explicit Consent**: Enabling the BlackArch repository requires typing `ENABLE BLACKARCH REPOSITORY` in the OOBE.
4. **Validation Flow**: Installing `jackrose-pack-security` must only occur after the BlackArch repository setup is validated.
