# Cidre Installer Workspace

This directory manages the installer integration metadata and local selection simulators.

---

## 1. Directory Structure

- `metadata/`: JSON schema and local metadata target configs.
- `fixtures/`: Mock schemas templates for integration validation checks.
- `scripts/`: Local selection executors.
  - `list-installer-entries`: Lists matching candidates.
  - `resolve-installer-entry`: Resolves single entry configurations.
  - `verify-local-image-artifact`: Validates target archives file structures.
  - `simulate-installer-selection`: Performs user selection dry-run simulator.
  - `run-local-integration-tests`: Tests all local scripts.
