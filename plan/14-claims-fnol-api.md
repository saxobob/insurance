# Step 14 — Claims & FNOL API

## Goal
Build first notification of loss (FNOL) capture, claim status management, document attachments, and optional insurer push integration.

## Prerequisites
- Steps 01–13 completed

---

## Prompt

You are building the claims notification API for a UK insurance broker policy admin SaaS. This is NOT a full claims management system — it captures FNOL (first notification of loss) and tracks basic claim status. Full claims handling remains with the insurer.

### Schema context:
- `claims`: id, broker_id, policy_id, policy_version_id, date_of_loss, description, estimated_loss, police_reported, status (default 'notified'), handler_id, handler_notes, created_at

### Claim statuses:
`notified → acknowledged → in_progress → referred_to_insurer → settled → closed → withdrawn`

### Files to create:

```
packages/api/src/
├── services/
│   └── claim.service.ts          # Claims business logic
├── routes/
│   └── claims.ts                 # Claims routes
```

### Requirements:

1. **Claim service** (`services/claim.service.ts`):
   - `createClaim(brokerId, userId, data)`: Create FNOL:
     1. Validate policy exists and is in_force/endorsed (or recently cancelled — allow claims for incidents during cover period)
     2. Validate date_of_loss is within the policy cover period (inception to expiry)
     3. Generate unique claim reference: `CLM/{YEAR}/{SEQUENCE}`
     4. Create claim record with status='notified'
     5. Link to policy and current policy version
     6. Send acknowledgement email to customer (stub — use email service from Step 20)
     7. Add customer timeline entry
     8. Return created claim
     Input: `{ policyId, dateOfLoss, description, estimatedLoss?, policeReported, handlerId? }`

   - `updateClaim(brokerId, claimId, updates)`: Update claim details (description, estimated_loss, handler_notes, handler_id). Log changes.
   - `transitionClaimStatus(brokerId, claimId, newStatus, notes, userId)`: Status transition with validation:
     - notified → acknowledged
     - acknowledged → in_progress
     - in_progress → referred_to_insurer, settled, withdrawn
     - referred_to_insurer → settled, closed
     - settled → closed
     - Any status → withdrawn (with reason)
   - `getClaim(brokerId, claimId)`: Get claim with policy info, handler info, documents, status history (from audit_log)
   - `listClaims(brokerId, filters, pagination)`: List claims with filters:
     - `status` — one or more statuses
     - `policyId` — claims for specific policy
     - `customerId` — claims for specific customer (via policy)
     - `handlerId` — claims assigned to handler
     - `dateFrom/dateTo` — date of loss range
     - `search` — search claim reference or description
   - `assignHandler(brokerId, claimId, handlerId)`: Assign or reassign claim handler
   - `addClaimNote(brokerId, claimId, note, userId)`: Add handler note with timestamp
   - `getClaimStats(brokerId)`: Dashboard stats: claims by status, average time to acknowledge, total estimated losses
   - `pushToInsurer(brokerId, claimId)`: Integration stub — if binder has claims API endpoint, push FNOL data. Log success/failure.

2. **Claim routes** (`routes/claims.ts`):
   - `POST /api/claims` — create FNOL (requires `claims:create`)
   - `GET /api/claims` — list claims with filters (requires `claims:read`)
   - `GET /api/claims/stats` — claim statistics (requires `claims:read`)
   - `GET /api/claims/:id` — get claim detail (requires `claims:read`)
   - `PUT /api/claims/:id` — update claim details (requires `claims:update`)
   - `POST /api/claims/:id/transition` — change status (requires `claims:update`)
     Body: `{ newStatus, notes }`
   - `POST /api/claims/:id/assign` — assign handler (requires `claims:update`)
     Body: `{ handlerId }`
   - `POST /api/claims/:id/notes` — add handler note (requires `claims:update`)
     Body: `{ note }`
   - `POST /api/claims/:id/documents` — attach document to claim (requires `documents:upload`)
   - `GET /api/claims/:id/documents` — list claim documents (requires `claims:read`)
   - `POST /api/claims/:id/push-to-insurer` — push FNOL to insurer API (requires `claims:update`)

3. **Document attachment**: Claims can have documents attached (photos, police reports, estimates). Use the document service from Step 11. Link documents to the claim via customer_id and a related_entity reference.

### Acceptance criteria:
- FNOL creates a claim linked to the correct policy and version
- Date of loss must be within policy cover period
- Status transitions follow the defined state machine
- Handler assignment is tracked and logged
- Claim notes are timestamped with the adding user
- Claim stats show counts by status and average response times
- Documents can be attached to and retrieved from claims
- All mutations logged to audit_log and customer timeline
- Cannot create claims for policies that were never in force
