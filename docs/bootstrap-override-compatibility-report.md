# Bootstrap Override Compatibility Report

Jackrose can currently generate, serve, fetch, and validate installer_data-shaped metadata, but it has not executed the real Asahi/ALARM installer. The next safe step is a controlled non-executing bootstrap override probe, not a real install.

> [!WARNING]
> Do not run bootstrap scripts yet.
> Do not run install.sh.
> Do not execute curl | sh.
> No real installer execution.

---

## 1. Variables Discovered

# Bootstrap Override Variables Map

| Variable | Source | Line | Pattern | Overrideable | Notes |
|---|---:|---:|---|---|---|
| INSTALLER_DATA | asahi-bootstrap-dev.snapshot.sh | 3 | `INSTALLER_DATA="${INSTALLER_DATA:-...}"` | yes | Metadata URL |
| REPO_BASE | asahi-bootstrap-dev.snapshot.sh | 4 | `REPO_BASE="${REPO_BASE:-...}"` | yes | Package/image base URL |
| INSTALLER_BASE | asahi-bootstrap-dev.snapshot.sh | 5 | `INSTALLER_BASE="${INSTALLER_BASE:-...}"` | yes | Installer package base URL |

---

## 2. Fetch Flow Summary

# Bootstrap Metadata Fetch Flow

1. **Environment Setup**: Read overrides like `INSTALLER_DATA` and `REPO_BASE` from shell.
2. **Metadata fetch**: Curl the descriptor URL.
3. **OS Selection Menu**: Presents human-facing choices.
4. **Installer package fetch**: Downloads packages and manifests.

---

## 3. Execution Boundary Summary

# Bootstrap Execution Boundary

- **HARMFUL Boundary**: Triggered when partitioning commands or system setups (`bless`, `nvram`) write modifications.
- **SAFE Boundary**: Resolving URL connections and fetching metadata in read-only tasks.

---

## 4. Mutation Boundary Summary

# Disk Mutation Boundary Gaps

The partition commands mapped below represent dangerous boundaries:
- `diskutil`: formats volumes.
- `bless`: sets boot configurations.
- `nvram`: sets boot parameters.
- `gpt` / `fdisk`: partitions drives.

---

## 5. Override Strategy

# Jackrose Installer Entry Strategy

## Strategy B: INSTALLER_DATA + REPO_BASE Override

- **Description**: Jackrose overrides both variables to redirect the metadata fetch and target archive download endpoints.
- **Risk Level**: High.
- **Recommended status**: Strategy B investigation only. Do not execute yet.

---

## 6. Risk Register Summary

# Bootstrap Override Risk Register

| Risk ID | Risk | Severity | Trigger | Detection | Mitigation | Status |
|---|---|---:|---|---|---|---|
| R-001 | Bootstrap enters real installer execution | Critical | install.sh / alx.sh call | Static detector | Keep Phase 22 non-execution | Open |
| R-002 | Disk mutation command executes | Critical | diskutil/bless/nvram/etc. | Mutation detector | Never execute bootstrap in Phase 21/22 | Open |
| R-003 | INSTALLER_DATA points to invalid metadata | High | bad URL / invalid JSON | validate-installer-data-url | Validate before any experiment | Mitigated |
| R-004 | Jackrose Asahi-like metadata is not actually upstream-compatible | High | real installer parse failure | compatibility study | Adapter remains prototype | Open |
| R-005 | REPO_BASE semantics differ from Jackrose assumptions | High | package fetch failure | static inspection | Document unresolved behavior | Open |

---

## 7. Minimum Safe Next Experiment

# Minimum safe next experiment

Define the smallest next experiment that Phase 22 may perform.

## 1. Allowed Actions
- Serve generated Asahi-like installer data over localhost.
- Fetch generated metadata with `curl -L`.
- Print `INSTALLER_DATA` / `REPO_BASE` environment variables.
- Validate fetched metadata.
- Simulate selection.
- Inspect bootstrap scripts statically.

## 2. Forbidden Actions
- Execute bootstrap scripts.
- Execute `install.sh`.
- Run `alx.sh`.
- Run `installer-bootstrap.sh`.
- Pipe curl output into shell.
- Use sudo for installer execution.
- Run `diskutil`, `bless`, `nvram`, `gpt`, `fdisk`, `dd`, `mkfs`, `parted`.
- Modify partitions.
- Modify boot policy.
- No real installer execution.

## 3. Success Criteria
- Exporter output matches schema format validations.
- Simulator processes served selection dry-runs correctly.

---

## 8. Open Questions / Recommendation for Phase 22
- Recommend proceeding to Phase 22 (Controlled Bootstrap Override Probe) to test environment variables validation checks.
- Do not authorize installer execution.
