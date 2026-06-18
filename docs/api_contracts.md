# ThreatLens AI - API Contracts

## Base URL
```
https://api.threatlensai.com/v1
```

## Authentication
All API endpoints require Bearer token authentication via Supabase JWT.

```
Authorization: Bearer <jwt_token>
```

---

## 1. Authentication Endpoints

### Register User
**POST** `/auth/register`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securepassword",
  "full_name": "John Doe",
  "organization_name": "ACME Corp"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "user_id": "uuid",
    "email": "user@example.com",
    "full_name": "John Doe",
    "organization_id": "uuid",
    "role": "admin"
  },
  "token": "jwt_token"
}
```

### Login
**POST** `/auth/login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user_id": "uuid",
    "email": "user@example.com",
    "organization_id": "uuid",
    "role": "admin"
  },
  "token": "jwt_token",
  "refresh_token": "refresh_token"
}
```

### Refresh Token
**POST** `/auth/refresh`

**Request Body:**
```json
{
  "refresh_token": "refresh_token"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "token": "new_jwt_token",
  "refresh_token": "new_refresh_token"
}
```

---

## 2. Threat Endpoints

### Get All Threats
**GET** `/threats?page=1&limit=20&severity=high&status=new`

**Query Parameters:**
- `page` (int, default: 1): Pagination page
- `limit` (int, default: 20): Items per page
- `severity` (string): Filter by severity (critical, high, medium, low, info)
- `status` (string): Filter by status (new, acknowledged, investigated, mitigated, resolved)
- `threat_type` (string): Filter by threat type
- `search` (string): Search in title and description

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "threats": [
      {
        "id": "uuid",
        "title": "Critical RCE in Apache Log4j",
        "threat_type": "vulnerability",
        "severity_level": "critical",
        "risk_score": 9.8,
        "status": "new",
        "cve_ids": ["CVE-2021-44228"],
        "affected_systems": ["Linux", "Windows"],
        "source": "NVD",
        "created_at": "2024-01-10T10:30:00Z",
        "is_read": false,
        "is_favorite": false
      }
    ],
    "total": 150,
    "page": 1,
    "limit": 20,
    "pages": 8
  }
}
```

### Get Threat Detail
**GET** `/threats/{threat_id}`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "Critical RCE in Apache Log4j",
    "description": "Detailed threat description...",
    "threat_type": "vulnerability",
    "severity_level": "critical",
    "risk_score": 9.8,
    "status": "new",
    "confidence_score": 0.98,
    "impact_rating": 0.95,
    "cve_ids": ["CVE-2021-44228"],
    "affected_systems": ["Linux", "Windows"],
    "affected_services": ["Apache", "Tomcat"],
    "threat_actors": ["APT28"],
    "ttps": ["T1190: Exploit Public-Facing Application"],
    "indicators_of_compromise": ["192.168.1.1", "malware.exe"],
    "source": "NVD",
    "source_url": "https://nvd.nist.gov/...",
    "location_country": "US",
    "location_city": "Unknown",
    "first_seen": "2024-01-01T00:00:00Z",
    "last_seen": "2024-01-10T10:30:00Z",
    "tags": ["critical", "rce"],
    "created_at": "2024-01-10T10:30:00Z",
    "updated_at": "2024-01-10T10:30:00Z",
    "analysis_count": 3
  }
}
```

### Create Threat
**POST** `/threats`

**Request Body:**
```json
{
  "title": "New Security Threat",
  "description": "Threat description...",
  "threat_type": "malware",
  "severity_level": "high",
  "cve_ids": ["CVE-2024-00001"],
  "affected_systems": ["Linux"],
  "source": "Custom Feed",
  "tags": ["malware", "ransomware"]
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "New Security Threat",
    "created_at": "2024-01-10T10:30:00Z"
  }
}
```

### Mark Threat as Read
**PUT** `/threats/{threat_id}/mark-read`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Threat marked as read"
}
```

---

## 3. Threat Analysis Endpoints

### Analyze Threat with DeepSeek
**POST** `/threats/{threat_id}/analyze`

**Request Body:**
```json
{
  "analysis_type": "full",
  "include_recommendations": true,
  "include_attack_vectors": true
}
```

**Response (202 Accepted):**
```json
{
  "success": true,
  "data": {
    "analysis_id": "uuid",
    "threat_id": "uuid",
    "status": "processing",
    "estimated_completion_seconds": 15
  }
}
```

### Get Analysis Result
**GET** `/threats/{threat_id}/analyses/{analysis_id}`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "threat_id": "uuid",
    "status": "completed",
    "analysis_type": "full",
    "deepseek_analysis": "Detailed AI analysis...",
    "risk_assessment": {
      "overall_risk": "critical",
      "exploitability": 0.9,
      "impact": 0.95,
      "affected_users": 10000
    },
    "attack_vectors": [
      "Network-based exploit",
      "Social engineering"
    ],
    "potential_impact": "Complete system compromise...",
    "remediation_steps": [
      "Apply security patch",
      "Update firewall rules"
    ],
    "preventive_measures": [
      "Enable auto-updates",
      "Deploy IDS/IPS"
    ],
    "confidence_level": 0.98,
    "ai_model_used": "deepseek-chat",
    "tokens_used": {
      "input": 1500,
      "output": 2000
    },
    "analysis_duration_ms": 3500,
    "created_at": "2024-01-10T10:30:00Z"
  }
}
```

### Get Risk Assessment
**GET** `/threats/{threat_id}/risk-assessment`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "threat_id": "uuid",
    "overall_risk_score": 9.2,
    "risk_level": "critical",
    "exploitability_score": 0.9,
    "impact_score": 0.95,
    "affected_users": 10000,
    "financial_impact_estimate": 5000000,
    "business_impact": "Service disruption, data breach, reputation damage",
    "timeline": "Immediate action required",
    "created_at": "2024-01-10T10:30:00Z"
  }
}
```

### Get Remediation Guide
**GET** `/threats/{threat_id}/remediation`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "threat_id": "uuid",
    "remediation_steps": [
      {
        "step": 1,
        "title": "Apply Security Patch",
        "description": "Download and install patch from vendor...",
        "priority": "critical",
        "estimated_time_minutes": 30,
        "rollback_plan": "Previous version can be restored..."
      },
      {
        "step": 2,
        "title": "Update Firewall Rules",
        "description": "Block traffic from affected ports...",
        "priority": "high",
        "estimated_time_minutes": 15
      }
    ],
    "preventive_measures": [
      "Enable automatic security updates",
      "Deploy IDS/IPS systems",
      "Implement network segmentation"
    ],
    "success_criteria": [
      "All systems patched",
      "No further exploitation attempts detected",
      "Firewall rules verified"
    ]
  }
}
```

---

## 4. Search & Filter Endpoints

### Search Threats
**GET** `/threats/search?q=ransomware&limit=20`

**Query Parameters:**
- `q` (string, required): Search query
- `limit` (int, default: 20): Max results
- `severity` (string): Filter by severity

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "query": "ransomware",
    "results": [
      {
        "id": "uuid",
        "title": "LockBit Ransomware Campaign",
        "threat_type": "ransomware",
        "severity_level": "critical",
        "relevance_score": 0.98
      }
    ],
    "total_results": 5
  }
}
```

### Get Trending Threats
**GET** `/threats/trending?days=7&limit=10`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "period_days": 7,
    "trending_threats": [
      {
        "id": "uuid",
        "title": "Critical Vulnerability",
        "threat_type": "vulnerability",
        "mentions_count": 1250,
        "affected_organizations": 450
      }
    ]
  }
}
```

---

## 5. User Profile Endpoints

### Get Current User Profile
**GET** `/users/profile`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "full_name": "John Doe",
    "avatar_url": "https://...",
    "organization_id": "uuid",
    "organization_name": "ACME Corp",
    "role": "admin",
    "status": "active",
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

### Update User Profile
**PUT** `/users/profile`

**Request Body:**
```json
{
  "full_name": "Jane Doe",
  "phone_number": "+1-555-0123",
  "avatar_url": "https://..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "full_name": "Jane Doe",
    "updated_at": "2024-01-10T10:30:00Z"
  }
}
```

### Get User Preferences
**GET** `/users/preferences`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "theme": "dark",
    "language": "en",
    "notification_email": true,
    "notification_push": true,
    "threat_severity_filter": "medium",
    "refresh_rate_minutes": 5,
    "timezone": "UTC"
  }
}
```

### Update User Preferences
**PUT** `/users/preferences`

**Request Body:**
```json
{
  "theme": "light",
  "notification_email": false,
  "refresh_rate_minutes": 10
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Preferences updated"
}
```

---

## 6. Notifications Endpoints

### Get Notifications
**GET** `/notifications?limit=20&unread_only=false`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": "uuid",
        "type": "threat_alert",
        "title": "Critical Threat Detected",
        "message": "A new critical threat has been detected...",
        "threat_id": "uuid",
        "is_read": false,
        "created_at": "2024-01-10T10:30:00Z"
      }
    ],
    "unread_count": 5
  }
}
```

### Mark Notification as Read
**PUT** `/notifications/{notification_id}/mark-read`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Notification marked as read"
}
```

---

## 7. Organization Endpoints

### Get Organization Info
**GET** `/organizations/info`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "ACME Corp",
    "industry": "Technology",
    "size": "enterprise",
    "subscription_tier": "pro",
    "subscription_expires_at": "2025-01-10T00:00:00Z",
    "threat_count": 1250,
    "member_count": 50
  }
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "error": "validation_error",
  "message": "Invalid request parameters",
  "details": {
    "field": "severity_level",
    "message": "Invalid severity level"
  }
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "error": "unauthorized",
  "message": "Authentication token is missing or invalid"
}
```

### 403 Forbidden
```json
{
  "success": false,
  "error": "forbidden",
  "message": "You do not have permission to access this resource"
}
```

### 404 Not Found
```json
{
  "success": false,
  "error": "not_found",
  "message": "Resource not found"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "error": "internal_error",
  "message": "An internal server error occurred",
  "request_id": "uuid"
}
```

---

## Rate Limiting

- Rate limit: 1000 requests per hour per API key
- Rate limit headers:
  - `X-RateLimit-Limit`: 1000
  - `X-RateLimit-Remaining`: 999
  - `X-RateLimit-Reset`: timestamp

---

## Pagination

All list endpoints support pagination with:
- `page` (default: 1)
- `limit` (default: 20, max: 100)

Response includes:
- `total`: Total number of items
- `page`: Current page
- `limit`: Items per page
- `pages`: Total number of pages
