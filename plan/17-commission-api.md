# Step 17 — Commission Splits & Clawbacks API

## Goal
Build commission management: splits between multiple payees, clawback tracking, and commission ledger exports.

## Prerequisites
- Steps 01–16 completed

---

## Prompt

You are building the commission management API for a UK insurance broker policy admin SaaS. Commissions can be split between the broker and introducers. Clawbacks occur when policies are cancelled within a clawback window.

### Schema context:
- `commission_splits`: id, policy_financial_id, payee_name, payee_type, rate, amount, created_at
- `commission_clawbacks`: id, policy_version_id, original_commission, clawback_amount, clawback_date, reason, created_at
- Payee types: `broker`, `introducer`, `sub_agent`, `other`

### Files to create:

```
packages/api/src/
├── services/
│   └── commission.service.ts     # Commission business logic
├── routes/
│   └── commissions.ts            # Commission routes
```

### Requirements:

1. **Commission service** (`services/commission.service.ts`):
   - `createCommissionSplits(policyFinancialId, splits)`: Create commission split entries:
     1. Validate total split percentages don't exceed 100%
     2. Validate total split amounts don't exceed commission_amount from policy_financials
     3. Create commission_split records
     Input: `{ splits: [{ payeeName, payeeType, rate?, amount }] }`
   - `getCommissionSplits(policyFinancialId)`: Get splits for a policy financial record
   - `getCommissionForPolicy(brokerId, policyId)`: Get all commission info across versions
   - `listCommissions(brokerId, filters, pagination)`: Commission ledger with filters:
     - `payeeName`, `payeeType`, `dateFrom/dateTo`, `binderId`, `productId`
     - Include: policy number, customer name, gross premium, commission rate, commission amount, split details
   - `getCommissionSummary(brokerId, dateFrom, dateTo)`: Aggregate:
     - Total commission earned
     - Total by payee
     - Total by product/binder
     - Total clawbacks
     - Net commission (earned - clawbacks)
   - `listClawbacks(brokerId, filters, pagination)`: List clawbacks with policy details
   - `getClawbackSummary(brokerId, dateFrom, dateTo)`: Aggregate clawback amounts by period
   - `exportCommissionLedger(brokerId, dateFrom, dateTo, format)`: Export as CSV:
     Columns: Policy Number, Customer, Product, Binder, Transaction Date, Gross Premium, Commission Rate, Commission Amount, Payee, Payee Type, Clawback Amount

2. **Default commission split**: When policy_financials are created (during quoting/endorsement), auto-create a default commission split with 100% to the broker. Users can then modify splits.

3. **Commission routes** (`routes/commissions.ts`):
   - `GET /api/commissions` — commission ledger (requires `commissions:read`)
   - `GET /api/commissions/summary` — aggregate summary (requires `commissions:read`)
   - `GET /api/commissions/clawbacks` — clawback list (requires `commissions:read`)
   - `GET /api/commissions/clawbacks/summary` — clawback summary (requires `commissions:read`)
   - `GET /api/commissions/export` — CSV export (requires `commissions:read`)
     Query: `?from=&to=&format=csv`
   - `GET /api/policies/:id/commissions` — commission for specific policy (requires `commissions:read`)
   - `POST /api/policies/:policyId/financials/:financialId/splits` — set commission splits (requires `commissions:manage`)
   - `PUT /api/policies/:policyId/financials/:financialId/splits` — update commission splits (requires `commissions:manage`)

### Acceptance criteria:
- Commission splits total cannot exceed 100% rate or the commission amount
- Default split assigns 100% to broker
- Clawbacks are linked to cancellation versions
- Commission ledger shows all commission entries with policy context
- CSV export contains all required columns for payroll/accounts processing
- Summary correctly aggregates earned commission minus clawbacks
- All commission changes logged to audit_log
