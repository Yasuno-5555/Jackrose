# Mutation Verification

After a mutation test, Cidre verifies:

- the planned disposable target changed
- protected Apple partitions did not change
- recovery remained present
- the startup container remained unchanged
- recovery survival checks still pass

Any protected-partition regression is treated as failure containment, not install success.
