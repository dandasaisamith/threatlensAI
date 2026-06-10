# ThreatLens AI - Supabase Database Schema

## Database Overview

The Supabase database consists of the following tables designed for threat intelligence, user management, analysis, and audit tracking.

---

## Tables

### 1. `users`
Main user table for authentication and profile management.

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    avatar_url TEXT,
    phone_number VARCHAR(20),
    organization_id UUID REFERENCES organizations(id),
    role VARCHAR(50) DEFAULT 'viewer' CHECK (role IN ('admin', 'analyst', 'viewer')),
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    preferences JSONB DEFAULT '{}'::jsonb,
    two_factor_enabled BOOLEAN DEFAULT false,
    two_factor_secret VARCHAR(255)
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_organization_id ON users(organization_id);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_role ON users(role);
```

**Columns**:
- `id`: UUID primary key
- `email`: Unique email for login
- `full_name`: User's full name
- `avatar_url`: Profile picture URL
- `phone_number`: Contact number
- `organization_id`: References the organization
- `role`: User role (admin/analyst/viewer)
- `status`: Account status
- `created_at`: Account creation timestamp
- `updated_at`: Last update timestamp
- `last_login_at`: Last login timestamp
- `preferences`: JSONB for user preferences
- `two_factor_enabled`: 2FA status
- `two_factor_secret`: 2FA secret

---

### 2. `organizations`
Organizations table for multi-tenancy support.

```sql
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    logo_url TEXT,
    website VARCHAR(255),
    industry VARCHAR(100),
    size VARCHAR(50) CHECK (size IN ('startup', 'small', 'medium', 'enterprise')),
    country VARCHAR(100),
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    subscription_tier VARCHAR(50) DEFAULT 'free' CHECK (subscription_tier IN ('free', 'basic', 'pro', 'enterprise')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subscription_expires_at TIMESTAMP,
    settings JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_organizations_name ON organizations(name);
CREATE INDEX idx_organizations_status ON organizations(status);
CREATE INDEX idx_organizations_subscription_tier ON organizations(subscription_tier);
```

---

### 3. `threats`
Core table for storing threat intelligence data.

```sql
CREATE TABLE threats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    threat_type VARCHAR(100) NOT NULL,
    severity_level VARCHAR(50) NOT NULL CHECK (severity_level IN ('critical', 'high', 'medium', 'low', 'info')),
    source VARCHAR(255),
    source_url TEXT,
    cve_ids TEXT[] DEFAULT '{}'::text[],
    affected_systems TEXT[],
    affected_services TEXT[],
    threat_actors TEXT[],
    indicators_of_compromise TEXT[],
    ttps TEXT[] DEFAULT '{}'::text[],
    first_seen TIMESTAMP,
    last_seen TIMESTAMP,
    status VARCHAR(50) DEFAULT 'new' CHECK (status IN ('new', 'acknowledged', 'investigated', 'mitigated', 'resolved')),
    confidence_score NUMERIC(3, 2) CHECK (confidence_score >= 0 AND confidence_score <= 1.0),
    impact_rating NUMERIC(3, 2),
    risk_score NUMERIC(5, 2),
    location_country VARCHAR(100),
    location_city VARCHAR(100),
    threat_data JSONB DEFAULT '{}'::jsonb,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_threats_organization_id ON threats(organization_id);
CREATE INDEX idx_threats_severity_level ON threats(severity_level);
CREATE INDEX idx_threats_status ON threats(status);
CREATE INDEX idx_threats_threat_type ON threats(threat_type);
CREATE INDEX idx_threats_created_at ON threats(created_at DESC);
CREATE INDEX idx_threats_risk_score ON threats(risk_score DESC);
CREATE INDEX idx_threats_cve_ids ON threats USING GIN(cve_ids);
```

---

### 4. `threat_analyses`
Stores threat analysis results and AI-generated insights.

```sql
CREATE TABLE threat_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    threat_id UUID NOT NULL REFERENCES threats(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    analysis_type VARCHAR(100) NOT NULL,
    deepseek_analysis TEXT,
    risk_assessment JSONB,
    attack_vectors TEXT[],
    potential_impact TEXT,
    remediation_steps TEXT[],
    preventive_measures TEXT[],
    confidence_level NUMERIC(3, 2),
    ai_model_used VARCHAR(100),
    analysis_duration_ms INTEGER,
    tokens_used JSONB DEFAULT '{"input": 0, "output": 0}'::jsonb,
    status VARCHAR(50) DEFAULT 'completed' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    error_message TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_threat_analyses_threat_id ON threat_analyses(threat_id);
CREATE INDEX idx_threat_analyses_organization_id ON threat_analyses(organization_id);
CREATE INDEX idx_threat_analyses_status ON threat_analyses(status);
CREATE INDEX idx_threat_analyses_created_at ON threat_analyses(created_at DESC);
```

---

### 5. `threat_intelligence_feeds`
Manages external threat intelligence feeds integration.

```sql
CREATE TABLE threat_intelligence_feeds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    feed_type VARCHAR(100) NOT NULL CHECK (feed_type IN ('cve', 'malware', 'phishing', 'botnet', 'ransomware', 'custom')),
    source_url TEXT NOT NULL,
    api_key VARCHAR(500),
    refresh_interval_minutes INTEGER DEFAULT 60,
    last_synced_at TIMESTAMP,
    threat_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_feeds_organization_id ON threat_intelligence_feeds(organization_id);
CREATE INDEX idx_feeds_feed_type ON threat_intelligence_feeds(feed_type);
CREATE INDEX idx_feeds_is_active ON threat_intelligence_feeds(is_active);
```

---

### 6. `user_threat_interactions`
Tracks user interactions with threats (read, favorite, acknowledge).

```sql
CREATE TABLE user_threat_interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    threat_id UUID NOT NULL REFERENCES threats(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    is_read BOOLEAN DEFAULT false,
    is_favorite BOOLEAN DEFAULT false,
    is_acknowledged BOOLEAN DEFAULT false,
    acknowledgment_note TEXT,
    interaction_type VARCHAR(50) CHECK (interaction_type IN ('view', 'favorite', 'acknowledge', 'share', 'analyze')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, threat_id)
);

CREATE INDEX idx_interactions_user_id ON user_threat_interactions(user_id);
CREATE INDEX idx_interactions_threat_id ON user_threat_interactions(threat_id);
CREATE INDEX idx_interactions_organization_id ON user_threat_interactions(organization_id);
```

---

### 7. `user_preferences`
User notification and display preferences.

```sql
CREATE TABLE user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    theme VARCHAR(50) DEFAULT 'system' CHECK (theme IN ('light', 'dark', 'system')),
    language VARCHAR(10) DEFAULT 'en',
    notification_email BOOLEAN DEFAULT true,
    notification_push BOOLEAN DEFAULT true,
    notification_sms BOOLEAN DEFAULT false,
    threat_severity_filter VARCHAR(50) DEFAULT 'medium',
    refresh_rate_minutes INTEGER DEFAULT 5,
    items_per_page INTEGER DEFAULT 20,
    timezone VARCHAR(100) DEFAULT 'UTC',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_preferences_user_id ON user_preferences(user_id);
```

---

### 8. `audit_logs`
Tracks all user actions and system events for audit trail.

```sql
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(255) NOT NULL,
    resource_type VARCHAR(100) NOT NULL,
    resource_id VARCHAR(255),
    status VARCHAR(50) CHECK (status IN ('success', 'failure')),
    details JSONB DEFAULT '{}'::jsonb,
    ip_address VARCHAR(50),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_logs_organization_id ON audit_logs(organization_id);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);
CREATE INDEX idx_audit_logs_resource_type ON audit_logs(resource_type);
```

---

### 9. `threat_tags`
Tags for categorizing threats.

```sql
CREATE TABLE threat_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    color VARCHAR(7) DEFAULT '#808080',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(organization_id, name)
);

CREATE INDEX idx_threat_tags_organization_id ON threat_tags(organization_id);
```

---

### 10. `threat_tag_mappings`
Junction table for many-to-many relationship between threats and tags.

```sql
CREATE TABLE threat_tag_mappings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    threat_id UUID NOT NULL REFERENCES threats(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES threat_tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(threat_id, tag_id)
);

CREATE INDEX idx_tag_mappings_threat_id ON threat_tag_mappings(threat_id);
CREATE INDEX idx_tag_mappings_tag_id ON threat_tag_mappings(tag_id);
```

---

### 11. `api_keys`
API keys for external integrations and programmatic access.

```sql
CREATE TABLE api_keys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    key_hash VARCHAR(255) NOT NULL UNIQUE,
    permissions TEXT[] DEFAULT '{}'::text[],
    rate_limit_requests INTEGER DEFAULT 1000,
    rate_limit_period_seconds INTEGER DEFAULT 3600,
    is_active BOOLEAN DEFAULT true,
    last_used_at TIMESTAMP,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_api_keys_organization_id ON api_keys(organization_id);
CREATE INDEX idx_api_keys_user_id ON api_keys(user_id);
CREATE INDEX idx_api_keys_is_active ON api_keys(is_active);
```

---

### 12. `deepseek_analysis_cache`
Cache for DeepSeek analysis results to avoid redundant API calls.

```sql
CREATE TABLE deepseek_analysis_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    threat_id UUID NOT NULL REFERENCES threats(id) ON DELETE CASCADE,
    query_hash VARCHAR(255) NOT NULL UNIQUE,
    analysis_result JSONB NOT NULL,
    tokens_used JSONB DEFAULT '{"input": 0, "output": 0}'::jsonb,
    cost_estimate NUMERIC(10, 6),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    hit_count INTEGER DEFAULT 0
);

CREATE INDEX idx_cache_threat_id ON deepseek_analysis_cache(threat_id);
CREATE INDEX idx_cache_expires_at ON deepseek_analysis_cache(expires_at);
CREATE INDEX idx_cache_hit_count ON deepseek_analysis_cache(hit_count DESC);
```

---

### 13. `notifications`
Push and email notifications history.

```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    threat_id UUID REFERENCES threats(id) ON DELETE CASCADE,
    type VARCHAR(100) NOT NULL CHECK (type IN ('threat_alert', 'analysis_complete', 'preference_update', 'system', 'custom')),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    data JSONB DEFAULT '{}'::jsonb,
    is_read BOOLEAN DEFAULT false,
    is_sent BOOLEAN DEFAULT false,
    delivery_channel VARCHAR(50) CHECK (delivery_channel IN ('email', 'push', 'in_app', 'sms')),
    sent_at TIMESTAMP,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
```

---

## Row Level Security (RLS) Policies

### Organizations
```sql
-- Users can only see organizations they belong to
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;

CREATE POLICY org_isolation ON organizations FOR SELECT
    USING (id IN (SELECT organization_id FROM users WHERE id = auth.uid()));

CREATE POLICY org_update ON organizations FOR UPDATE
    USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND organization_id = organizations.id AND role = 'admin'));
```

### Threats
```sql
ALTER TABLE threats ENABLE ROW LEVEL SECURITY;

CREATE POLICY threats_isolation ON threats FOR SELECT
    USING (organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid()));

CREATE POLICY threats_insert ON threats FOR INSERT
    WITH CHECK (organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid()));
```

### Audit Logs
```sql
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY audit_logs_isolation ON audit_logs FOR SELECT
    USING (organization_id IN (SELECT organization_id FROM users WHERE id = auth.uid() AND role = 'admin'));
```

---

## Views

### `threat_summary_view`
```sql
CREATE VIEW threat_summary_view AS
SELECT
    t.id,
    t.title,
    t.severity_level,
    t.threat_type,
    t.status,
    COUNT(DISTINCT uta.user_id) as interaction_count,
    COUNT(DISTINCT ta.id) as analysis_count,
    t.risk_score,
    t.created_at
FROM threats t
LEFT JOIN user_threat_interactions uta ON t.id = uta.threat_id
LEFT JOIN threat_analyses ta ON t.id = ta.threat_id
GROUP BY t.id;
```

---

## Triggers

### Update timestamp on record modification
```sql
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_timestamp BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_threats_timestamp BEFORE UPDATE ON threats
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_analyses_timestamp BEFORE UPDATE ON threat_analyses
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();
```

---

## Performance Considerations

1. **Indexes**: Composite indexes on commonly filtered fields
2. **Partitioning**: Consider partitioning threats by month after 1M+ records
3. **Caching**: DeepSeek analysis cache to reduce API costs
4. **Archival**: Archive threats older than 1 year to separate table
5. **Full-text Search**: Enable for title and description fields in threats table

---

## Backup and Disaster Recovery

- Daily automated backups retained for 30 days
- Weekly backup snapshots retained for 90 days
- Point-in-time recovery available within 7 days
