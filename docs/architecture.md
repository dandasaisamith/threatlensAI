# ThreatLens AI Architecture

## Overview

ThreatLens AI is a production-grade AI-assisted Threat Modeling platform built with Flutter. It follows Clean Architecture principles with a feature-first folder structure.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Flutter App                       │
│  ┌─────────────┐  ┌─────────────┐  ┌────────────┐  │
│  │ Presentation │  │   Domain    │  │    Data     │  │
│  │  (Screens,  │  │ (Entities,  │  │ (DataSrc,  │  │
│  │  Widgets)   │  │  UseCases)  │  │  Repos)    │  │
│  └──────┬──────┘  └──────┬──────┘  └─────┬──────┘  │
│         │                │               │          │
│  ┌──────┴────────────────┴───────────────┴──────┐   │
│  │              Core Infrastructure             │   │
│  │  Security │ Network │ Services │ Exceptions  │   │
│  └──────────────────────┬───────────────────────┘   │
└─────────────────────────┼───────────────────────────┘
                          │
                  ┌───────▼────────┐
                  │   Supabase     │
                  │  (Auth + DB)   │
                  └───────┬────────┘
                          │
                  ┌───────▼────────┐
                  │ Edge Functions │
                  │  (AI Proxy)    │
                  └───────┬────────┘
                          │
                  ┌───────▼────────┐
                  │  AI Providers  │
                  │ (DeepSeek/OAI) │
                  └────────────────┘
```

## Security Architecture

### No Client-Side Secrets

```
CRITICAL: No AI provider secrets exist in the mobile app.

Flutter App
    ↓ HTTP (Bearer token)
Supabase Edge Function
    ↓ Server-side only
DeepSeek / OpenAI / Claude
    ↓ Response
Supabase Edge Function
    ↓ Response
Flutter App
```

- Edge Functions own all provider API keys
- Client authenticates with Supabase (JWT)
- All AI requests are proxied through backend

### Authentication Flow

```
1. User enters credentials → LoginScreen
2. AuthRepository calls Supabase auth
3. SessionManager stores tokens in SecureStorage
4. AuthGuard checks session state on navigation
5. AuthInterceptor injects Bearer token on API calls
6. SessionManager auto-refreshes before expiry
7. LogoutWiper clears all data on sign-out
```

### Secure Storage Stack

| Layer | Storage | Purpose |
|-------|---------|----------|
| Platform | Android Keystore / iOS Keychain | Encryption keys |
| flutter_secure_storage | EncryptedSharedPreferences | Token storage |
| Isar (encrypted) | Local database | Cached analysis data |

### Network Security

```
Request → RetryInterceptor → AuthInterceptor → LoggingInterceptor → Server
Response ← RetryInterceptor ← AuthInterceptor ← LoggingInterceptor ← Server
```

- **RetryInterceptor**: Exponential backoff with jitter (3 retries max)
- **AuthInterceptor**: Injects Bearer token from SecureStorage
- **LoggingInterceptor**: Redacts tokens, API keys, PII from logs

## Folder Structure

```
lib/
├── config/                    # App configuration
│   ├── environment_config.dart
│   └── router.dart
├── core/                      # Core infrastructure
│   ├── exceptions/            # Custom exception classes
│   ├── extensions/            # Dart extensions
│   ├── network/               # HTTP client + interceptors
│   │   ├── api_client.dart
│   │   └── interceptors/
│   ├── security/              # Auth + session management
│   │   ├── auth_guard.dart
│   │   ├── logout_wiper.dart
│   │   ├── secure_storage_service.dart
│   │   └── session_manager.dart
│   ├── services/              # Core services
│   └── widgets/               # Reusable widgets
├── features/                  # Feature modules
│   ├── auth/
│   │   ├── data/              # Repository implementations, data sources
│   │   ├── domain/            # Entities, use cases, repository interfaces
│   │   └── presentation/      # Screens, widgets
│   ├── dashboard/
│   ├── threat_analysis/
│   ├── ai_chat/
│   └── reports/
├── main.dart
```

## Clean Architecture Layers

### Domain Layer (Innermost)

- **Entities**: Pure data classes with business logic
- **Use Cases**: Single-responsibility business operations
- **Repository Interfaces**: Contracts for data access
- **Rules**: Zero Flutter, Dio, or Supabase imports

### Data Layer

- **Data Sources**: Remote (Edge Functions) and Local (Isar)
- **Repository Implementations**: Coordinate data sources
- **Rules**: Implements domain repository interfaces

### Presentation Layer (Outermost)

- **Screens**: UI components using Riverpod providers
- **Widgets**: Reusable UI components
- **Rules**: No direct API calls — use repositories via DI

## Threat Modeling Engine

### Processing Pipeline

```
Architecture Input (system description)
    ↓
Asset Extraction (identify critical assets)
    ↓
STRIDE Classification (categorize threats)
    ↓
DREAD Scoring (quantify risk)
    ↓
Mitigation Generation (recommend fixes)
    ↓
Threat Report (comprehensive output)
```

### STRIDE Categories

| Category | Description | Example |
|----------|-------------|---------|
| Spoofing | Identity impersonation | Fake login page |
| Tampering | Data modification | SQL injection |
| Repudiation | Denying actions | Missing audit logs |
| Information Disclosure | Data exposure | Unencrypted API response |
| Denial of Service | Availability attacks | DDoS on API |
| Elevation of Privilege | Unauthorized access | Privilege escalation |

### DREAD Scoring

Each threat is scored 1-10 on:
- **D**amage Potential
- **R**eproducibility
- **E**xploitability
- **A**ffected Users
- **D**iscoverability

Average score determines risk priority.

## Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| UI Framework | Flutter 3.22+ | Cross-platform |
| State Management | Riverpod 2.4+ | Reactive state |
| Navigation | GoRouter 14+ | Route management |
| HTTP Client | Dio 5.3+ | Network requests |
| Secure Storage | flutter_secure_storage 9+ | Token storage |
| Backend | Supabase 1.10+ | Auth + DB |
| AI Proxy | Supabase Edge Functions | AI request routing |
| Local DB | Isar 3.1+ | Offline cache |
| Analytics | PostHog | Usage tracking |
| Monitoring | Sentry | Error tracking |
| DI | GetIt 7.6+ | Service location |
| Code Gen | Freezed + json_serializable | Models |
