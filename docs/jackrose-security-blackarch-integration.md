# Jackrose Security & BlackArch Integration

## Design & Trust Boundary
Enabling security tools requires external tools from the BlackArch Linux project. To preserve the integrity of the core Jackrose system and prevent unconfirmed alterations, the following flow is enforced:

1. **Bootstrap Pack**: The system must have `jackrose-security-base` installed.
2. **Explicit Consent**: The user must explicitly type or confirm the phrase:
   `ENABLE BLACKARCH REPOSITORY`
   to allow repository configuration changes.
3. **Repository Setup**: Once authorized, the backend configures BlackArch keys and repository files.
4. **Tool Verification**: Backend commands validation ensures trust boundaries are maintained and tools verify correctly.
