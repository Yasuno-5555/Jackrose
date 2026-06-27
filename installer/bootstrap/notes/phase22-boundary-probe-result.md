# Phase 22 Boundary Probe Result

## Inputs
- INSTALLER_DATA:       http://127.0.0.1:8765/asahi-installer-data.cidre.dev.json
- REPO_BASE:            http://127.0.0.1:8765
- bootstrap snapshot:   installer/bootstrap/upstream/asahi-bootstrap-dev.snapshot.sh

## Validation Results
- URL validation:       failed
- metadata validation:  failed
- selection simulation: failed
- danger-zone scan:     passed

## Decision
C_ADAPTER_OR_LAYOUT_MISMATCH

## Rationale
Failed to validate served installer metadata shape. Output did not conform to expected Asahi schema layouts.

## Next Action
Transition to downstream/wrapper strategy
