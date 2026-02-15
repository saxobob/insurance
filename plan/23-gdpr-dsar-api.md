# Step 23 — GDPR & DSAR Support API

## Goal
Build GDPR data subject access request handling, data export, redaction, and secure deletion workflows.

## Prerequisites
- Steps 01–22 completed

---

## Prompt

You are building GDPR compliance tools for a UK insurance broker policy admin SaaS. Each broker is a separate data controller. The system must support DSARs (Data Subject Access Requests), data export, redaction, and secure deletion with audit trails.

### Files to create:

```
packages/api/src/
├── services/
│   └── gdpr.service.ts           # GDPR operations
├── routes/
│   └── gdpr.ts                   # GDPR routes
├── db/schema/
│   └── gdpr.ts                   # DSAR tracking table (new migration)
```

### Requirements:

1. **New table** — `dsar_requests`:
   - id, broker_id, customer_id, request_type (access/rectification/erasure/portability), status (received/in_progress/completed/rejected), received_at, due_by (30 days from receipt), completed_at, response_notes, handled_by, created_at

2. **GDPR service** (`services/gdpr.service.ts`):
   - `createDsarRequest(brokerId, data)`: Log a DSAR:
     1. Set due_by = received_at + 30 calendar days
     2. Create record with status='received'
     Input: `{ customerId, requestType, receivedAt?, notes? }`

   - `processDsar(brokerId, dsarId, userId)`: Begin processing:
     1. Update status to 'in_progress'
     2. Set handled_by

   - `completeDsar(brokerId, dsarId, userId, responseNotes)`: Complete the request:
     1. Update status to 'completed', set completed_at
     2. Log completion in audit trail

   - `exportCustomerData(brokerId, customerId)`: Full data export (reuse from customer service):
     - Customer record
     - All policies and versions
     - All financial records
     - All documents metadata (with download links)
     - All emails
     - All claims and complaints
     - All KYC checks
     - All timeline entries
     - All audit log entries for this customer
     - Export as structured JSON and optionally CSV

   - `redactCustomerData(brokerId, customerId, userId, reason)`: Redact PII while preserving records:
     1. Replace name with "REDACTED"
     2. Clear email, phone, address_json
     3. Retain: policy numbers, financial data, dates (needed for regulatory retention)
     4. Log redaction in audit trail with reason
     5. Cannot redact if policies are still in_force

   - `deleteCustomerData(brokerId, customerId, userId, reason)`: Full erasure:
     1. Only allowed if all policies expired/cancelled for > retention period
     2. Delete customer record and all related personal data
     3. Preserve anonymised financial/policy records for regulatory compliance
     4. Log deletion in audit trail (the log entry itself is retained)

   - `listDsarRequests(brokerId, filters)`: List with filters: status, requestType, overdue (due_by < today AND status != completed)
   - `getDsarOverdue(brokerId)`: DSARs past their 30-day deadline

3. **GDPR routes** (`routes/gdpr.ts`):
   - `GET /api/gdpr/dsar` — list DSAR requests (requires `gdpr:manage`)
   - `GET /api/gdpr/dsar/overdue` — overdue DSARs (requires `gdpr:manage`)
   - `POST /api/gdpr/dsar` — log new DSAR (requires `gdpr:manage`)
   - `PUT /api/gdpr/dsar/:id/process` — begin processing (requires `gdpr:manage`)
   - `PUT /api/gdpr/dsar/:id/complete` — complete DSAR (requires `gdpr:manage`)
   - `GET /api/gdpr/customers/:customerId/export` — export customer data (requires `gdpr:manage`)
   - `POST /api/gdpr/customers/:customerId/redact` — redact PII (requires `gdpr:manage`)
     Body: `{ reason }`
   - `DELETE /api/gdpr/customers/:customerId` — delete customer data (requires `gdpr:manage`)
     Body: `{ reason }`

### Acceptance criteria:
- DSAR tracking includes 30-day deadline with overdue alerts
- Data export includes all customer-related data across all tables
- Redaction replaces PII but preserves structural records
- Deletion only allowed when retention period has passed
- All GDPR actions are logged in audit trail (including the deletion itself)
- Cannot redact/delete customers with active policies
- Export format is machine-readable (JSON/CSV)
