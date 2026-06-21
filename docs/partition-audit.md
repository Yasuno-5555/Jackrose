# Partition Audit

`scripts/cidre-partition-audit` records the current Linux-side block device view.

## Commands Used

- `lsblk -f`
- `lsblk -o NAME,SIZE,FSTYPE,FSVER,LABEL,UUID,PARTUUID,MOUNTPOINTS`
- `findmnt`
- `blkid`
- `mount`

## What the Report Means

It captures exact identifiers and mount information visible from Linux.

## What the Report Does Not Mean

- it does not prove which partitions are safe to delete
- it does not confirm macOS startup disk state
- it does not replace macOS-side review

Use it as an audit artifact, not a delete plan.
