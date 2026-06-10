# Threat Modeling Methodology

This document describes the STRIDE and DREAD methodology used by ThreatLens AI.

## 1) STRIDE Overview

STRIDE classifies threats into six categories:

1. **Spoofing** – impersonation of users/systems
2. **Tampering** – unauthorized modification of data/code/state
3. **Repudiation** – inability to prove or audit actions
4. **Information Disclosure** – exposure of sensitive information
5. **Denial of Service** – degradation or unavailability of service
6. **Elevation of Privilege** – unauthorized capability escalation

## 2) DREAD Risk Scoring

DREAD prioritizes threats by scoring:

- **Damage potential**
- **Reproducibility**
- **Exploitability**
- **Affected users**
- **Discoverability**

Recommended scoring: **0-10** each.

Risk score:

```text
(D + R + E + A + D) / 5
```

Suggested interpretation:

- **0.0-3.9** Low
- **4.0-6.9** Medium
- **7.0-10.0** High

## 3) ThreatLens AI Methodology Implementation Status

Current repository status:

- Methodology documentation is implemented
- Runtime threat generation/scoring engine is planned and not fully implemented yet

## 4) Step-by-Step Threat Modeling Process

1. Define system scope and trust boundaries
2. Identify assets and sensitive operations
3. Decompose architecture by component/data flow
4. Enumerate threats using STRIDE per component/flow
5. Score each threat with DREAD
6. Prioritize remediation by risk and feasibility
7. Define mitigation owners and verification tests
8. Reassess after controls are implemented

## 5) Asset Identification Guide

Identify assets in these groups:

- **Identity assets** (accounts, tokens, sessions)
- **Data assets** (PII, configuration, threat artifacts)
- **Service assets** (APIs, queues, databases)
- **Operational assets** (logs, secrets, monitoring signals)

## 6) Attack Path Generation

For each asset, generate attack paths by asking:

- Entry points: where can input/state be influenced?
- Trust boundaries: where does trust level change?
- Required preconditions: what must attacker already control?
- Lateral opportunities: what can be pivoted to next?

## 7) Mitigation Strategy Framework

Prefer controls in this order:

1. Eliminate unsafe design paths
2. Reduce attack surface
3. Enforce strong authentication/authorization
4. Validate/sanitize all untrusted inputs
5. Add defense-in-depth monitoring and alerts
6. Add incident response playbooks and recovery steps

## 8) Example Threat Modeling Session

### Scenario
Mobile client authenticates with backend and requests threat-analysis generation.

### STRIDE Findings

- Spoofing: token theft/replay in compromised device context
- Tampering: modified request payload to bypass server checks
- Information Disclosure: unmasked sensitive architecture notes in logs
- Denial of Service: repeated analysis generation causing quota/resource exhaustion

### DREAD Example Scores

| Threat | D | R | E | A | D | Average | Priority |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Token replay | 8 | 7 | 6 | 8 | 6 | 7.0 | High |
| Payload tampering | 7 | 6 | 6 | 7 | 5 | 6.2 | Medium |
| Sensitive log leakage | 8 | 5 | 4 | 6 | 6 | 5.8 | Medium |
| Analysis request flooding | 7 | 8 | 7 | 7 | 7 | 7.2 | High |

### Mitigations

- Short-lived tokens + device/session binding
- Server-side schema validation and authorization checks
- Sensitive-field redaction in logs/telemetry
- Rate limiting and abuse-detection controls
