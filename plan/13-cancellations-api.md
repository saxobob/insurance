# Step 13 — Cancellations & Return Premium API

## Goal
Build policy cancellation processing with pro-rata and short-period return premium calculations, commission clawback, and cancellation documentation.

## Prerequisites
- Steps 01–12 completed

---

## Prompt

You are building the cancellation API for a UK insurance broker policy admin SaaS. Cancellations create a new policy version, calculate return premium, handle commission clawbacks, and generate cancellation documents.

### Schema context:
- `commission_clawbacks`: id, policy_version_id, original_commission, clawback_amount, clawback_date, reason, created_at

### Files to create:

```
packages/api/src/
├── services/
│   └── cancellation.service.ts   # Cancellation business logic
├── routes/
│   └── cancellations.ts          # Cancellation routes
```

### Requirements:

1. **Cancellation service** (`services/cancellation.service.ts`):
   - `initiateCancel(brokerId, policyId, userId, data)`: Start cancellation:
     1. Validate policy is in 'in_force' or 'endorsed' status
     2. Create new policy_version with transaction_type='cancellation', effective_date=cancellation date
     3. Calculate return premium based on method (pro_rata or short_period)
     4. Calculate commission clawback if within clawback window
     5. Create policy_financials for cancellation version (negative amounts for returns)
     6. Create commission_clawback record if applicable
     7. Transition policy status to 'cancelled'
     8. Generate cancellation notice document
     9. Create invoice credit note for return premium
     10. Log to audit trail and customer timeline
     Input data: `{ cancellationDate, reason, method: 'pro_rata' | 'short_period', cancellationReason: string }`

   - `calculateReturnPremium(policy, latestVersion, financials, cancellationDate, method)`:
     **Pro-rata method:**
     ```
     totalDays = expiryDate - inceptionDate
     daysUsed = cancellationDate - inceptionDate
     daysUnused = totalDays - daysUsed
     returnFactor = daysUnused / totalDays
     returnPremium = grossPremium * returnFactor
     returnIpt = iptAmount * returnFactor
     ```
     **Short-period method** (insurer retains more):
     ```
     Use a short-period rate table based on percentage of policy period elapsed:
     0-25% elapsed → 50% of annual premium retained
     25-50% elapsed → 75% retained
     50-75% elapsed → 90% retained
     75-100% elapsed → 100% retained (no return)
     ```
     Make the short-period table configurable per binder.

   - `calculateClawback(policyId, cancellationVersion, originalFinancials)`:
     1. Check if cancellation is within clawback window (configurable per binder, default 90 days from inception)
     2. If within window: clawback_amount = original commission_amount (full clawback)
     3. If partially within window: pro-rata clawback based on days within window
     4. Create commission_clawback record
     5. Return clawback details

   - `previewCancellation(brokerId, policyId, cancellationDate, method)`: Calculate and return preview without executing:
     - Return premium amount
     - Return IPT
     - Commission clawback (if applicable)
     - Net refund to customer
     Useful for showing the customer before confirming.

   - `listCancellations(brokerId, filters)`: List cancelled policies with filters: date range, binder, product

2. **Cancellation routes** (`routes/cancellations.ts`):
   - `POST /api/policies/:id/cancel/preview` — preview cancellation figures (requires `policies:read`)
     Body: `{ cancellationDate, method }`
   - `POST /api/policies/:id/cancel` — execute cancellation (requires `policies:cancel`)
     Body: `{ cancellationDate, reason, method }`
   - `GET /api/cancellations` — list cancellations (requires `policies:read`)

3. **Commission clawback rules**:
   - Clawback window is configurable per binder (default 90 days)
   - Within window: full commission clawback
   - Outside window: no clawback
   - Clawback creates a debit entry that can be tracked in commission reports
   - Clawback record links to the cancellation version

4. **Credit note**: When return premium is due, create an invoice with negative total_amount (credit note) linked to the cancellation version.

### Acceptance criteria:
- Pro-rata return premium calculated correctly based on unused days
- Short-period calculation uses configurable rate table
- Commission clawback triggers within the clawback window
- Preview endpoint shows figures without executing cancellation
- Cancellation creates new immutable version (original version unchanged)
- Credit note invoice created for return premium
- Cancellation notice document generated
- Policy status transitions to 'cancelled'
- Cannot cancel a policy that's already cancelled, lapsed, or expired
- All actions logged to audit_log
