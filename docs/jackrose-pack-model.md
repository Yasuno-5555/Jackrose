# Jackrose Pack Model

## Overview
Jackrose workload packaging isolates specific use-cases into separate additional packages, avoiding dependency duplication and keeping the base environment sleek but robust.

## Packages
1. `jackrose-meta-default`: Mandatory desktop environment and base tooling.
2. `jackrose-pack-student`: Optional student workload pack.
3. `jackrose-pack-security`: Optional security suite. Requires `jackrose-security-base` and BlackArch repository.
4. `jackrose-pack-calvados`: Optional compatibility runtime.

## Rule
- Package dependencies are declared entirely inside their respective `PKGBUILD` files. Welcome metadata JSON files ONLY serve user display purposes and must not list packages recursively or contain dependency list copies.
