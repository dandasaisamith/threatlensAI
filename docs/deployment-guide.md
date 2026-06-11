# Deployment Guide

## Prerequisites

- Flutter 3.22.0 or higher
- Dart 3.2.0 or higher
- Supabase project with Edge Functions configured
- DeepSeek/OpenAI API key (stored in Supabase Edge Functions only)

## Environment Setup

### 1. Create .env file

```bash
cp .env.example .env
```

Fill in your values:

```env
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-supabase-anon-key
POSTHOG_API_KEY=your-posthog-key
SENTRY_DSN=your-sentry-dsn
APP_ENV=production
DEBUG_MODE=false
```

**IMPORTANT:** Never commit `.env` to version control.

### 2. Install dependencies

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 3. Configure Supabase Edge Functions

Deploy AI proxy functions to your Supabase project:

```bash
supabase functions deploy threat-analysis
supabase functions deploy ai-chat
```

Store AI provider API keys as Supabase secrets:

```bash
supabase secrets set DEEPSEEK_API_KEY=your-key
supabase secrets set OPENAI_API_KEY=your-key
```

## Building for Production

### Android

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## CI/CD Pipeline

The GitHub Actions workflow runs three parallel jobs:

1. **Lint & Analyze** — Secret scanning, lint enforcement, architecture compliance
2. **Build & Test** — Unit tests with coverage, domain/presentation layer validation
3. **Security Checks** — Dependency audit, secure storage verification, .env prevention

Build fails on:
- Lint errors
- Test failures
- Secret leaks
- Architecture violations
- Missing security modules

## Security Checklist

- [ ] `.env` is not committed
- [ ] No AI provider keys in client code
- [ ] `flutter_secure_storage` is in dependencies
- [ ] All security modules present (auth_guard, secure_storage_service, session_manager, logout_wiper)
- [ ] Domain layer has no Flutter/Dio/Supabase imports
- [ ] Presentation layer has no direct API calls
- [ ] All tests passing

## Monitoring

- **Sentry** — Error tracking with PII filtering
- **PostHog** — Analytics (no PII in events)

## Rollback

If a release causes issues:

1. Revert to the previous stable commit on `main`
2. Tag as `hotfix/rollback-vX.Y.Z`
3. Deploy from the reverted branch
