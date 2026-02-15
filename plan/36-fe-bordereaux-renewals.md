# Step 36 — Frontend: Bordereaux & Renewals Pages

## Goal
Build bordereau runs management and renewal pipeline views.

## Prerequisites
- Steps 25–35 completed

---

## Prompt

You are building the bordereaux and renewals pages for a UK insurance broker policy admin SaaS React frontend.

### Files to create/modify:

```
packages/web/src/
├── routes/_app/
│   ├── bordereaux/
│   │   ├── index.tsx             # Bordereau runs list
│   │   └── $runId.tsx            # Run detail with items
│   └── renewals/
│       ├── index.tsx             # Renewal pipeline
│       └── $renewalId.tsx        # Renewal detail
├── hooks/
│   ├── use-bordereaux.ts
│   └── use-renewals.ts
├── components/
│   ├── bordereaux/
│   │   ├── run-table.tsx          # Bordereau runs table
│   │   ├── run-detail.tsx         # Run detail with items
│   │   ├── run-wizard.tsx         # Create new run wizard
│   │   ├── item-table.tsx         # Items in a run (with validation status)
│   │   ├── validation-summary.tsx # Validation results display
│   │   └── preview-table.tsx      # Preview bordereau data
│   └── renewals/
│       ├── pipeline-view.tsx      # Kanban-style pipeline
│       ├── renewal-table.tsx      # Renewal list table
│       ├── renewal-detail.tsx     # Renewal detail card
│       └── batch-actions.tsx      # Batch generate/send controls
```

### Requirements:

1. **Bordereau runs list**: Table with binder name, run type (premium/renewal badge), period, status (coloured badge), item count, file (download link if generated), created. Filter by binder, type, status. "New Run" button.

2. **New run wizard**: Select binder → select type → set period dates → create. Shows preview of how many items will be included.

3. **Run detail page**: Header with run info and status. Stepper showing run progress: Draft → Validated → Generated → Transmitted. Items table: policy number, customer, transaction type, premium, validation status (pass/fail). Exclude/include toggle per item. Validation errors shown inline.
   - Action buttons progress through states: Validate → Generate → Download → Transmit
   - Validation summary: total items, valid, invalid, error categories

4. **Preview**: Before generating, show first 20 rows of the bordereau as a table matching the binder's column mapping.

5. **Renewal pipeline** — two views:
   - **Kanban view**: Columns for pending, quote_generated, quote_sent, accepted, declined. Cards show policy number, customer, premium, expiry date. Drag not needed, but visual pipeline.
   - **Table view**: Standard data table with all renewal fields, filters by status, date range, product
   - Toggle between kanban and table views

6. **Renewal detail**: Show original policy info, quoted renewal premium, comparison with current premium (% change), status, action buttons (generate quote, send notice, accept, decline).

7. **Batch actions**: Select multiple renewals → batch generate quotes or batch send notices. Progress indicator for batch operations.

### Acceptance criteria:
- Bordereau creation identifies correct items for the period
- Validation shows clear error messages per item
- Items can be excluded/included
- Generated file can be downloaded
- Transmission status tracked
- Renewal pipeline shows clear visual progression
- Batch operations provide feedback
- Kanban view groups renewals by status
