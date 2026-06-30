# Jackrose Pack Dependency Policy

## Principles
1. **Opinionated Defaults**: Jackrose Default is mandatory. OOBE hides fine-grained configuration choice checkboxes.
2. **PKGBUILD is Source of Truth**: All pack dependencies are declared solely within PKGBUILD files.
3. **No Duplicate JSON Lists**: Pack metadata JSONs (`resources/packs/*.json`) must not declare package dependency lists.
4. **Reality First**: Only confirmed working packages (Bucket A or custom Bucket B) may appear in PKGBUILD `depends`.
5. **No Blind Deletions**: Unconfirmed or fragile packages are categorized as deferred, rather than silently deleted from documentation.

## Dogfood Rule

Dogfood install evidence is required before moving fragile or custom packages toward official default promotion. A package that works on the maintainer machine may still remain gated from active `jackrose-meta-default` depends until the promotion phase is explicit.
