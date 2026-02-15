# Step 16 — Invoicing & Receipts API

## Goal
Build invoice generation, receipt recording, payment allocation (receipt-to-invoice matching), and basic reconciliation.

## Prerequisites
- Steps 01–15 completed

---

## Prompt

You are building the invoicing and receipts API for a UK insurance broker policy admin SaaS. This is NOT a full accounting package — it captures invoices issued to customers, records payments received, and allocates payments against invoices for reconciliation.

### Schema context:
- `invoices`: id, broker_id, policy_version_id, invoice_number (unique), invoice_date, due_date, total_amount, status (default 'outstanding'), created_at
- `receipts`: id, broker_id, receipt_date, amount, payment_method, reference, created_at
- `receipt_allocations`: id, receipt_id, invoice_id, amount

### Files to create:

```
packages/api/src/
├── services/
│   ├── invoice.service.ts        # Invoice management
│   └── receipt.service.ts        # Receipt & allocation management
├── routes/
│   ├── invoices.ts               # Invoice routes
│   └── receipts.ts               # Receipt routes
```

### Requirements:

1. **Invoice service** (`services/invoice.service.ts`):
   - `createInvoice(brokerId, data)`: Create invoice:
     1. Generate invoice number: `INV/{YEAR}/{SEQUENCE}` (unique per broker)
     2. Set invoice_date (default today), due_date (default +30 days, configurable)
     3. total_amount from policy_financials (gross_premium + IPT + broker_fee)
     4. Status = 'outstanding'
     5. Link to policy_version_id
     6. Return created invoice
   - `createCreditNote(brokerId, data)`: Create credit note (negative invoice):
     1. Generate number: `CN/{YEAR}/{SEQUENCE}`
     2. total_amount is negative (return premium)
     3. Link to cancellation/endorsement version
   - `getInvoice(brokerId, invoiceId)`: Get invoice with allocations (payments received against it)
   - `listInvoices(brokerId, filters, pagination)`: List with filters:
     - `status` — outstanding, part_paid, paid, overdue, credit_note
     - `customerId` (via policy → customer)
     - `dateFrom/dateTo`
     - `overdue` — due_date < today AND status != 'paid'
   - `updateInvoiceStatus(invoiceId)`: Recalculate status based on allocations:
     - Sum of allocations = total_amount → 'paid'
     - Sum of allocations > 0 but < total_amount → 'part_paid'
     - Sum = 0 → 'outstanding'
   - `getAgingSummary(brokerId)`: Aged debtor summary:
     - Current (not yet due)
     - 1-30 days overdue
     - 31-60 days overdue
     - 61-90 days overdue
     - 90+ days overdue
   - `generateInvoicePdf(brokerId, invoiceId)`: Generate invoice PDF using document service

2. **Receipt service** (`services/receipt.service.ts`):
   - `recordReceipt(brokerId, data)`: Record payment received:
     1. Create receipt record
     2. Return created receipt
     Input: `{ receiptDate, amount, paymentMethod: 'bank_transfer'|'card'|'cheque'|'cash'|'direct_debit', reference? }`
   - `allocateReceipt(brokerId, receiptId, allocations)`: Allocate receipt to invoices:
     1. Validate total allocations don't exceed receipt amount
     2. Validate each invoice exists and belongs to broker
     3. Create receipt_allocation records
     4. Update invoice statuses (paid/part_paid)
     Input: `{ allocations: [{ invoiceId, amount }] }`
   - `unallocateReceipt(brokerId, receiptId, allocationId)`: Remove an allocation. Revert invoice status.
   - `getReceipt(brokerId, receiptId)`: Get receipt with its allocations
   - `listReceipts(brokerId, filters, pagination)`: List with filters:
     - `paymentMethod`, `dateFrom/dateTo`, `allocated` (fully/partially/unallocated)
   - `getUnallocatedReceipts(brokerId)`: Receipts with remaining unallocated balance
   - `suggestAllocations(brokerId, receiptId)`: Auto-match receipt to outstanding invoices by amount or reference. Return suggestions.

3. **Invoice routes** (`routes/invoices.ts`):
   - `GET /api/invoices` — list invoices (requires `invoices:read`)
   - `GET /api/invoices/aging` — aged debtor summary (requires `invoices:read`)
   - `GET /api/invoices/:id` — get invoice with allocations (requires `invoices:read`)
   - `POST /api/invoices` — create invoice (requires `invoices:create`)
   - `GET /api/invoices/:id/pdf` — download invoice PDF (requires `invoices:read`)

4. **Receipt routes** (`routes/receipts.ts`):
   - `GET /api/receipts` — list receipts (requires `receipts:read`)
   - `GET /api/receipts/unallocated` — unallocated receipts (requires `receipts:read`)
   - `GET /api/receipts/:id` — get receipt with allocations (requires `receipts:read`)
   - `POST /api/receipts` — record receipt (requires `receipts:create`)
   - `POST /api/receipts/:id/allocate` — allocate to invoices (requires `receipts:allocate`)
   - `DELETE /api/receipts/:id/allocations/:allocationId` — remove allocation (requires `receipts:allocate`)
   - `GET /api/receipts/:id/suggest` — suggest invoice matches (requires `receipts:allocate`)

5. **Validation**:
   - Receipt amount must be > 0
   - Allocation amount must be > 0
   - Total allocations for a receipt cannot exceed receipt amount
   - Total allocations for an invoice cannot exceed invoice total_amount
   - Cannot allocate to a fully paid invoice

### Acceptance criteria:
- Invoice numbers are unique and sequential per broker
- Credit notes have negative total_amount
- Receipt allocation updates invoice status (outstanding → part_paid → paid)
- Removing allocation reverts invoice status
- Over-allocation is prevented (validation error)
- Aged debtor summary groups by overdue period
- Allocation suggestion matches by amount or reference
- Invoice PDF generates correctly via document service
