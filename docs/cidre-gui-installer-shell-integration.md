# GUI Installer Shell Integration

This document details the architecture and integration specification of the Jackrose GUI Installer Shell wrapper.

---

## 1. Architecture

```text
SwiftUI GUI (JackroseInstallerShellView)
  ↓
JackroseInstallerShellViewModel (State Machine)
  ↓
JackroseWrapperPipelineService (Swift-to-Script Bridge)
  ↓
JackroseWrapperScriptRunner (Process/Runner Utility)
  ↓
Phase 24-34 Backend Wrapper Scripts
  ↓
Staging & Freeze JSON Artifacts
```

---

## 2. Safety and Permission Locks

> [!WARNING]
> The GUI functions strictly as a user interface shell.
> The underlying wrapper backend holds final validation authority.
> Partition/resize/format planning checks rely on previously resolved candidates.
> Under all standard circumstances, boot policy mutations (`bless`, `nvram`) remain locked.

---

## 3. Staging and Progress Screen Details

- **Welcome / Mode Selection**: Introduces safety locks and boot policy guidelines.
- **Verification Stage**: Runs select, fetch, sandbox extract, and validation scripts sequentially.
- **Disk / Partition Planner**: Encompasses targetcandidates and selection gates. Blocks active recovery, system, and EFI drives.
- **Final Review**: Binds final contract and displays step actions. Requires typing the exact string: `APPLY JACKROSE STAGING TO SELECTED TARGET`.
- **Progress + Handoff**: Executes staging, validation, boot handoff document writing, and MVP pipeline freezing.
