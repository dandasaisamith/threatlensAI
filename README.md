# ThreatLens AI

AI Threat Modeling Assistant built with Flutter.

## Overview

ThreatLens AI is an intelligent threat modeling platform that uses AI to help security professionals:
- Analyze system architectures for security threats
- Generate comprehensive threat models using STRIDE methodology
- Identify assets, attack paths, and vulnerabilities
- Calculate risk scores using DREAD scoring
- Generate mitigation strategies
- Collaborate through AI-powered chat
- Export detailed security reports

## Security Architecture

```
Flutter App
    ↓ HTTP (Bearer JWT token)
Supabase Edge Function
    ↓ Server-side only
DeepSeek / OpenAI
    ↓ Response
Flutter App
```

**No AI provider secrets exist in the mobile client.** All API keys are managed server-side through Supabase Edge Functions.

## Tech Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| UI Framework | Flutter 3.22+ | Cross-platform |
| State Management | Riverpod 2.4+ | Reactive state |
| Navigation | GoRouter 14+ | Route management |
| HTTP Client | Dio 5.3+ | Network requests |
| Secure Storage | flutter_secure_storage 9+ | Token storage |
| Backend | Supabase 1.10+ | Auth + DB |
| Local DB | Isar 3.1+ | Offline cache |
| Analytics | PostHog | Usage tracking |
| Monitoring | Sentry | Error tracking |

## Architecture

Follows **Clean Architecture** with feature-first folder structure:

```
lib/
├── config/                    # App configuration
├── core/                      # Core infrastructure
│   ├── exceptions/            # Custom exception classes
│   ├── extensions/            # Dart extensions
│   ├── network/               # HTTP client + interceptors
│   ├── security/              # Auth + session management
│   ├── services/              # Core services
│   └── widgets/               # Reusable widgets
├── features/                  # Feature modules
│   ├── auth/
│   │   ├── data/              # Repository implementations
│   │   ├── domain/            # Entities, use cases
│   │   └── presentation/      # Screens, widgets
│   ├── dashboard/
│   ├── threat_analysis/
│   ├── ai_chat/
│   └── reports/
└── main.dart
```

### Domain Layer Rules
- No Flutter imports
- No Dio imports
- No Supabase imports
- Pure Dart only

### Presentation Layer Rules
- No direct API calls
- Use repositories through dependency injection

## Getting Started

### Prerequisites

- Flutter 3.22.0 or higher
- Dart 3.2.0 or higher
- iOS 12.0 or higher
- Android 5.0 (API level 21) or higher

### Installation

1. Clone the repository:
```bash
git clone https://github.com/dandasaisamith/threatlensAI.git
cd threatlensAI
```

2. Create `.env` file from template:
```bash
cp .env.example .env
```

3. Add your configuration:
```env
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-anon-key
POSTHOG_API_KEY=your-posthog-key
SENTRY_DSN=your-sentry-dsn
```

4. Install dependencies:
```bash
flutter pub get
```

5. Generate code:
```bash
dart run build_runner build --delete-conflicting-outputs
```

6. Run the app:
```bash
flutter run
```

## Features

### 1. Authentication
- Supabase authentication
- Secure token storage (flutter_secure_storage)
- Session expiration handling
- Auth guards on protected routes

### 2. Dashboard
- Recent analyses overview
- Threat statistics
- Risk score summary
- Quick actions

### 3. Threat Analysis
- System description input
- STRIDE threat classification
- DREAD risk scoring
- Asset identification
- Mitigation strategies

### 4. AI Chat
- Context-aware conversation
- Threat modeling focused
- Routed through Supabase Edge Functions
- Analysis history

### 5. Reports
- PDF generation
- Export functionality
- Shareable reports
- Analysis archival

### 6. Offline Support
- Local data synchronization
- Offline analysis access
- Automatic sync when online

## Threat Modeling

### STRIDE Classification

| Category | Description |
|----------|-------------|
| Spoofing | Identity impersonation |
| Tampering | Data modification |
| Repudiation | Denying actions |
| Information Disclosure | Data exposure |
| Denial of Service | Availability attacks |
| Elevation of Privilege | Unauthorized access |

### DREAD Scoring

Each threat scored 1-10 on:
- **D**amage Potential
- **R**eproducibility
- **E**xploitability
- **A**ffected Users
- **D**iscoverability

## Development

### Testing

```bash
flutter test                    # Run all tests
flutter test --coverage         # Run with coverage
flutter analyze                 # Check code quality
```

### Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

## CI/CD

GitHub Actions workflow runs:
- **Lint & Analyze** — Secret scanning, lint enforcement, architecture compliance
- **Build & Test** — Unit tests, domain layer validation
- **Security Checks** — Dependency audit, secure storage verification

Build fails on:
- Lint errors
- Test failures
- Secret leaks
- Architecture violations

## Security

- No AI provider secrets in client code
- Secure token storage via flutter_secure_storage
- Auth guards on all protected routes
- Log redaction for sensitive data
- CI/CD secret scanning
- OWASP MASVS compliance

## Documentation

- [Architecture](docs/architecture.md)
- [Threat Modeling Methodology](docs/threat-modeling-methodology.md)
- [Deployment Guide](docs/deployment-guide.md)
- [Security Policy](SECURITY.md)
- [Contributing](CONTRIBUTING.md)
- [Roadmap](docs/roadmap.md)

## License

MIT License - See LICENSE file for details.

## Support

- GitHub Issues: [ThreatLens AI Issues](https://github.com/dandasaisamith/threatlensAI/issues)

---

**ThreatLens AI** - Making threat modeling intelligent and accessible.
