# Step 21 — Audit Log & Compliance API

## Goal
Enhance the audit logging middleware and build query/filter/export endpoints for the audit trail.

## Prerequisites
- Steps 01–20 completed (audit plugin exists from Step 03; this step adds full query API)

---

## Prompt

You are enhancing the audit log system for a UK insurance broker policy admin SaaS. The audit middleware from Step 03 automatically logs mutations. Now build the query API, retention management, and compliance export features.

### Schema context:
- `audit_log`: id, broker_id, user_id, entity_type, entity_id, action, reason, ip_address, created_at

### Files to create/modify:

```
packages/api/src/
├── services/
│   └── audit.service.ts          # Audit log query & management
├── routes/
│   └── audit.ts                  # Audit log routes
├── plugins/
│   └── audit.ts                  # MODIFY: enhance auto-logging
```

### Requirements:

1. **Enhanced audit plugin** — modify to capture more context:
   - Store `old_values` and `new_values` as JSONB (add columns via migration) — for diffing
   - Capture HTTP method, URL path, request body hash (not full body — avoid PII in logs)
   - Entity types: `customer`, `policy`, `policy_version`, `claim`, `complaint`, `invoice`, `receipt`, `binder`, `product`, `user`, `role`, `document`, `email_template`, `bordereau`, `renewal`, `tax_rate`
   - Actions: `create`, `update`, `delete`, `status_change`, `login`, `logout`, `login_failed`, `permission_denied`, `export`, `transmit`

2. **Audit service** (`services/audit.service.ts`):
   - `logAction(brokerId, userId, entry)`: Explicit logging (for cases not caught by middleware)
   - `queryAuditLog(brokerId, filters, pagination)`: Query with filters:
     - `entityType` — one or more entity types
     - `entityId` — specific entity
     - `userId` — actions by specific user
     - `action` — one or more actions
     - `dateFrom/dateTo`
     - `search` — text search in reason field
   - `getEntityHistory(brokerId, entityType, entityId)`: Complete audit trail for a specific entity (e.g., all changes to a specific policy)
   - `getUserActivity(brokerId, userId, dateFrom, dateTo)`: All actions by a specific user
   - `getSecurityEvents(brokerId, dateFrom, dateTo)`: Failed logins, permission denials, sensitive actions
   - `exportAuditLog(brokerId, filters, format)`: Export as CSV or JSON
   - `getAuditStats(brokerId)`: Summary: actions per day, most active users, most changed entities

3. **Retention management**:
   - `archiveOldEntries(brokerId, olderThan)`: Move entries older than retention period to archive table (or mark as archived)
   - Retention period: configurable per broker, default 7 years
   - Archived entries still queryable but stored separately

4. **Audit routes** (`routes/audit.ts`):
   - `GET /api/audit` — query audit log (requires `audit:read`)
   - `GET /api/audit/entity/:entityType/:entityId` — entity history (requires `audit:read`)
   - `GET /api/audit/user/:userId` — user activity (requires `audit:read`)
   - `GET /api/audit/security` — security events (requires `audit:read`)
   - `GET /api/audit/stats` — audit statistics (requires `audit:read`)
   - `GET /api/audit/export` — export audit log (requires `compliance:export`)
     Query: `?entityType=&dateFrom=&dateTo=&format=csv`

### Acceptance criteria:
- Every mutation in the system is captured in audit_log
- Audit entries include who, what, when, why, and from where (IP)
- Entity history shows complete change trail for any entity
- Security events (failed logins, permission denials) are queryable
- CSV export works for compliance reporting
- Audit log queries are performant (indexed by entity, date, user)
- 7-year retention is enforced with archival
