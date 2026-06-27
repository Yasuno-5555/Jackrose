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
  - `inspect-asahi-installer-data`: Inspects upstream metadata schemas.
  - `compare-installer-metadata-shape`: Analyzes mappings overlap between Cidre and Asahi.
  - `run-installer-compat-study-tests`: Runs compatibility study validator.

---

## 2. Upstream Compatibility Study

To run the compatibility analysis suite:

```bash
installer/scripts/run-installer-compat-study-tests
```

---

## 3. Local INSTALLER_DATA Override Dry-run

To execute the override dry-run verification suite:

```bash
installer/scripts/run-installer-override-dryrun-tests
```

---

## 4. Static Bootstrap Override Inspection

To run the bootstrap static analysis suite:

```bash
installer/scripts/run-bootstrap-inspection-tests
```

---

## 5. Controlled Installer Boundary Probe

To run the boundary probe tests suite:

```bash
installer/scripts/run-controlled-installer-boundary-probe-tests
```
