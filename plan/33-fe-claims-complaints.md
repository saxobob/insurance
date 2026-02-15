# Step 33 — Frontend: Claims & Complaints Pages

## Goal
Build claims FNOL form, claims list, complaints log, and SLA tracking views.

## Prerequisites
- Steps 25–30 completed

---

## Prompt

You are building the claims and complaints pages for a UK insurance broker policy admin SaaS React frontend.

### Files to create/modify:

```
packages/web/src/
├── routes/_app/
│   ├── claims/
│   │   ├── index.tsx             # Claims list
│   │   └── $claimId.tsx          # Claim detail
│   └── complaints/
│       ├── index.tsx             # Complaints list
│       └── $complaintId.tsx      # Complaint detail
├── hooks/
│   ├── use-claims.ts
│   └── use-complaints.ts
├── components/
│   ├── claims/
│   │   ├── claim-table.tsx        # Claims data table
│   │   ├── fnol-form.tsx          # FNOL capture form
│   │   ├── claim-detail.tsx       # Claim detail layout
│   │   ├── claim-notes.tsx        # Handler notes timeline
│   │   └── claim-status-flow.tsx  # Claim status stepper
│   └── complaints/
│       ├── complaint-table.tsx    # Complaints data table with SLA indicators
│       ├── complaint-form.tsx     # Log complaint form
│       ├── complaint-detail.tsx   # Complaint detail layout
│       ├── sla-indicator.tsx      # SLA countdown/breach indicator
│       └── complaint-resolve-form.tsx # Resolution form
```

### Requirements:

1. **Claims list**: Table with claim ref, policy number, customer, date of loss, status badge, estimated loss, handler, created. Filter by status, handler, date range. Search.

2. **FNOL form**: Policy selector (search by policy number), date of loss (date picker), description (textarea), estimated loss (currency input), police reported (checkbox), handler assignment (user selector). Validate date of loss is within policy cover period.

3. **Claim detail**: Header with claim ref, status badge, policy link. Tabs: overview (claim info + policy info), notes (handler notes timeline with add note form), documents (attached files with upload), status history. Status transition buttons based on current status.

4. **Complaints list**: Table with complaint ref, customer, channel badge, received date, SLA status (green/amber/red indicator), owner, status. Filter by status (open/resolved/FOS), channel, SLA status. SLA column shows: days remaining or "BREACHED" in red.

5. **Complaint form**: Customer selector, policy selector (optional), channel (select), received date, summary (textarea), owner assignment.

6. **Complaint detail**: Header with ref, SLA countdown prominently displayed. Tabs: overview, timeline (actions taken), documents. Action buttons: Acknowledge, Resolve, Refer to FOS. Resolution form: outcome (select), remediation notes, final response.

7. **SLA indicator component**: Visual indicator:
   - Green: > 5 days remaining
   - Amber: 1-5 days remaining
   - Red: breached (past deadline)
   - Show days remaining or days overdue
   - Two SLA tracks: acknowledgement (1 business day) and final response (8 weeks)

### Acceptance criteria:
- FNOL form validates date of loss against policy period
- Claims status transitions work with handler notes
- Complaints SLA indicators show correct countdown
- Breached SLAs highlighted prominently in red
- Resolution form captures DISP-required outcome fields
- FOS referral tracked and visible
- Document attachments work for both claims and complaints
