# Step 30 — Frontend: Policy Management Pages

## Goal
Build policy list, detail, version history, status transitions, and version comparison views.

## Prerequisites
- Steps 25–29 completed

---

## Prompt

You are building the policy management pages for a UK insurance broker policy admin SaaS React frontend. Policies are the core entity — this is the most-used part of the UI.

### Files to create/modify:

```
packages/web/src/
├── routes/_app/policies/
│   ├── index.tsx                 # MODIFY: full policy list
│   └── $policyId.tsx             # MODIFY: full policy detail
├── hooks/
│   └── use-policies.ts           # Policy API hooks
├── components/
│   └── policies/
│       ├── policy-table.tsx       # Policy data table with filters
│       ├── policy-detail.tsx      # Policy detail layout
│       ├── policy-header.tsx      # Policy header with status, actions
│       ├── policy-overview.tsx    # Overview tab content
│       ├── policy-versions.tsx    # Version history tab
│       ├── version-diff.tsx       # Version comparison component
│       ├── policy-status-flow.tsx # Visual status flow diagram
│       ├── policy-actions.tsx     # Action buttons (issue, endorse, cancel)
│       └── status-transition-dialog.tsx # Transition confirmation dialog
```

### Requirements:

1. **Policy list page**:
   - Data table: Policy Number, Customer, Product, Status (coloured badge), Inception, Expiry, Premium, Created
   - Filters: status (multi-select), product, binder, date ranges (inception/expiry), search
   - Status filter shows counts per status
   - Sort by any column
   - Row click → policy detail
   - Quick actions: view, endorse, cancel (permission-gated)

2. **Policy detail page** — Tabbed layout with header:
   - **Header**: Policy number, customer name (linked), product, status badge, cover period, version indicator ("v3"). Action buttons based on current status.
   - **Overview tab**: Policy info, current risk items, cover period, product/binder info. Status flow diagram showing the policy's journey through states.
   - **Financials tab**: Current premium breakdown, financial history across versions (handled in Step 31)
   - **Versions tab**: List of all versions with version number, transaction type (new/endorsement/renewal/cancellation badge), effective date, created by, created at. Click to view version detail. "Compare" button to select two versions for diff.
   - **Documents tab**: List of documents with type, filename, date, download button (handled in Step 31)
   - **Timeline tab**: Policy-specific timeline (status changes, endorsements, emails, documents)

3. **Version diff component**: Side-by-side comparison of two versions:
   - Highlight changed fields in risk items
   - Show financial changes (old premium vs new, adjustment amount)
   - Show who made the change and why

4. **Status flow diagram**: Visual representation of the policy's state journey. Show completed states (green), current state (blue/pulsing), future possible states (gray). Use a horizontal stepper or flow diagram.

5. **Action buttons** — context-dependent based on current status:
   - `bound` → "Issue Policy" button
   - `issued` → "Activate" button (or automatic)
   - `in_force`/`endorsed` → "Endorse", "Cancel" buttons
   - Each action shows confirmation dialog with reason field where required
   - Permission-gated: only show if user has the required permission

6. **Status transition dialog**: Modal with:
   - Current status → New status
   - Reason field (required for some transitions)
   - Confirmation button
   - Shows what will happen (e.g., "This will generate cancellation documents and calculate return premium")

### Acceptance criteria:
- Policy list loads with all filter options working
- Policy detail shows all tabs with correct data
- Version history is complete and clickable
- Version diff highlights changes clearly
- Status flow diagram reflects actual policy journey
- Action buttons only appear for valid transitions
- Transitions require confirmation and log to audit
- All elements are permission-gated
