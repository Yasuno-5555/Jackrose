# jackrose-installer --json: Structured Output Format

Jackrose CLI tools emit a streaming JSON Lines (JSONL) protocol so GUI wrappers can display progress, errors, and next steps without parsing terminal escape codes.

## Protocol

One JSON object per line, written to stdout. Each line is a complete, parseable JSON object.

```jsonl
{"type":"phase_start","phase":"preflight","timestamp":"2026-06-25T12:00:00Z"}
{"type":"check_result","check":"pacman","status":"ok","detail":"pacman is available"}
{"type":"check_result","check":"network","status":"fail","detail":"No active network link","causes":["..."]}
{"type":"phase_end","phase":"preflight","status":"failed","exit_code":1}
```

Stderr remains human-readable fallback text. `--json` redirects structured output to stdout.

## Event Types

### 1. `banner`

Emitted once at startup.

```json
{
  "type": "banner",
  "timestamp": "2026-06-25T12:00:00Z",
  "version": "0.36.0",
  "profile": "desktop",
  "dry_run": false
}
```

### 2. `phase_start` / `phase_end`

Marks the beginning and end of each install phase.

```json
{
  "type": "phase_start",
  "timestamp": "2026-06-25T12:00:00Z",
  "phase": "preflight",
  "label": "Running System Preflight Checks"
}
```

```json
{
  "type": "phase_end",
  "timestamp": "2026-06-25T12:00:05Z",
  "phase": "preflight",
  "status": "passed",
  "exit_code": 0,
  "summary": "All checks passed"
}
```

Phases: `preflight`, `plan`, `confirmation`, `bootstrap`, `config`, `verify`, `complete`.

### 3. `check_result`

Emitted for each preflight check.

```json
{
  "type": "check_result",
  "timestamp": "2026-06-25T12:00:01Z",
  "check": "pacman",
  "status": "ok",
  "detail": "pacman is available"
}
```

```json
{
  "type": "check_result",
  "timestamp": "2026-06-25T12:00:02Z",
  "check": "network",
  "status": "fail",
  "detail": "No active non-loopback link detected",
  "causes": [
    "Network interface is down",
    "No DHCP lease obtained"
  ],
  "try": [
    "ip link set eth0 up",
    "systemctl start systemd-networkd"
  ]
}
```

Status values: `ok`, `warn`, `fail`.

### 4. `step_start` / `step_end`

Emitted for each sub-step within a phase.

```json
{
  "type": "step_start",
  "timestamp": "2026-06-25T12:00:10Z",
  "step": "install_packages",
  "label": "Installing jackrose-meta-desktop",
  "phase": "bootstrap"
}
```

```json
{
  "type": "step_end",
  "timestamp": "2026-06-25T12:00:30Z",
  "step": "install_packages",
  "status": "passed",
  "detail": "5 packages installed"
}
```

### 5. `step_progress`

Emitted during long-running steps to keep the GUI updated.

```json
{
  "type": "step_progress",
  "timestamp": "2026-06-25T12:00:15Z",
  "step": "install_packages",
  "message": "Installing jackrose-session (3/5)",
  "current": 3,
  "total": 5
}
```

### 6. `brand_promise`

Emitted when showing the safety guarantees.

```json
{
  "type": "brand_promise",
  "timestamp": "2026-06-25T12:00:05Z",
  "guarantees": [
    "macOS default boot",
    "NVRAM boot order",
    "boot policy",
    "recovery partition"
  ],
  "requires_confirmation": true
}
```

### 7. `prompt`

Emitted when user input is needed. The GUI shows a dialog; the response comes via a named pipe or `--json-input`.

```json
{
  "type": "prompt",
  "timestamp": "2026-06-25T12:00:05Z",
  "id": "confirm-install",
  "kind": "confirm",
  "message": "Ready to install Jackrose with profile 'desktop'. Continue?",
  "default": false
}
```

```json
{
  "type": "prompt",
  "id": "select-profile",
  "kind": "select",
  "message": "Choose installation profile",
  "options": [
    {"key": "desktop", "label": "Desktop", "description": "Niri, Ghostty, waybar, fcitx5 Mozc"},
    {"key": "developer", "label": "Developer", "description": "Desktop + dev toolchain"},
    {"key": "student", "label": "Student", "description": "Lightweight desktop"},
    {"key": "minimal", "label": "Minimal", "description": "Core session only"}
  ],
  "default": "desktop"
}
```

### 8. `error`

Emitted on failure. Follows the Likely causes + Try + Log pattern.

```json
{
  "type": "error",
  "timestamp": "2026-06-25T12:00:20Z",
  "phase": "bootstrap",
  "step": "install_packages",
  "title": "pacman database sync failed",
  "causes": [
    "Network is unavailable",
    "Mirror is temporarily unreachable",
    "pacman keyring is outdated"
  ],
  "try": [
    "sudo pacman -Syy",
    "sudo pacman -Sy archlinuxarm-keyring",
    "./install.sh --retry"
  ],
  "log": "~/.local/state/jackrose/install-2026-06-25.log",
  "exit_code": 1,
  "recoverable": true
}
```

### 9. `complete`

Emitted on successful completion.

```json
{
  "type": "complete",
  "timestamp": "2026-06-25T12:01:00Z",
  "profile": "desktop",
  "status": "passed",
  "next_steps": [
    "Reboot the system or log out",
    "Select the 'Jackrose' graphical session at the greeter",
    "On first login, run: jackrose-welcome"
  ],
  "maintenance": [
    {"label": "Diagnostics", "command": "jackrose-doctor --daily"},
    {"label": "Repair configs", "command": "jackrose-repair --configs"},
    {"label": "Audio fix", "command": "jackrose-repair --audio"}
  ],
  "log": "~/.local/state/jackrose/install-2026-06-25.log"
}
```

## Integration Example (SwiftUI)

```swift
class InstallerViewModel: ObservableObject {
    @Published var phase: String = ""
    @Published var steps: [StepState] = []
    @Published var checks: [CheckResult] = []
    @Published var error: InstallError? = nil
    @Published var isComplete: Bool = false
    @Published var prompt: InstallPrompt? = nil

    func startInstall(profile: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "./scripts/jackrose-installer")
        process.arguments = ["--\(profile)", "--json"]

        let pipe = Pipe()
        process.standardOutput = pipe

        pipe.fileHandleForReading.readabilityHandler = { handle in
            if let line = String(data: handle.availableData, encoding: .utf8) {
                for jsonLine in line.split(separator: "\n") {
                    self.handleEvent(jsonLine)
                }
            }
        }

        try? process.run()
    }

    func handleEvent(_ line: String.SubSequence) {
        guard let data = String(line).data(using: .utf8),
              let event = try? JSONDecoder().decode(InstallEvent.self, from: data)
        else { return }

        DispatchQueue.main.async {
            switch event.type {
            case "phase_start":
                self.phase = event.phase ?? ""
            case "check_result":
                self.checks.append(CheckResult(event: event))
            case "error":
                self.error = InstallError(event: event)
            case "complete":
                self.isComplete = true
            case "prompt":
                self.prompt = InstallPrompt(event: event)
            default: break
            }
        }
    }
}
```

## Implementation Plan

1. Add a `--json` flag to `scripts/jackrose-installer` (already parsed in help, not yet functional)
2. Create `lib/jackrose/json.sh` with helper functions:
   - `json_emit type [key=value ...]` — emit a JSON line
   - `json_phase_start phase label`
   - `json_phase_end phase status`
   - `json_check check status detail [causes] [tries]`
   - `json_error title causes tries log`
   - `json_complete profile steps maintenance`
3. Instrument each phase/step in `jackrose-installer` to call json_* functions when `--json` is active
4. Non-JSON mode continues to use lib/jackrose/ui.sh for human-readable output
5. Keep stderr as human-readable fallback even in JSON mode

## Design Decisions

| Decision | Rationale |
|----------|-----------|
| JSONL over stdout | Easy to stream, each line is self-contained, no buffering issues |
| Stderr remains human text | GUI can show stderr as "details" pane; CLI users see normal output |
| `prompt` events for interactivity | GUI can show native dialogs instead of terminal prompts |
| Phase-based hierarchy | Maps directly to the 5-phase install model |
| `recoverable: bool` on errors | GUI can show "Retry" vs "Contact support" buttons |
