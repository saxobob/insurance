# Step 35 — Frontend: Commission Management Pages

## Goal
Build commission splits table, clawback tracking, and commission ledger export.

## Prerequisites
- Steps 25–34 completed

---

## Prompt

You are building the commission management pages for a UK insurance broker policy admin SaaS React frontend.

### Files to create:

```
packages/web/src/
├── routes/_app/financials/
│   └── commissions.tsx           # Commission ledger page
├── hooks/
│   └── use-commissions.ts
├── components/
│   └── financials/
│       ├── commission-table.tsx   # Commission ledger table
│       ├── commission-splits.tsx  # Split editor for a policy
│       ├── clawback-table.tsx     # Clawback list
│       ├── commission-summary.tsx # Summary cards
│       └── commission-export.tsx  # Export controls
```

### Requirements:

1. **Commission ledger page**: Table showing: policy number, customer, product, binder, transaction date, gross premium, commission rate, commission amount, payee, payee type. Filter by payee, product, binder, date range. Summary cards at top: total earned, total clawbacks, net commission.

2. **Commission splits editor** (on policy financials tab): Show current splits for a policy financial. Editable: add/remove payees, set rate or fixed amount. Validate total doesn't exceed 100% / commission amount.

3. **Clawback table**: List of clawbacks with policy number, original commission, clawback amount, clawback date, reason. Filter by date range.

4. **Export**: "Export CSV" button with date range selector. Downloads commission ledger as CSV for payroll/accounts.

### Acceptance criteria:
- Commission ledger shows all commission entries
- Splits can be edited with validation
- Clawbacks displayed separately with clear labelling
- CSV export contains all required columns
- Summary cards show accurate totals
