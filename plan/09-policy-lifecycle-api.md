# Step 09 — Policy Lifecycle API

## Goal
Build policy management endpoints covering status transitions, version history, policy issuance, and policy search/listing.

## Prerequisites
- Steps 01–08 completed (quoting creates policies in draft/quoted/bound states)

---

## Prompt

You are building the policy lifecycle API for a UK insurance broker policy admin SaaS. Quotes are already created as policies in draft/quoted/bound states (Step 08). Now implement the full policy lifecycle: issuance, status transitions, version management, and policy search.

### Policy states (from CLAUDE.md):
`draft → quoted → bound → issued → in_force → endorsement_pending → endorsed → cancelled → lapsed → expired`

### Valid transitions:
- draft → quoted (after rating)
- quoted → bound (after binding)
- bound → issued (after document generation)
- issued → in_force (automatic or manual activation on inception date)
- in_force → endorsement_pending (when endorsement requested)
- endorsement_pending → endorsed (when endorsement completed)
- endorsed → endorsement_pending (subsequent endorsement)
- in_force → cancelled, endorsed → cancelled (cancellation)
- in_force → lapsed, endorsed → lapsed (non-payment/breach)
- in_force → expired, endorsed → expired (natural expiry)

### Files to create:

```
packages/api/src/
├── services/
│   └── policy.service.ts         # Policy lifecycle operations
├── routes/
│   └── policies.ts               # Policy routes
├── jobs/
│   └── policy-status.job.ts      # Scheduled job for auto-transitions
```

### Requirements:

1. **Policy service** (`services/policy.service.ts`):
   - `issuePolicy(brokerId, policyId, userId)`: Transition bound → issued:
     1. Validate policy is in 'bound' status
     2. Generate policy documents (delegate to document service — stub for now)
     3. Update status to 'issued'
     4. Create audit log entry
     5. Create customer timeline entry
     6. Return issued policy
   - `activatePolicy(brokerId, policyId)`: Transition issued → in_force:
     1. Validate inception date has been reached (or allow early activation)
     2. Update status to 'in_force'
     3. Log transition
   - `transitionStatus(brokerId, policyId, newStatus, reason, userId)`: Generic transition with validation:
     1. Check current status allows transition to newStatus (use state machine map)
     2. Update status
     3. Create audit log with reason
     4. Return updated policy
   - `getPolicy(brokerId, policyId)`: Get policy with:
     - Current version (latest)
     - Financial summary
     - Customer info
     - Product/binder info
     - Status history (from audit_log)
     - Document list
   - `getPolicyVersions(brokerId, policyId)`: List all versions for a policy with their financials
   - `getPolicyVersion(brokerId, policyId, versionNumber)`: Get specific version with financials and risk items
   - `comparePolicyVersions(brokerId, policyId, v1, v2)`: Return diff between two versions (changed fields in risk items and financials)
   - `listPolicies(brokerId, filters, pagination)`: Paginated list with filters:
     - `status` — filter by one or more statuses
     - `customerId` — policies for specific customer
     - `productId` — policies for specific product
     - `binderId` — policies under specific binder
     - `search` — search by policy_number or customer name
     - `inceptionDateFrom/To` — date range
     - `expiryDateFrom/To` — date range
     - `sortBy` — policy_number, inception_date, expiry_date, created_at, status
   - `getPolicySummaryStats(brokerId)`: Return counts by status for dashboard widgets

2. **State machine** — define valid transitions as a map:
   ```typescript
   const VALID_TRANSITIONS: Record<PolicyStatus, PolicyStatus[]> = {
     draft: ['quoted'],
     quoted: ['bound', 'draft'], // allow back to draft for re-editing
     bound: ['issued'],
     issued: ['in_force'],
     in_force: ['endorsement_pending', 'cancelled', 'lapsed', 'expired'],
     endorsement_pending: ['endorsed', 'in_force'], // in_force = endorsement rejected/cancelled
     endorsed: ['endorsement_pending', 'cancelled', 'lapsed', 'expired'],
     cancelled: [],
     lapsed: [],
     expired: [],
   };
   ```

3. **Policy status job** (`jobs/policy-status.job.ts`):
   - Scheduled job (daily) to auto-transition:
     - `issued` → `in_force` when inception_date <= today
     - `in_force`/`endorsed` → `expired` when expiry_date < today
   - Use BullMQ for job scheduling (or a simple cron-based approach)
   - Log all automatic transitions

4. **Policy routes** (`routes/policies.ts`):
   - `GET /api/policies` — list with filters/search (requires `policies:read`)
   - `GET /api/policies/stats` — summary counts by status (requires `policies:read`)
   - `GET /api/policies/:id` — get policy detail (requires `policies:read`)
   - `GET /api/policies/:id/versions` — list versions (requires `policies:read`)
   - `GET /api/policies/:id/versions/:versionNumber` — get specific version (requires `policies:read`)
   - `GET /api/policies/:id/versions/compare?v1=1&v2=2` — compare versions (requires `policies:read`)
   - `POST /api/policies/:id/issue` — issue policy (requires `policies:update`)
   - `POST /api/policies/:id/activate` — activate policy (requires `policies:update`)
   - `POST /api/policies/:id/transition` — generic transition (requires `policies:update`)
     Body: `{ newStatus, reason }`

5. **Policy number display**: Format policy numbers consistently. When listing, include customer name, product name, status badge colour mapping, and premium total.

### Acceptance criteria:
- Status transitions follow the state machine — invalid transitions return 400 with "Invalid transition from X to Y"
- All transitions are logged to audit_log with user, reason, and timestamp
- Policy detail includes full version history
- Version comparison shows field-level differences
- Daily job auto-activates and auto-expires policies
- Policy search works across policy number and customer name
- Stats endpoint returns correct counts per status
- Policies are always scoped to the authenticated broker (tenant isolation)
