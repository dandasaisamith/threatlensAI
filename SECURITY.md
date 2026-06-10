# Security Policy

## Supported Versions

ThreatLens AI is currently in active early development.

| Version | Supported |
| --- | --- |
| 1.x | ✅ |
| < 1.0.0 | ❌ |

## Reporting a Vulnerability

If you discover a vulnerability, please report it privately before creating a public issue.

1. Open a **private security advisory** in this repository, or contact maintainers through a private channel.
2. Include:
   - Affected component and file paths
   - Reproduction steps / proof of concept
   - Impact assessment
   - Suggested remediation (if known)
3. Allow maintainers reasonable time to investigate and patch before public disclosure.

### Response Targets

- Initial triage acknowledgment: **within 5 business days**
- Confirmed issue remediation plan: **within 10 business days**
- Patch release timing: based on severity and exploitability

## Disclosure Process

- Validate and reproduce the report
- Assess severity and affected versions
- Prepare and test a fix
- Publish patch + advisory notes
- Credit reporter (if requested)

## Known Security Considerations

- `.env` values are sensitive and must never be committed
- Threat modeling inputs may contain confidential architecture details
- Third-party backend/API credentials (Supabase, DeepSeek, PostHog, Sentry) must be scoped least-privilege
- Telemetry should be reviewed against local policy and compliance needs

## Best Practices for Secure Use

- Use separate credentials per environment (dev/stage/prod)
- Rotate exposed credentials immediately
- Restrict API keys by origin/usage where supported
- Avoid sharing sensitive threat-model artifacts in public channels
- Keep Flutter/Dart dependencies updated and monitor security advisories

## Data Privacy Statement

ThreatLens AI can process user-supplied architecture/system descriptions and metadata. Repository maintainers do not guarantee secure handling of user-provided deployment environments or third-party services configured by users.

Users are responsible for:

- Data classification of inputs sent to AI/backends
- Applying regulatory/privacy controls required by their organization
- Correct retention/deletion configuration in integrated services

## Incident Reporting Guidelines

For active incidents (credential leak, unauthorized access, suspicious telemetry):

1. Revoke/rotate affected keys immediately
2. Capture timeline and impacted systems
3. Notify maintainers with incident details and containment status
4. Open follow-up issue/advisory after immediate containment
