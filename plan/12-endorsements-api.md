# Step 12 — Endorsements & Mid-Term Adjustments API

## Goal
Build endorsement processing: mid-term policy changes that create new versions with recalculated premiums and updated risk items.

## Prerequisites
- Steps 01–11 completed

---

## Prompt

You are building the endorsement (mid-term adjustment) API for a UK insurance broker policy admin SaaS. When a customer needs to change their policy mid-term (e.g., change vehicle, add a property, update sum insured), the system creates a new policy version with adjusted financials.

### Key rules (from CLAUDE.md):
- Policy versions are IMMUTABLE — never update, only insert new versions
- Each endorsement creates a new version with incremented version_number
- Financial adjustments (additional premium or return premium) must be calculated
- Re-rating via binder API may be required if the change affects rated items
- Endorsement documents must be generated

### Files to create:

```
packages/api/src/
├── services/
│   └── endorsement.service.ts    # Endorsement business logic
├── routes/
│   └── endorsements.ts           # Endorsement routes
```

### Requirements:

1. **Endorsement service** (`services/endorsement.service.ts`):
   - `createEndorsement(brokerId, policyId, userId, data)`: Start an endorsement:
     1. Validate policy is in 'in_force' or 'endorsed' status
     2. Transition policy to 'endorsement_pending'
     3. Create new policy_version with:
        - version_number = previous version + 1
        - transaction_type = 'endorsement'
        - effective_date = endorsement effective date
        - reason = description of changes
     4. Copy existing risk items to new version, applying the changes
     5. Return the pending endorsement for review
   - `rateEndorsement(brokerId, policyId, versionId)`: Re-rate the endorsement:
     1. If binder supports API rating, call with updated risk items
     2. Calculate financial adjustment:
        - New premium based on updated risk
        - Pro-rata adjustment from effective_date to expiry_date
        - Additional premium = new pro-rata - remaining old pro-rata
        - Recalculate commission on the adjustment
        - Recalculate IPT on the adjustment
     3. Create policy_financials for the new version
     4. Store rating payload/response
   - `manualRateEndorsement(brokerId, policyId, versionId, financialData, reason)`: Manual premium adjustment with mandatory reason
   - `approveEndorsement(brokerId, policyId, versionId, userId)`: Complete the endorsement:
     1. Validate policy is in 'endorsement_pending'
     2. Transition policy to 'endorsed'
     3. Generate endorsement notice document
     4. Create invoice for additional premium (if positive adjustment)
     5. Log to audit trail and customer timeline
   - `rejectEndorsement(brokerId, policyId, versionId, reason)`: Cancel the endorsement:
     1. Transition policy back to 'in_force' or 'endorsed' (previous status)
     2. Mark the version as rejected (add to reason field)
     3. Log rejection reason
   - `getEndorsementDetail(brokerId, policyId, versionId)`: Get endorsement with:
     - Changes compared to previous version (diff of risk items)
     - Financial adjustment breakdown
     - Status (pending/approved/rejected)
   - `listEndorsements(brokerId, filters)`: List endorsements with filters: policyId, status, date range

2. **Pro-rata calculation logic**:
   ```
   daysRemaining = expiryDate - endorsementEffectiveDate
   totalDays = expiryDate - inceptionDate
   proRataFactor = daysRemaining / totalDays

   oldProRataRemaining = oldGrossPremium * proRataFactor
   newProRataRemaining = newGrossPremium * proRataFactor
   adjustmentPremium = newProRataRemaining - oldProRataRemaining

   adjustmentCommission = adjustmentPremium * commissionRate / 100
   adjustmentIpt = adjustmentPremium * iptRate / 100
   ```

3. **Endorsement routes** (`routes/endorsements.ts`):
   - `POST /api/policies/:id/endorsements` — create endorsement (requires `endorsements:create`)
     Body: `{ effectiveDate, reason, riskItemChanges: [{ itemId?, itemType, itemData, sumInsured }] }`
   - `POST /api/policies/:id/endorsements/:versionId/rate` — rate endorsement (requires `quotes:rate`)
   - `POST /api/policies/:id/endorsements/:versionId/manual-rate` — manual rate (requires `quotes:rate`)
   - `POST /api/policies/:id/endorsements/:versionId/approve` — approve (requires `endorsements:approve`)
   - `POST /api/policies/:id/endorsements/:versionId/reject` — reject (requires `endorsements:approve`)
   - `GET /api/policies/:id/endorsements` — list endorsements for policy (requires `policies:read`)
   - `GET /api/policies/:id/endorsements/:versionId` — endorsement detail with diff (requires `policies:read`)

4. **Risk item change handling**:
   - New risk items: add to new version
   - Modified risk items: copy to new version with changes
   - Removed risk items: don't copy to new version
   - Unchanged risk items: copy as-is to new version
   - The version should contain the COMPLETE set of risk items (not just changes)

### Acceptance criteria:
- Endorsement creates a new immutable version (old version unchanged)
- Pro-rata premium adjustment is calculated correctly
- Additional premium generates an invoice
- Return premium (if risk reduced) is tracked for refund
- Endorsement can be rejected, reverting policy to previous status
- Risk item diff shows what changed between versions
- Re-rating via binder API stores payload/response for audit
- All actions logged to audit_log and customer timeline
