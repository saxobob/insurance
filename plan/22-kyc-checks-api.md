# Step 22 — KYC Checks API

## Goal
Build KYC (Know Your Customer) record management, provider integration stubs, and evidence storage.

## Prerequisites
- Steps 01–21 completed

---

## Prompt

You are building the KYC checks API for a UK insurance broker policy admin SaaS. Brokers need to record identity verification checks for customers as part of AML/KYC compliance.

### Schema context:
- `kyc_checks`: id, customer_id, check_date, check_type, provider, outcome, evidence_stored, notes, created_by, created_at

### Files to create:

```
packages/api/src/
├── services/
│   └── kyc.service.ts            # KYC business logic
├── routes/
│   └── kyc.ts                    # KYC routes
```

### Requirements:

1. **KYC service** (`services/kyc.service.ts`):
   - `createCheck(brokerId, customerId, userId, data)`: Record a KYC check:
     1. Validate customer exists
     2. Create kyc_checks record
     3. If evidence documents provided, upload and link
     4. Add customer timeline entry
     Input: `{ checkType, provider?, outcome, notes? }`
   - Check types: `identity_verification`, `address_verification`, `sanctions_screening`, `pep_check`, `company_verification`
   - Outcomes: `pass`, `fail`, `refer`, `pending`
   - `getChecksForCustomer(brokerId, customerId)`: List all KYC checks for a customer
   - `getCheck(brokerId, checkId)`: Get check detail with evidence documents
   - `getKycStatus(brokerId, customerId)`: Summary status: has the customer passed all required checks? Returns `{ verified: boolean, checks: [...], lastCheckDate, missingChecks[] }`
   - `listCustomersRequiringKyc(brokerId)`: Customers with policies but no KYC checks, or with expired checks (older than configurable period, default 3 years)

2. **KYC routes** (`routes/kyc.ts`):
   - `GET /api/customers/:customerId/kyc` — list checks for customer (requires `customers:read`)
   - `GET /api/customers/:customerId/kyc/status` — KYC status summary (requires `customers:read`)
   - `POST /api/customers/:customerId/kyc` — record check (requires `customers:update`)
   - `GET /api/kyc/:id` — get check detail (requires `customers:read`)
   - `POST /api/kyc/:id/evidence` — upload evidence document (requires `documents:upload`)
   - `GET /api/kyc/outstanding` — customers needing KYC (requires `customers:read`)

### Acceptance criteria:
- KYC checks are linked to customers and recorded with outcomes
- Evidence documents can be attached to checks
- KYC status summary shows whether customer is verified
- Outstanding KYC list identifies customers needing checks
- All KYC actions logged to audit trail
