# Mutation Plan Signing

v0.35.4 uses a required SHA-256 plan hash before helper mutation is allowed.

Workflow:

1. Generate a plan with `cidre-app-mutation-plan`.
2. Sign/hash it with `cidre-app-mutation-plan-sign`.
3. Re-verify it with `cidre-app-mutation-plan-verify`.
4. Pass the matching plan, signature, and confirmation token into helper execution.
