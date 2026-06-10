# Contributing to ThreatLens AI

Thank you for contributing to ThreatLens AI.

## Code of Conduct

This project follows a respectful, inclusive, and harassment-free collaboration model. Be constructive, assume good intent, and focus feedback on code and behavior.

## Development Setup

1. Install Flutter and Dart stable 3.x+ toolchain
2. Fork and clone the repository
3. Create `.env` from `.env.example`
4. Install dependencies:
   ```bash
   flutter pub get
   ```
5. Run checks before opening PR:
   ```bash
   flutter analyze
   flutter test
   ```

## Branch Naming Convention

Use one of the following patterns:

- `feature/<short-description>`
- `fix/<short-description>`
- `hotfix/<short-description>`
- `docs/<short-description>`
- `chore/<short-description>`

See also: [docs/branch-strategy.md](docs/branch-strategy.md)

## Commit Message Standards

Use clear, imperative commit messages. Conventional Commit style is recommended:

- `feat: add threat scoring placeholder state`
- `fix: handle missing env value parsing`
- `docs: update deployment prerequisites`

## Pull Request Process

1. Keep PRs scoped to a single objective
2. Link related issue(s)
3. Include a concise summary of changes
4. Include testing evidence (commands + result)
5. Update docs when behavior/setup/security guidance changes
6. Request review from maintainers

## Testing Requirements

Before submitting a PR, run:

```bash
flutter analyze
flutter test
```

If your change affects runtime behavior, include additional targeted validation notes.

## Documentation Requirements

Update documentation when you change:

- Setup or deployment instructions
- Security expectations
- Architecture or workflow behavior
- Public interfaces or CLI/API contracts

## Development Environment Notes

- Do not commit `.env` or credentials
- Prefer small, focused PRs over large mixed changes
- Keep generated artifacts and build outputs out of version control
