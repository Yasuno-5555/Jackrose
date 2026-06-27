# Cidre to Asahi/ALARM Installer Data Fields Mappings

## Summary
The fields mappings summarize how Cidre installer-facing JSON translates into upstream Asahi/ALARM installer definitions.

| Cidre field | Installer-facing field | Asahi/ALARM field | Mapping status | Notes |
|---|---|---|---|---|
| `entries[].id` | `images[].id` | `id` | compatible | Maps directly |
| `entries[].name` | `images[].label` | `name` | compatible | Maps to OS display name |
| `entries[].image.url` | `images[].url` | `package` | transform-required | Upstream may expect relative repository base paths |
| `entries[].image.sha256` | `images[].sha256` | `checksum` | compatible | Maps directly |
| `entries[].image.size_bytes` | `images[].size_bytes` | `size` | compatible | Maps directly |
| `entries[].image.manifest` | `images[].manifest` | `manifest` | compatible | Maps directly |
| `entries[].compatibility` | `images[].platform` | `compatibility` | compatible | Mapped properties |

---

## Phase 18 Adapter Mapping

The adapter implements the following mapping transitions:
- `images[].label` ==> `os_list[].name` (Direct)
- `images[].id` ==> `os_list[].id` (Direct)
- `images[].version` ==> `os_list[].version` (Direct)
- `images[].url` ==> `os_list[].url` (Direct/Approximate)
- `images[].url` (filename) ==> `os_list[].package` (Derived/Approximate)
- `images[].sha256` ==> `os_list[].sha256` (Direct)
- `images[].manifest` ==> `os_list[].manifest` (Direct/Cidre Extension)
- `images[].first_boot_mode` ==> `os_list[].first_boot_mode` (Cidre Extension)
