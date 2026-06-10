# Changelog

All notable changes to ThreatLens AI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.0.0] - 2026-06-10

### Added

- **Security Module** — Secure storage, session management, auth guards, logout wiper
- **Network Module** — Centralized API client with auth, logging, and retry interceptors
- **Router Hardening** — GoRouter redirect logic preventing unauthenticated route access
- **Clean Architecture Enforcement** — Domain/data/presentation layers for all features
- **Threat Modeling Domain Models** — STRIDE categories, DREAD scoring, asset entities
- **Test Suite** — Unit tests for entities, use cases, security, and network modules
- **CI/CD Pipeline** — Secret scanning, dependency auditing, architecture compliance
- **Comprehensive Documentation** — Architecture, security, methodology, deployment guides

### Security

- **Removed DEEPSEEK_API_KEY from client** — All AI requests flow through Supabase Edge Functions
- **Removed shared_preferences** — Replaced with flutter_secure_storage (OWASP MASVS)
- **Added flutter_secure_storage** — Platform keystore-encrypted token storage
- **Added connectivity_plus** — Network connectivity monitoring
- **Added auth guards** — Protected routes require authentication
- **Added session expiration** — Automatic token refresh and logout on expiry
- **Added log redaction** — Sensitive data stripped from all network logs

### Changed

- **EnvironmentConfig** — Removed DeepSeek/OpenAI API key references
- **InitializationService** — Now initializes security and network modules
- **Router** — Added redirect logic for authentication boundaries

### Deprecated

- None

### Removed

- **shared_preferences** — Security risk for token storage
- **Direct AI provider access** — All AI calls proxied through Edge Functions

### Fixed

- None (initial release)
