# Cidre Installer Wrapper

This directory centralizes policies for the Cidre-owned installer wrapper strategy.

## Safety Boundaries
The Cidre installer wrapper does not execute upstream bootstrap scripts in Phase 26.
It does not run install.sh.
It does not modify disks.
All tasks are sandboxed preflights and validations.
