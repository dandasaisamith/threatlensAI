# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| main    | :white_check_mark: |
| develop | :white_check_mark: |

## Reporting a Vulnerability

Please do not disclose vulnerabilities publicly.

Open a [GitHub Security Advisory](https://github.com/dandasaisamith/threatlensAI/security/advisories/new) or contact the project maintainer privately.

Include:
- Steps to reproduce
- Impact assessment
- Screenshots or logs if applicable

**Response time:** 48 hours acknowledgment, 7-day resolution target.

## Security Architecture

### Secrets Management

- **No AI provider secrets (DeepSeek, OpenAI, Claude) are stored in the mobile client**
- All AI requests flow through Supabase Edge Functions
- Backend owns and manages all provider credentials
- `.env` files are never committed to version control

```
Flutter App
    ↓
Supabase Edge Function
    ↓
DeepSeek/OpenAI
    ↓
Response
```

### Authentication & Session Security

- **flutter_secure_storage** for all token storage (Android Keystore / iOS Keychain)
- Never store tokens in SharedPreferences or plain files
- Session expiration handling with automatic refresh
- Complete data wipe on logout via `LogoutWiper`
- Auth guards on all protected routes

### Network Security

- Centralized Dio-based API client with interceptors
- Bearer token injection via `AuthInterceptor`
- Sensitive data redaction in logs (`AppLoggingInterceptor`)
- Retry with exponential backoff (`RetryInterceptor`)
- 30-second connection/receive timeouts

### OWASP MASVS Compliance

- Secure local storage using platform keystores
- No hardcoded secrets
- No direct AI provider access from client
- Backend-enforced authorization
- Encrypted local database (Isar)
- Certificate pinning ready

### Clean Architecture Security

- Domain layer has zero framework dependencies
- Presentation layer cannot make direct API calls
- Repositories mediate between UI and data sources
- Data sources handle all network/storage operations

### CI/CD Security

- Automated secret scanning on every PR
- Dependency vulnerability auditing
- Lint enforcement (build fails on lint errors)
- Architecture compliance verification
- `.env` file commit prevention

## Security Principles

- Least-privilege access
- Defense in depth
- Secure by default
- Zero trust for client-side secrets
- Responsible disclosure

## Dependencies

All dependencies are audited for:
- Known vulnerabilities
- Deprecated packages
- Insecure packages
- Duplicate functionality

Currently using:
- `flutter_secure_storage: ^9.0.0` — OWASP-compliant encrypted storage
- `supabase_flutter: ^1.10.0` — Backend authentication
- `dio: ^5.3.0` — Secure HTTP client with interceptors
