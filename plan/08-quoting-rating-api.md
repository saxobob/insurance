# Step 08 — Quoting & Binder Rating Integration API

## Goal
Build the quote creation flow including binder API rating calls, manual rating fallback, IPID acknowledgement gate for consumer products, and quote-to-bind transition.

## Prerequisites
- Steps 01–07 completed (binder and product config exists)

---

## Prompt

You are building the quoting and rating API for a UK insurance broker policy admin SaaS. Brokers create quotes for customers by selecting a product (under a binder), capturing risk details, and getting a rated premium from the binder's API. If the API is unavailable, manual rating is supported with mandatory documentation.

### Schema context:
- `policies`: id, broker_id, customer_id, product_id, policy_number, status, inception_date, expiry_date
- `policy_versions`: id, policy_id, version_number, transaction_type, effective_date, reason, rating_payload (JSONB), rating_response (JSONB), created_by
- `policy_financials`: id, policy_version_id, gross_premium, broker_fee, commission_rate, commission_amount, ipt_rate, ipt_amount, net_to_insurer, currency, ipt_rate_id
- `policy_risk_items`: id, policy_version_id, item_type, item_data (JSONB), sum_insured
- `ipid_acknowledgements`: id, policy_version_id, acknowledged_at, acknowledged_by
- `tax_rates`: id, broker_id, tax_type, class_of_business, rate, effective_from, effective_to

### Files to create:

```
packages/api/src/
├── services/
│   ├── quote.service.ts          # Quote creation & rating logic
│   ├── rating.service.ts         # Binder API calling logic
│   ├── ipt.service.ts            # IPT rate lookup
│   └── policy-number.service.ts  # Policy number generation
├── routes/
│   └── quotes.ts                 # Quote routes
```

### Requirements:

1. **Policy number generation** (`services/policy-number.service.ts`):
   - Generate unique policy numbers per broker: `{BROKER_PREFIX}/{YEAR}/{SEQUENCE}`
   - e.g., `ACM/2026/000001`
   - Use a sequence counter per broker (store in DB or use PostgreSQL sequence)
   - Thread-safe (handle concurrent creates)

2. **IPT service** (`services/ipt.service.ts`):
   - `getIptRate(brokerId, classOfBusiness, transactionDate)`: Look up the tax_rates table for the IPT rate active at the transaction date. Match on class_of_business and date within effective_from/effective_to range.
   - `calculateIpt(grossPremium, iptRate)`: Return IPT amount rounded to 2 decimal places.
   - Current UK IPT rates to seed: 12% standard rate, 20% higher rate (travel insurance)

3. **Rating service** (`services/rating.service.ts`):
   - `callBinderRating(binder, ratingPayload)`: Make HTTP call to binder's API endpoint with the rating payload. Return the rating response. Handle:
     - Timeout (configurable, default 30s)
     - HTTP errors (4xx, 5xx) — return structured error
     - Network failures — return structured error
   - Store both request payload and response in policy_versions.rating_payload / rating_response
   - `buildRatingPayload(product, customer, riskItems, inceptionDate, expiryDate)`: Build the payload structure to send to the binder API. Structure varies per binder — use a flexible approach (the payload shape is defined by the risk items).

4. **Quote service** (`services/quote.service.ts`):
   - `createQuote(brokerId, userId, data)`: Full quote creation flow:
     1. Validate customer exists and belongs to broker
     2. Validate product exists, is active, and belongs to broker
     3. Generate policy number
     4. Create policy record with status='draft'
     5. Create policy_version (version_number=1, transaction_type='new')
     6. Create policy_risk_items from the risk details provided
     7. Return the draft quote
   - `rateQuote(brokerId, policyId)`: Rate an existing draft quote:
     1. Load policy, version, risk items, product, binder
     2. If binder supports API rating: call rating service, store payload/response
     3. If binder doesn't support API rating OR API fails: mark as requiring manual rating
     4. If rating succeeds: look up IPT rate, calculate financials, create policy_financials record
     5. Update policy status to 'quoted'
     6. Return the quote with premium breakdown
   - `manualRate(brokerId, policyId, premiumData, reason)`: Manual rating entry:
     1. Require a reason (regulatory audit trail)
     2. Create policy_financials with manually entered figures
     3. Store reason in policy_version.reason
     4. Update policy status to 'quoted'
     5. Flag the version as manually rated (add to rating_response: `{ manual: true, reason }`)
   - `acknowledgeIpid(brokerId, policyId, acknowledgedBy)`: Record IPID acknowledgement:
     1. Check if product requires IPID (retail_consumer + ipid_required)
     2. Create ipid_acknowledgement record
   - `bindQuote(brokerId, policyId, userId)`: Bind the quote:
     1. Check policy is in 'quoted' status
     2. If product requires IPID: check ipid_acknowledgement exists. If not, return error "IPID must be acknowledged before binding"
     3. Update policy status to 'bound'
     4. Create timeline entry for customer
     5. Return bound policy
   - `getQuote(brokerId, policyId)`: Get quote with version, financials, risk items, IPID status
   - `listQuotes(brokerId, filters, pagination)`: List quotes (policies in draft/quoted status) with filters: customer, product, date range

5. **Quote routes** (`routes/quotes.ts`):
   - `POST /api/quotes` — create draft quote (requires `quotes:create`)
     Body: `{ customerId, productId, inceptionDate, expiryDate, riskItems: [{ itemType, itemData, sumInsured }] }`
   - `POST /api/quotes/:id/rate` — rate the quote via binder API (requires `quotes:rate`)
   - `POST /api/quotes/:id/manual-rate` — manually enter premium (requires `quotes:rate` + logged reason)
     Body: `{ grossPremium, brokerFee, commissionRate, reason }`
   - `POST /api/quotes/:id/acknowledge-ipid` — record IPID acknowledgement (requires `quotes:create`)
   - `POST /api/quotes/:id/bind` — bind the quote (requires `policies:bind`)
   - `GET /api/quotes` — list quotes (requires `quotes:read`)
   - `GET /api/quotes/:id` — get quote detail (requires `quotes:read`)

6. **Financial calculation logic**:
   - `gross_premium` — from binder API response or manual entry
   - `broker_fee` — from manual entry or binder config
   - `commission_rate` — from binder config or manual entry
   - `commission_amount` = `gross_premium * commission_rate / 100`
   - `ipt_rate` — looked up from tax_rates by class_of_business and date
   - `ipt_amount` = `gross_premium * ipt_rate / 100`
   - `net_to_insurer` = `gross_premium - commission_amount`
   - Store the `ipt_rate_id` FK to preserve which rate record was used

### Acceptance criteria:
- Draft quote creates policy + version + risk items
- Rating calls binder API and stores payload/response
- Manual rating requires a reason and is flagged in the data
- IPT is calculated using the correct historical rate for the class of business
- Consumer product quote cannot be bound without IPID acknowledgement
- Commercial product quote can be bound without IPID
- Financial breakdown is accurate (gross, commission, IPT, net all correct)
- Failed binder API calls are logged and user can fall back to manual rating
- All mutations logged to audit_log and customer timeline
