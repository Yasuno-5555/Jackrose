# Rescue Threat Model

- Wrong partition mount
- Accidental read-write modification
- Rescue/main environment confusion
- Stale rescue metadata or package assumptions
- Data loss during export or cleanup
- False confidence from advisory detection

Boot integration risks:
- wrong slot location
- ESP/main/rescue confusion
- boot entry mutation
- stale rescue environment
