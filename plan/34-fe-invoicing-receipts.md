# Step 34 — Frontend: Invoicing & Receipts Pages

## Goal
Build invoice list, receipt recording, payment allocation, and reconciliation views.

## Prerequisites
- Steps 25–30 completed

---

## Prompt

You are building the invoicing and receipts pages for a UK insurance broker policy admin SaaS React frontend.

### Files to create/modify:

```
packages/web/src/
├── routes/_app/financials/
│   ├── index.tsx                 # Financial overview (redirect or tabs)
│   ├── invoices.tsx              # Invoice list
│   ├── receipts.tsx              # Receipt list
│   └── reconciliation.tsx        # Reconciliation view
├── hooks/
│   ├── use-invoices.ts
│   └── use-receipts.ts
├── components/
│   └── financials/
│       ├── invoice-table.tsx      # Invoice data table
│       ├── invoice-detail.tsx     # Invoice detail modal
│       ├── receipt-table.tsx      # Receipt data table
│       ├── receipt-form.tsx       # Record receipt form
│       ├── allocation-modal.tsx   # Allocate receipt to invoices
│       ├── aging-summary.tsx      # Aged debtor summary cards
│       └── reconciliation-view.tsx # Side-by-side reconciliation
```

### Requirements:

1. **Invoice list**: Table with invoice number, customer, policy number, date, due date, amount, status (outstanding/part_paid/paid/overdue badge), actions. Overdue invoices highlighted. Filter by status, date range. Aging summary cards at top (current, 30/60/90+ days).

2. **Invoice detail modal**: Click invoice → modal showing: line items (premium, IPT, fees), payment history (allocations from receipts), remaining balance, policy link, download PDF button.

3. **Receipt list**: Table with date, amount, payment method badge, reference, allocated amount, unallocated balance, actions. Filter by payment method, date range, allocation status.

4. **Receipt form**: Date picker, amount (currency), payment method (select), reference (text). Simple form.

5. **Allocation modal**: Select a receipt → shows unallocated balance. List of outstanding invoices with amounts. Checkbox + amount input per invoice. Auto-suggest matches by amount. Total allocation cannot exceed receipt amount. Visual running total.

6. **Aging summary**: Four cards showing aged debt: Current, 1-30 days, 31-60 days, 61-90 days, 90+ days. Each shows count and total amount. Click navigates to filtered invoice list.

7. **Reconciliation view**: Split view — receipts on left, invoices on right. Drag-and-drop or click to match. Shows unmatched items highlighted.

### Acceptance criteria:
- Invoice list shows correct aging indicators
- Receipt recording creates record and appears in list
- Allocation modal prevents over-allocation
- Allocated invoices update status to part_paid/paid
- Aging summary shows correct counts and amounts
- Reconciliation view helps match unallocated receipts to invoices
