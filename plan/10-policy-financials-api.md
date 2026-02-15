# Step 10 — Policy Financials & IPT Calculation API

## Goal
Build dedicated financial management endpoints for policies including premium breakdown, IPT calculation with historic rates, broker fees, and financial summaries.

## Prerequisites
- Steps 01–09 completed (quotes create basic financials; this step adds full financial management)

---

## Prompt

You are building the policy financials API for a UK insurance broker policy admin SaaS. Basic financial records are created during quoting (Step 08). This step adds comprehensive financial management, tax rate administration, and financial reporting helpers.

### Schema context:
- `policy_financials`: id, policy_version_id, gross_premium, broker_fee, commission_rate, commission_amount, ipt_rate, ipt_amount, net_to_insurer, currency, ipt_rate_id
- `tax_rates`: id, broker_id, tax_type, class_of_business, rate, effective_from, effective_to
- Financial precision: numeric(12,2) for money, numeric(5,2) for rates

### Files to create:

```
packages/api/src/
├── services/
│   ├── financial.service.ts      # Financial calculation & management
│   └── tax-rate.service.ts       # Tax rate administration
├── routes/
│   ├── policy-financials.ts      # Financial routes for policies
│   └── tax-rates.ts              # Tax rate admin routes
```

### Requirements:

1. **Financial service** (`services/financial.service.ts`):
   - `calculateFinancials(grossPremium, brokerFee, commissionRate, iptRate)`: Pure calculation:
     - `commission_amount` = round(grossPremium * commissionRate / 100, 2)
     - `ipt_amount` = round(grossPremium * iptRate / 100, 2)
     - `net_to_insurer` = round(grossPremium - commission_amount, 2)
     - `total_payable` = round(grossPremium + ipt_amount + brokerFee, 2) — what the customer pays
     - Return all calculated fields
   - `getFinancialsForPolicy(brokerId, policyId)`: Get financials for the latest version
   - `getFinancialsForVersion(brokerId, policyVersionId)`: Get financials for specific version
   - `getFinancialHistory(brokerId, policyId)`: All financial records across versions (shows premium changes over endorsements)
   - `calculateReturnPremium(originalFinancials, cancellationDate, expiryDate, method)`:
     - `method = 'pro_rata'`: Return premium proportional to unused days
     - `method = 'short_period'`: Use short-period rate table (configurable percentages)
     - Returns: return_premium, return_commission, return_ipt
   - `getFinancialSummary(brokerId, dateFrom, dateTo)`: Aggregate summary:
     - Total GWP (gross written premium)
     - Total broker fees
     - Total commission earned
     - Total IPT collected
     - Total net to insurers
     - Breakdown by product/binder

2. **Tax rate service** (`services/tax-rate.service.ts`):
   - `getActiveRate(brokerId, classOfBusiness, date)`: Find the tax rate active at given date. Match: broker_id + tax_type='IPT' + class_of_business + effective_from <= date + (effective_to IS NULL OR effective_to >= date). If no rate found, return error.
   - `listRates(brokerId, filters)`: List all tax rates with filters: class_of_business, active/historical
   - `createRate(brokerId, data)`: Create new rate. If there's an existing open-ended rate for same class, close it (set effective_to = new rate's effective_from - 1 day).
   - `updateRate(brokerId, rateId, data)`: Update rate (only if not yet used by any policy_financials).
   - `getRateHistory(brokerId, classOfBusiness)`: Show rate changes over time for a class of business.

3. **Financial routes** (`routes/policy-financials.ts`):
   - `GET /api/policies/:id/financials` — current financials (requires `policies:read`)
   - `GET /api/policies/:id/financials/history` — financial history across versions (requires `policies:read`)
   - `GET /api/policies/:policyId/versions/:versionId/financials` — version-specific financials (requires `policies:read`)
   - `GET /api/financials/summary?from=&to=` — aggregate financial summary (requires `reports:read`)
   - `POST /api/policies/:id/financials/calculate-return` — calculate return premium (requires `policies:read`)
     Body: `{ cancellationDate, method: 'pro_rata' | 'short_period' }`

4. **Tax rate routes** (`routes/tax-rates.ts`):
   - `GET /api/tax-rates` — list all rates (requires `settings:read`)
   - `GET /api/tax-rates/current` — list currently active rates (requires `settings:read`)
   - `GET /api/tax-rates/history/:classOfBusiness` — rate history for class (requires `settings:read`)
   - `POST /api/tax-rates` — create new rate (requires `settings:manage`)
   - `PUT /api/tax-rates/:id` — update rate (requires `settings:manage`)

5. **Validation rules**:
   - Gross premium must be >= 0
   - Commission rate must be 0-100
   - IPT rate must be >= 0
   - Broker fee must be >= 0
   - All amounts stored as numeric(12,2) — validate no more than 2 decimal places
   - Currency defaults to 'GBP'

6. **Seed data for tax rates** (update existing seed):
   - IPT Standard Rate: 12%, effective_from 2011-01-04, no effective_to (current)
   - IPT Higher Rate (travel): 20%, effective_from 2011-01-04, no effective_to
   - Include a historical rate for testing: IPT Standard was 6% from 2007-01-01 to 2011-01-03

### Acceptance criteria:
- Financial calculations are accurate to 2 decimal places
- IPT rate lookup uses the rate active at the transaction date, not today's date
- Historical rates are preserved — changing a rate creates a new record, doesn't modify old ones
- Return premium calculation handles pro-rata and short-period methods
- Financial summary correctly aggregates across all policies in date range
- Tax rates that are already used by policy_financials cannot be modified
- All financial amounts use numeric(12,2) precision
