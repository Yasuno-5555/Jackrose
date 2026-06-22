# Controlled Mutation Test Mode

Cidre v0.35.4 keeps normal disk mutation disabled. Development-only mutation testing now requires all of the following:

- `CIDRE_MUTATION_TEST_MODE=1`
- `cidre-app-mutation-test-mode --enable`
- `cidre-app-installer-killswitch --enable-for-test --i-understand-dfu-risk`
- a disposable target that passes `cidre-app-disposable-target-check`
- a signed mutation plan and explicit confirmation token

This mode is not a normal install path.
