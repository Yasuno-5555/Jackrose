# Jackrose Critical Tool Recovery Policy

## Principles
1. **Maintain Default Identity**: Crucial terminal and development defaults must not be offloaded as low-level user check selections.
2. **Custom Recovery**: Missing tools defined under Jackrose defaults are recovered via customized build pipelines or clean repackaging.
3. **No False Promises**: Experimental packages that are not yet stable are deferred to the App Center and hidden from firstboot OOBE.

## Recovery Strategies
- **jackrose-package**: Build custom Jackrose packages directly.
- **wait-for-upstream**: Await official aarch64 support packages.
- **defer**: Postpone packaging until stability improves.
- **policy-review**: Assess license compatibility and dependencies.
