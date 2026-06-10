# ThreatLens AI Architecture

## High-Level Overview

ThreatLens AI currently provides application scaffolding for a threat-modeling platform. The active implementation is focused on startup, configuration, routing, and integration wiring.

## Component Interaction (Text Diagram)

```text
User
  |
  v
Flutter UI (MaterialApp.router)
  |
  +--> GoRouter (route resolution)
  |       |
  |       +--> Dashboard/Login/ThreatAnalysis/AIChat/Reports screens (currently placeholders)
  |
  +--> Riverpod ProviderScope (state container boundary)
  |
  +--> InitializationService
          |
          +--> EnvironmentConfig (.env load + validation)
          +--> Isar (local persistence initialization)
          +--> Supabase (backend/auth client initialization)
          +--> PostHog (analytics setup)

Sentry wraps app startup for error monitoring.
```

## Data Flow Architecture

1. App startup calls `EnvironmentConfig.initialize()`
2. Required secrets are validated (Supabase URL/key, DeepSeek key)
3. `InitializationService.initialize()` wires local and remote clients
4. Sentry initializes, then app runs under `ProviderScope`
5. GoRouter serves route-level screen scaffolds

Current implementation does not yet include production threat-analysis pipeline data flow.

## Technology Stack Rationale

- **Flutter**: cross-platform UI foundation
- **Riverpod**: predictable state management and dependency boundaries
- **GoRouter**: typed route scaffolding and nested navigation
- **Supabase**: backend/auth integration point
- **Isar**: local persistence foundation
- **PostHog + Sentry**: telemetry and error-observability hooks

## Design Patterns in Use

### Clean Architecture (Planned + Partial Structure)
Project folders are structured by feature/module boundaries, but domain/data use-cases are still being implemented.

### MVVM (Planned)
Presentation-level separation is intended; current screens are placeholders without full ViewModel logic.

### Repository Pattern (Planned)
Repository layer is referenced in architecture goals but not fully implemented yet.

## Dependency Injection Approach

- Riverpod provides app-wide dependency scope through `ProviderScope`
- Service access points are currently static initializers (`InitializationService`)
- Future work can migrate service access into explicit provider-based injection for testability

## Security Architecture

- Environment-based secret loading (`.env`) with required-variable validation
- Explicit separation between configuration loading and app startup
- Sentry initialization for runtime failure visibility
- External service integrations intended to run with least-privilege credentials
