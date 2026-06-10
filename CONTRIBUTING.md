# Contributing to ThreatLens AI

Thank you for your interest in contributing to ThreatLens AI.

## Branch Strategy

```
main          ← production releases
  ↑
develop       ← integration branch
  ↑
feature/*     ← new features
hotfix/*      ← urgent production fixes
```

| Branch | Purpose | Protection |
|--------|---------|------------|
| `main` | Production releases | 2 reviews, commit signatures, status checks |
| `develop` | Integration | 1 review, status checks |
| `feature/*` | Feature development | No protection |
| `hotfix/*` | Urgent fixes | 1 review, commit signatures |

## Getting Started

1. Fork the repository
2. Create a feature branch from `develop`:
   ```bash
   git checkout -b feature/your-feature develop
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run code generation:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

## Development Workflow

### Code Standards

- Follow the existing code style and conventions
- Use the existing lint rules in `analysis_options.yaml`
- Run `flutter analyze` before committing — zero errors required
- Run `flutter test` before committing — all tests must pass
- Use meaningful commit messages following Conventional Commits

### Commit Message Format

```
feat(auth): add session expiration handling
fix(router): prevent unauthenticated route access
docs(security): update OWASP compliance section
refactor(network): extract retry logic to interceptor
```

### Clean Architecture Rules

Every feature **must** follow this structure:

```
feature/
  data/           ← Data sources, repository implementations
    datasources/
    repositories/
  domain/         ← Entities, use cases, repository interfaces
    entities/
    repositories/
    use_cases/
  presentation/   ← Screens, widgets, providers
    screens/
    widgets/
```

**Domain layer rules:**
- No Flutter imports
- No Dio imports
- No Supabase imports
- Pure Dart only

**Presentation layer rules:**
- No direct API calls
- No direct database access
- Use repositories through dependency injection

### Testing Requirements

- Write tests for all use cases
- Write tests for all domain entities
- Mock external dependencies using `mocktail`
- Target: 80% coverage on domain layer

Run tests:
```bash
flutter test                    # Run all tests
flutter test --coverage         # Run with coverage
flutter test test/features/     # Run specific feature tests
```

### Security Requirements

- **Never** commit `.env` files or secrets
- **Never** store API keys in source code
- **Never** use `SharedPreferences` for tokens — use `flutter_secure_storage`
- **Never** make direct AI provider calls from the client
- All AI requests must go through Supabase Edge Functions

## Pull Request Process

1. Update documentation if needed
2. Add tests for new features
3. Ensure all CI checks pass
4. Request a review from a maintainer
5. Address review feedback
6. Merge with a merge commit (no squashing on main)

## Questions?

Open a GitHub Issue for questions or discussions.
