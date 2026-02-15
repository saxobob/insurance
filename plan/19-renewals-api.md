# Step 19 — Renewals Workflow API

## Goal
Build renewal detection, renewal quote generation, customer notification, acceptance tracking, and renewal pipeline management.

## Prerequisites
- Steps 01–18 completed

---

## Prompt

You are building the renewals workflow API for a UK insurance broker policy admin SaaS. Renewals identify expiring policies, re-rate them via the binder, send renewal notices to customers, and track acceptance/decline.

### Schema context:
- `renewals`: id, policy_id, renewal_date, quote_generated_at, quote_sent_at, quoted_premium, status, accepted_at, declined_reason, created_at
- Renewal statuses: `pending`, `quote_generated`, `quote_sent`, `accepted`, `declined`, `lapsed`

### Files to create:

```
packages/api/src/
├── services/
│   └── renewal.service.ts        # Renewal business logic
├── routes/
│   └── renewals.ts               # Renewal routes
├── jobs/
│   └── renewal.job.ts            # Scheduled renewal processing
```

### Requirements:

1. **Renewal service** (`services/renewal.service.ts`):
   - `identifyRenewals(brokerId, daysAhead)`: Find policies expiring within `daysAhead` days that don't already have a renewal record:
     1. Query policies with status in ('in_force', 'endorsed') and expiry_date within range
     2. Exclude policies that already have a renewal record for this expiry
     3. Create renewal records with status='pending'
     4. Return list of newly identified renewals

   - `generateRenewalQuote(brokerId, renewalId)`: Generate renewal quote:
     1. Load the original policy, latest version, financials
     2. If binder supports API rating: call with same risk items for new period
     3. Calculate new premium, commission, IPT
     4. Set quoted_premium and quote_generated_at
     5. Update status to 'quote_generated'
     6. Optionally create a new policy in 'draft' status for the renewal (new policy period)

   - `sendRenewalNotice(brokerId, renewalId)`: Send renewal notice to customer:
     1. Generate renewal notice document (PDF)
     2. Send email with renewal details and quoted premium
     3. Set quote_sent_at
     4. Update status to 'quote_sent'
     5. Add customer timeline entry

   - `acceptRenewal(brokerId, renewalId, userId)`: Customer accepts renewal:
     1. Create new policy for renewal period (or activate the draft)
     2. Create policy_version with transaction_type='renewal'
     3. Create policy_financials
     4. Set accepted_at, update status to 'accepted'
     5. Issue the renewal policy (generate docs, invoice)
     6. Add timeline entry

   - `declineRenewal(brokerId, renewalId, reason)`: Customer declines:
     1. Set declined_reason, update status to 'declined'
     2. Original policy will expire naturally
     3. Log decline with reason

   - `getRenewal(brokerId, renewalId)`: Get renewal with original policy, quoted premium, status
   - `listRenewals(brokerId, filters, pagination)`: List with filters:
     - `status`, `dateFrom/dateTo` (renewal date), `productId`, `binderId`
   - `getRenewalPipeline(brokerId)`: Dashboard view:
     - Renewals due in 7 days, 14 days, 30 days, 60 days, 90 days
     - Counts by status
     - Total quoted premium
   - `batchGenerateQuotes(brokerId, renewalIds)`: Generate quotes for multiple renewals
   - `batchSendNotices(brokerId, renewalIds)`: Send notices for multiple renewals

2. **Scheduled job** (`jobs/renewal.job.ts`):
   - Daily job to identify policies expiring in next 90 days (configurable)
   - Auto-generate renewal quotes for policies expiring in next 60 days
   - Auto-send renewal notices for policies expiring in next 30 days (if not already sent)
   - Flag renewals past expiry date without acceptance as 'lapsed'

3. **Renewal routes** (`routes/renewals.ts`):
   - `GET /api/renewals` — list renewals (requires `policies:read`)
   - `GET /api/renewals/pipeline` — renewal pipeline dashboard (requires `policies:read`)
   - `GET /api/renewals/:id` — get renewal detail (requires `policies:read`)
   - `POST /api/renewals/identify` — manually trigger renewal identification (requires `policies:update`)
     Body: `{ daysAhead: number }`
   - `POST /api/renewals/:id/generate-quote` — generate renewal quote (requires `quotes:create`)
   - `POST /api/renewals/:id/send-notice` — send renewal notice (requires `policies:update`)
   - `POST /api/renewals/:id/accept` — accept renewal (requires `policies:bind`)
   - `POST /api/renewals/:id/decline` — decline renewal (requires `policies:update`)
     Body: `{ reason }`
   - `POST /api/renewals/batch/generate` — batch generate quotes (requires `quotes:create`)
     Body: `{ renewalIds: string[] }`
   - `POST /api/renewals/batch/send` — batch send notices (requires `policies:update`)
     Body: `{ renewalIds: string[] }`

### Acceptance criteria:
- Renewal identification finds expiring policies without duplicating
- Renewal quote re-rates via binder API with new period dates
- Renewal notice generates document and sends email
- Accepting a renewal creates a new policy with correct version chain
- Declining a renewal records the reason
- Pipeline view shows renewals grouped by time horizon
- Scheduled jobs run reliably and are idempotent
- Lapsed renewals are flagged after expiry
