# Branch Strategy

ThreatLens AI follows a structured branching model.

## Branch Roles

- **`main`**: production-ready, releasable state
- **`develop`**: integration branch for completed feature work
- **`feature/*`**: new features and enhancements
- **`hotfix/*`**: urgent fixes for production-impacting issues
- **`release/*`**: stabilization branch for an upcoming release

## Workflow

1. Branch from `develop` for `feature/*`
2. Open PR back into `develop`
3. Create `release/*` from `develop` for hardening and release prep
4. Merge `release/*` into `main` when ready
5. Merge `main` back into `develop` after release
6. Branch `hotfix/*` from `main` for urgent production fixes, then merge to both `main` and `develop`

## Quality Gates

- Required CI checks must pass before merge
- Review approval required for protected branches
- No direct pushes to `main`
- Squash or rebase strategy should maintain clear history
