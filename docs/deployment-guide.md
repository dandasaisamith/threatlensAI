# Deployment Guide

This guide documents how to prepare and deploy ThreatLens AI in its current implementation stage.

## 1) Platform Targets

ThreatLens AI is a Flutter application intended for:

- Android
- iOS
- Web (optional, depending on dependency compatibility and deployment needs)

## 2) Environment Configuration

Create environment files from `.env.example` and provide environment-specific values.

Required values:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `DEEPSEEK_API_KEY`

Optional/operational values:

- `DEEPSEEK_API_BASE_URL`
- `POSTHOG_API_KEY`
- `POSTHOG_API_HOST`
- `SENTRY_DSN`
- `APP_ENV`
- `DEBUG_MODE`

## 3) Backend Setup

### Supabase

- Create isolated projects per environment (dev/stage/prod)
- Use least-privilege anon/service roles
- Apply row-level security policies before production rollout

### DeepSeek API

- Use scoped API keys
- Enforce key rotation and monitoring
- Avoid embedding privileged secrets in client-distributed builds

## 4) Monitoring Setup

### Sentry

- Configure DSN per environment
- Verify PII/data scrubbing policies
- Set release/environment tags for incident triage

### PostHog

- Configure project keys by environment
- Review event schema to avoid sensitive data capture

## 5) CI/CD Setup

Repository includes `.github/workflows/ci.yml` for pull-request checks:

- Flutter dependency installation
- Dart/Flutter analysis
- Tests with coverage generation
- Android/iOS matrix build steps
- Dependency staleness checks

Integrate branch protections so `ci` must pass before merge.

## 6) Build Commands

Use stable Flutter 3.x+:

```bash
flutter pub get
flutter analyze
flutter test --coverage
flutter build apk --release       # Android
flutter build ios --release       # iOS (macOS runner)
```

## 7) Performance Considerations

- Keep startup initialization lightweight and fault-tolerant
- Limit expensive synchronous work on app launch
- Monitor crash-free sessions and route-level latency

## 8) Scaling Considerations

As feature implementation grows:

- Move heavy AI calls through backend-controlled services
- Add request throttling, caching, and queue-based processing
- Separate analytics and operational observability pipelines
- Define SLO/SLA and incident-response standards early
