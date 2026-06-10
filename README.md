# ThreatLens AI

ThreatLens AI is a Flutter-based threat-modeling workspace focused on secure architecture analysis using STRIDE and DREAD frameworks.

## Current Project Status

ThreatLens AI is currently an early-stage project. The repository contains production-minded project scaffolding, security/monitoring integration points, and UI route/screen shells, while core threat-modeling workflows are still under active development.

## Implemented Features

The following items are verified in the current codebase:

- **Application shell** with Material 3 dark theme (`lib/main.dart`)
- **Navigation routing scaffold** for dashboard, login, threat-analysis, AI chat, and reports screens (`lib/config/router.dart`)
- **Environment configuration loading and validation** from `.env` (`lib/config/environment_config.dart`)
- **Startup initialization flow** for Isar, Supabase, PostHog, and Sentry wiring (`lib/core/services/initialization_service.dart`, `lib/main.dart`)
- **Placeholder UI screens** for major feature areas (dashboard/auth/threat analysis/AI chat/reports)

## Planned Features

These capabilities are planned but not fully implemented yet:

- Full authentication experience and session management UI
- STRIDE-driven automated threat generation workflow
- DREAD scoring engine and mitigation recommendation workflow
- DeepSeek-powered analysis/chat completion pipeline
- Persistent threat-model entities and report export workflow
- Advanced analytics, collaboration, and API integrations

## STRIDE Threat Modeling Methodology

ThreatLens AI is being built around **STRIDE**, a structured model for identifying six threat classes:

- **S**poofing: pretending to be another identity or system
- **T**ampering: unauthorized data or state modification
- **R**epudiation: actions denied due to insufficient audit trails
- **I**nformation Disclosure: sensitive data exposure
- **D**enial of Service: resource exhaustion or service disruption
- **E**levation of Privilege: gaining unauthorized higher permissions

### STRIDE Example

For a mobile app login flow:

- **Spoofing**: attacker reuses stolen tokens
- **Tampering**: attacker modifies local cache/session data
- **Repudiation**: no auditable login action trail
- **Information Disclosure**: API responses leak sensitive profile fields
- **Denial of Service**: repeated login bursts overwhelm auth backend
- **Elevation of Privilege**: normal user accesses admin endpoints

## DREAD Risk Assessment Methodology

ThreatLens AI also applies **DREAD** to score risk severity for each threat:

- **D**amage potential
- **R**eproducibility
- **E**xploitability
- **A**ffected users
- **D**iscoverability

Each category is typically scored from **0-10**. Overall risk is commonly represented as:

`(Damage + Reproducibility + Exploitability + Affected Users + Discoverability) / 5`

### DREAD Example

For “token replay in login flow”:

- Damage: 8
- Reproducibility: 7
- Exploitability: 6
- Affected Users: 8
- Discoverability: 6
- **Average DREAD score: 7.0 (High)**

## Security Considerations for Users

When running ThreatLens AI locally or in shared environments:

- Never commit `.env` files or real credentials
- Use least-privilege Supabase and API keys
- Treat imported architecture/system descriptions as sensitive data
- Avoid entering production secrets in prompt/chat fields
- Review telemetry/error-reporting settings for your compliance needs
- Rotate keys immediately if accidental exposure is suspected

See [SECURITY.md](SECURITY.md) for disclosure and incident reporting guidance.

## Technology Stack

- Flutter (stable release **3.x or higher**)
- Dart (stable release **3.x or higher**)
- Riverpod
- GoRouter
- Supabase Flutter
- Isar
- Dio
- PostHog
- Sentry

## Getting Started

### Prerequisites

- Flutter stable release **3.x or higher**
- Dart stable release **3.x or higher**

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/dandasaisamith/threatlensAI.git
   cd threatlensAI
   ```
2. Copy environment template:
   ```bash
   cp .env.example .env
   ```
3. Fill placeholders in `.env` with your own values.
4. Install dependencies:
   ```bash
   flutter pub get
   ```
5. Run static checks:
   ```bash
   flutter analyze
   ```
6. Run tests:
   ```bash
   flutter test
   ```
7. Run the app:
   ```bash
   flutter run
   ```

## Documentation

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [SECURITY.md](SECURITY.md)
- [CHANGELOG.md](CHANGELOG.md)
- [docs/architecture.md](docs/architecture.md)
- [docs/threat-modeling-methodology.md](docs/threat-modeling-methodology.md)
- [docs/deployment-guide.md](docs/deployment-guide.md)
- [docs/branch-strategy.md](docs/branch-strategy.md)

## License

MIT License — see [LICENSE](LICENSE).

## Support

- GitHub Issues: <https://github.com/dandasaisamith/threatlensAI/issues>
