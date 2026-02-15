# Step 32 — Frontend: Endorsements & Cancellations UI

## Goal
Build endorsement and cancellation forms with premium adjustment preview.

## Prerequisites
- Steps 30–31 completed

---

## Prompt

You are building the endorsement and cancellation UI for a UK insurance broker policy admin SaaS React frontend. These are accessible from the policy detail page.

### Files to create:

```
packages/web/src/
├── components/
│   └── policies/
│       ├── endorsement-form.tsx   # Endorsement wizard/form
│       ├── cancellation-form.tsx  # Cancellation form with preview
│       ├── endorsement-detail.tsx # Endorsement review/approval
│       ├── return-premium-preview.tsx # Return premium breakdown
│       └── risk-item-editor.tsx   # Editable risk items for endorsement
```

### Requirements:

1. **Endorsement form** (accessible from "Endorse" button on in_force/endorsed policy):
   - Step 1: Effective date picker, reason for change text field
   - Step 2: Risk item editor — shows current risk items as editable cards. Can modify item_data fields, sum_insured. Can add new items or remove existing.
   - Step 3: Rate — "Get New Premium" button calls endorsement rating API. Shows adjustment breakdown: old premium (pro-rata remaining), new premium (pro-rata remaining), adjustment amount, IPT adjustment, commission adjustment
   - Manual rating option with reason field
   - Step 4: Review and confirm — submit creates the endorsement

2. **Endorsement approval** (for endorsement_pending policies):
   - Show endorsement details, changes diff, financial impact
   - "Approve" and "Reject" buttons (permission-gated to `endorsements:approve`)
   - Reject requires reason

3. **Cancellation form** (accessible from "Cancel" button):
   - Cancellation date picker
   - Reason text field (required)
   - Method selector: Pro-rata or Short Period
   - "Preview" button — shows return premium preview without committing
   - Return premium preview: return premium, return IPT, commission clawback (if applicable), net refund
   - Confirmation dialog before executing
   - Clawback warning if within clawback window

4. **Risk item editor**: Reusable component for editing risk items. Card-based layout — each risk item is a card with editable fields. "Add Item" and "Remove Item" buttons. Changes highlighted with yellow background.

### Acceptance criteria:
- Endorsement flow creates new version with changed risk items
- Premium adjustment calculated and displayed correctly
- Cancellation preview shows accurate return premium
- Clawback warning appears when applicable
- Both approve and reject workflows function
- Risk item editor preserves unchanged items
- All forms validate before submission
