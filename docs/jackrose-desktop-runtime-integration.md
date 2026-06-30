# Jackrose Desktop Runtime Integration

## Purpose

J18 closes the gap between "package built" and "desktop behaves coherently".

## Fixed Areas

- Ghostty now has a packaged `catppuccin-mocha` theme asset.
- Ghostty now has a packaged `ghostty.desktop` launcher entry.
- Niri now prefers Ghostty while preserving a `foot` fallback.
- Runtime configs no longer tolerate stale `cidre` or `niri-cidre` references.
- `niri-jackrose` is tracked as a P0 candidate without becoming a hard runtime dependency.
- `quickshell` is tracked as a deferred default candidate while Waybar remains the stable baseline.

## Policy

- Preferred components may exist.
- Fallbacks must still work.
- Runtime configs must parse on upstream `niri`.
- Ghostty integration must include both config and launcher assets.
