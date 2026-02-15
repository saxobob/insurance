# Step 06 — Customer Management API

## Goal
Build full customer CRUD with search, duplicate detection, customer timeline, and GDPR lawful basis tracking.

## Prerequisites
- Steps 01–05 completed

---

## Prompt

You are building the customer management API for a UK insurance broker policy admin SaaS. Auth, RBAC, and tenant-scoped DB are in place. Build customer endpoints.

### Schema context:
- `customers`: id, broker_id, customer_type (retail/commercial), full_name, company_name, company_number, email, phone, address_json (JSONB), gdpr_lawful_basis, marketing_consent, created_at
- CHECK: commercial customers must have company_name
- `customer_timeline`: id, customer_id, event_type, event_date, description, related_entity_type, related_entity_id, created_by, created_at

### Files to create:

```
packages/api/src/
├── services/
│   ├── customer.service.ts       # Customer business logic
│   └── customer-timeline.service.ts # Timeline operations
├── routes/
│   ├── customers.ts              # Customer CRUD routes
│   └── customer-timeline.ts      # Timeline routes
```

### Requirements:

1. **Customer service** (`services/customer.service.ts`):
   - `createCustomer(brokerId, data)`: Validate input with Zod schema from shared package. For commercial customers, enforce company_name is present. Generate timeline entry "Customer created". Return created customer.
   - `updateCustomer(brokerId, customerId, data)`: Update allowed fields. Log changes to audit_log. Add timeline entry "Customer updated: [changed fields]".
   - `getCustomer(brokerId, customerId)`: Fetch customer with recent timeline entries (last 10).
   - `listCustomers(brokerId, filters, pagination)`: Paginated list with filters:
     - `search` (text) — search across full_name, company_name, email, phone
     - `customerType` — filter by retail/commercial
     - `sortBy` — full_name, created_at (default: created_at DESC)
   - `deleteCustomer(brokerId, customerId)`: Soft-delete only if customer has no policies. Otherwise return error "Cannot delete customer with existing policies".
   - `detectDuplicates(brokerId, fullName, email?, companyNumber?)`: Return potential duplicate customers based on fuzzy name match (trigram similarity if pg_trgm available, otherwise ILIKE) and exact email/company_number match.
   - `exportCustomerData(brokerId, customerId)`: Export all customer data as structured JSON (for GDPR DSAR). Include: customer record, all policies, all documents, all emails, all timeline entries, all claims, all complaints.

2. **Timeline service** (`services/customer-timeline.service.ts`):
   - `addTimelineEntry(customerId, eventType, description, relatedEntityType?, relatedEntityId?, createdBy?)`: Insert timeline entry.
   - `getTimeline(customerId, pagination)`: Return paginated timeline entries, newest first.
   - Event types: `customer_created`, `customer_updated`, `policy_created`, `policy_issued`, `policy_cancelled`, `claim_created`, `complaint_created`, `document_uploaded`, `email_sent`, `payment_received`, `note_added`

3. **Customer routes** (`routes/customers.ts`):
   - `GET /api/customers` — list with filters/search/pagination (requires `customers:read`)
   - `GET /api/customers/:id` — get customer detail with recent timeline (requires `customers:read`)
   - `POST /api/customers` — create customer (requires `customers:create`). Run duplicate detection and return warnings (don't block creation, just warn).
   - `PUT /api/customers/:id` — update customer (requires `customers:update`)
   - `DELETE /api/customers/:id` — delete customer (requires `customers:delete`)
   - `GET /api/customers/:id/timeline` — paginated timeline (requires `customers:read`)
   - `POST /api/customers/:id/timeline` — add manual note to timeline (requires `customers:update`)
   - `GET /api/customers/:id/export` — GDPR data export (requires `gdpr:manage`)
   - `GET /api/customers/:id/duplicates` — check for duplicates (requires `customers:read`)

4. **Address JSON structure** (document in types):
   ```typescript
   interface Address {
     line1: string;
     line2?: string;
     city: string;
     county?: string;
     postcode: string;
     country: string; // default 'GB'
   }
   ```

5. **Validation** (add to shared package):
   - Validate UK postcode format (regex)
   - Validate email format
   - Validate UK phone number format
   - company_number: 8 digits for Companies House

6. **Audit logging**: Every create/update/delete logs to audit_log via the audit plugin from Step 03.

### Acceptance criteria:
- Creating a retail customer without company_name succeeds
- Creating a commercial customer without company_name returns 400
- Search finds customers by partial name, email, or phone
- Duplicate detection flags customers with same email or similar name
- Timeline shows chronological activity for a customer
- Customer with policies cannot be deleted
- GDPR export returns complete customer data as JSON
- All mutations logged to audit_log
