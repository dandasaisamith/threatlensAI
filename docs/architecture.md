# ThreatLens AI Architecture

## High Level Architecture

Flutter App
  -> Riverpod State Management
  -> Repository Layer
  -> Supabase Backend
  -> Supabase Edge Functions
  -> DeepSeek API

## Security Principles

- No AI provider secrets stored in the mobile app
- Secure token storage using platform keystores
- Backend-enforced authorization
- Offline-first architecture with encrypted local storage

## Planned Layers

features/
  auth/
  dashboard/
  threat_analysis/
  reports/

Each feature contains:
- data
- domain
- presentation