# ThreatLens AI

AI Threat Modeling Assistant built with Flutter.

## Overview

ThreatLens AI is an intelligent threat modeling platform that uses advanced AI (DeepSeek) to help security professionals:
- Analyze system architectures for security threats
- Generate comprehensive threat models
- Identify assets, attack paths, and vulnerabilities
- Calculate risk scores and mitigation strategies
- Collaborate through AI-powered chat
- Export detailed security reports

## Tech Stack

- **Flutter** - Cross-platform UI framework
- **Riverpod** - State management
- **GoRouter** - Navigation
- **Supabase** - Authentication & Backend
- **DeepSeek API** - AI threat modeling engine
- **Isar** - Local database with offline support
- **Dio** - HTTP client
- **PostHog** - Analytics
- **Sentry** - Error tracking & monitoring
- **Freezed** - Code generation for models

## Architecture

The project follows **Clean Architecture** with:
- **Feature-first** folder structure
- **Repository Pattern** for data access
- **Dependency Injection** for loose coupling
- **SOLID Principles** throughout
- **Offline-first** design with Isar
- **Security-first** approach

### Folder Structure

```
lib/
├── core/                    # Core utilities and infrastructure
│   ├── exceptions/         # Custom exception classes
│   ├── extensions/         # Dart extensions
│   ├── models/            # Core domain models
│   ├── services/          # Core services (initialization, etc.)
│   └── widgets/           # Reusable widgets
├── features/              # Feature modules (feature-first)
│   ├── auth/
│   │   ├── data/         # Data layer (repositories, data sources)
│   │   ├── domain/       # Domain layer (entities, use cases)
│   │   └── presentation/ # Presentation layer (screens, widgets)
│   ├── dashboard/
│   ├── threat_analysis/
│   ├── ai_chat/
│   └── reports/
├── shared/                # Shared utilities
│   ├── models/           # Shared domain models
│   └── providers/        # Shared Riverpod providers
├── services/             # Application services
│   ├── api/             # API clients
│   ├── database/        # Database service
│   └── cache/           # Cache service
├── data/                # Global data layer
└── config/              # Configuration files
```

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
DEEPSEEK_API_KEY=your-api-key
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
- Secure token storage
- Multi-factor authentication ready

### 2. Dashboard
- Recent analyses overview
- Threat statistics
- Risk score summary
- Quick actions

### 3. Threat Analysis
- System description input
- AI-powered threat generation
- Assets identification
- Attack path mapping
- Risk calculation
- Mitigation strategies

### 4. AI Chat
- Context-aware conversation
- Threat modeling focused
- Real-time responses
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
- Conflict resolution

## Development

### Code Generation

Generate models and providers:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Watch for changes:
```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Testing

Run tests:
```bash
flutter test
```

Run specific test:
```bash
flutter test test/features/auth/...
```

### Linting

Check code quality:
```bash
flutter analyze
```

Format code:
```bash
dart format .
```

Fix linting issues:
```bash
dart fix --apply
```

## Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Commit your changes: `git commit -am 'Add feature'`
3. Push to the branch: `git push origin feature/your-feature`
4. Create a Pull Request

### Code Standards

- Follow the existing code style
- Write tests for new features
- Update documentation
- Ensure all lints pass
- Use meaningful commit messages

## Security

- All API keys stored in `.env` (never committed)
- Secure token storage using Supabase
- SSL certificate pinning ready
- Error tracking via Sentry (PII filtered)
- OWASP security best practices

## License

MIT License - See LICENSE file for details

## Support

For issues and questions:
- GitHub Issues: [ThreatLens AI Issues](https://github.com/dandasaisamith/threatlensAI/issues)

## Roadmap

- [ ] Complete Authentication Module
- [ ] Threat Analysis Engine
- [ ] DeepSeek AI Integration
- [ ] Isar Database Setup
- [ ] PDF Report Generation
- [ ] Multi-language Support
- [ ] Advanced Analytics Dashboard
- [ ] Team Collaboration Features
- [ ] API for Third-party Integrations
- [ ] Mobile-specific Optimizations

---

**ThreatLens AI** - Making threat modeling intelligent and accessible.
