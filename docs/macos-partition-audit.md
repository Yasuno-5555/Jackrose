# macOS Partition Audit

The macOS partition audit uses read-only system tools.

## Sources

- `diskutil list`
- `diskutil apfs list`
- `diskutil info`
- `system_profiler SPStorageDataType`

## Candidate Detection

The report marks partitions as advisory candidates based on:

- name hints such as Asahi, Linux, EFI, U-Boot, or Cidre
- non-macOS-looking type hints
- ambiguous but suspicious layout positions

## Confidence Levels

- `high`
- `medium`
- `low`
- `protected`
- `unknown`

## Warning

This audit is advisory only.
It is not deletion approval.
