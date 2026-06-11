# Threat Modeling Methodology

ThreatLens AI uses two industry-standard frameworks for structured threat analysis: **STRIDE** for threat classification and **DREAD** for risk scoring.

## STRIDE

STRIDE is a threat classification model developed by Microsoft. Each threat is categorized into one of six categories:

### Categories

| Category | Description | What It Prevents | Example Attack |
|----------|-------------|------------------|----------------|
| **S**poofing | Impersonating something or someone | Identity theft | Fake login page, ARP spoofing |
| **T**ampering | Modifying data or code | Data integrity | SQL injection, file modification |
| **R**epudiation | Denying actions without proof | Accountability | Missing audit logs, log deletion |
| **I**nformation Disclosure | Exposing data to unauthorized parties | Confidentiality | Unencrypted API, verbose errors |
| **D**enial of Service | Exhausting resources to deny service | Availability | DDoS, resource exhaustion |
| **E**levation of Privilege | Gaining unauthorized access levels | Authorization | Privilege escalation, buffer overflow |

### STRIDE Threat Identification Process

1. **Decompose the system** — Identify components, data flows, trust boundaries
2. **Map threats to components** — Apply each STRIDE category to each component
3. **Document findings** — Record threats with descriptions and affected assets

### STRIDE-per-Component Mapping

| Component Type | Relevant STRIDE Categories |
|----------------|---------------------------|
| External Entity | Spoofing, Information Disclosure |
| Process | Tampering, Elevation of Privilege, Denial of Service |
| Data Store | Tampering, Information Disclosure, Denial of Service |
| Data Flow | Tampering, Information Disclosure, Denial of Service |

## DREAD

DREAD is a risk scoring model that rates each threat on five dimensions, each scored 1-10:

### Dimensions

| Dimension | Description | Low (1-3) | Medium (4-7) | High (8-10) |
|-----------|-------------|-----------|--------------|-------------|
| **D**amage Potential | Impact if exploited | Minor data loss | Significant impact | Complete system compromise |
| **R**eproducibility | Ease of reproduction | Hard to reproduce | Requires specific conditions | Always reproducible |
| **E**xploitability | Ease of exploitation | Requires significant skill | Moderate skill needed | Trivial to exploit |
| **A**ffected Users | Scope of impact | Single user | Department/team | Entire organization/users |
| **D**iscoverability | How easy to find | Very hard to discover | Requires some probing | Easily discovered |

### DREAD Score Calculation

```
DREAD Score = (D + R + E + A + D) / 5
```

### Risk Classification

| Score Range | Risk Level | Priority | Action |
|-------------|-----------|----------|--------|
| 8.0 - 10.0 | Critical | P0 | Immediate fix required |
| 6.0 - 7.9 | High | P1 | Fix within sprint |
| 4.0 - 5.9 | Medium | P2 | Fix in next release |
| 2.0 - 3.9 | Low | P3 | Fix when possible |
| 1.0 - 1.9 | Informational | P4 | No immediate action |

## ThreatLens AI Pipeline

### 1. Architecture Input

User provides system description:
- System components and their interactions
- Data flows and storage
- Trust boundaries
- External interfaces

### 2. Asset Extraction

AI identifies critical assets:
- Data assets (databases, files, API keys)
- Service assets (APIs, microservices, CDNs)
- Infrastructure assets (servers, networks)
- Human assets (users, administrators)

Each asset is classified by sensitivity level:
- **Critical** — Core business data, credentials
- **High** — User data, financial information
- **Medium** — Internal operational data
- **Low** — Public information

### 3. STRIDE Classification

Each identified threat is classified into STRIDE categories:

```
For each component:
  For each STRIDE category:
    → Identify applicable threats
    → Document attack vectors
    → Link to affected assets
```

### 4. DREAD Scoring

Each threat receives a DREAD score:

```
For each threat:
  → Score Damage Potential (1-10)
  → Score Reproducibility (1-10)
  → Score Exploitability (1-10)
  → Score Affected Users (1-10)
  → Score Discoverability (1-10)
  → Calculate average → Risk Level
```

### 5. Mitigation Generation

For each threat, generate mitigations:

```
For each threat (sorted by DREAD score, descending):
  → Generate prevention controls
  → Generate detection controls
  → Prioritize by risk level
  → Provide implementation guidance
```

### 6. Threat Report

Final output includes:
- Executive summary
- Asset inventory with sensitivity ratings
- Threat catalog with STRIDE classification
- Risk scores with DREAD breakdown
- Prioritized mitigation roadmap
- Appendix with methodology reference

## AI's Role

**AI assists structured threat modeling — it is not the business logic.**

- AI helps generate threat hypotheses based on system descriptions
- STRIDE/DREAD frameworks provide the structure
- Human reviewers validate and refine findings
- The pipeline ensures consistency and completeness

## References

- [Microsoft STRIDE](https://learn.microsoft.com/en-us/azure/security/fundamentals/threat-modeling-tool-terms)
- [OWASP Threat Modeling](https://owasp.org/www-community/Threat_Modeling)
- [OWASP MASVS](https://mas.owasp.org/MASVS/)
