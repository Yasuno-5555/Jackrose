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

---

## 6. Metadata-only Installer Override Harness

To run the override harness tests suite:

```bash
installer/scripts/run-metadata-only-override-harness-tests
```

---

## 7. Bootstrap Safe-mode / No-exec Capability Probe

To run the safe-mode probe tests suite:

```bash
installer/scripts/run-bootstrap-safe-mode-probe-tests
```

---

## 8. Cidre Wrapper Metadata Selection

To run the wrapper selection tests suite:

```bash
installer/scripts/run-cidre-wrapper-selection-tests
```

---

## 9. Cidre Wrapper Artifact Fetch and Integrity Verification

To run the wrapper artifact fetch tests suite:

```bash
installer/scripts/run-cidre-wrapper-artifact-tests
```

---

## 10. Cidre Wrapper Artifact Structure Inspection and Sandbox Extraction

To run the sandbox extraction tests suite:

```bash
installer/scripts/run-cidre-wrapper-extraction-tests
```

---

## 11. Cidre Rootfs Validation and Review-only Install Plan

To run the rootfs content and plan tests suite:

```bash
installer/scripts/run-cidre-rootfs-plan-tests
```

---

## 12. Cidre Read-only Target Discovery

To run the read-only target discovery tests suite:

```bash
installer/scripts/run-cidre-target-discovery-tests
```

---

## 13. Cidre Target Selection Gate

To run the target selection tests suite:

```bash
installer/scripts/run-cidre-target-selection-tests
```

---

## 14. Cidre Final Install Contract

To run the final contract tests suite:

```bash
installer/scripts/run-cidre-final-contract-tests
```

---

## 15. Cidre Installer MVP Freeze

To run the full installer MVP tests suite:

```bash
installer/scripts/run-cidre-installer-mvp-tests
```

---

## 16. GUI Installer Shell Integration

To run the GUI integration smoke tests:

```bash
installer/scripts/run-cidre-gui-integration-smoke-tests
```
