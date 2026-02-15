# Step 39 — Frontend: GDPR & Compliance Tools UI

## Goal
Build DSAR handling interface, audit log viewer, compliance pack export, and KYC status views.

## Prerequisites
- Steps 25–38 completed

---

## Prompt

You are building the GDPR and compliance tools pages for a UK insurance broker policy admin SaaS React frontend.

### Files to create:

```
packages/web/src/
├── routes/_app/settings/
│   ├── gdpr/
│   │   └── index.tsx             # DSAR management
│   ├── audit/
│   │   └── index.tsx             # Audit log viewer
│   └── compliance/
│       └── index.tsx             # Compliance tools hub
├── components/
│   └── compliance/
│       ├── dsar-table.tsx         # DSAR request list
│       ├── dsar-form.tsx          # Log new DSAR
│       ├── dsar-detail.tsx        # DSAR detail with actions
│       ├── audit-log-viewer.tsx   # Audit log table with filters
│       ├── audit-entity-history.tsx # History for specific entity
│       ├── compliance-pack.tsx    # Export compliance pack UI
│       └── kyc-status-panel.tsx   # KYC status on customer detail
```

### Requirements:

1. **DSAR management**: Table of DSAR requests with customer, request type, status, received date, due by (with overdue highlighting), handled by. "Log DSAR" button. Detail view with: process, complete, export data, redact data actions. Overdue counter at top.

2. **Audit log viewer**: Searchable, filterable table of audit entries. Filters: entity type, action, user, date range. Click entry → show full details (old/new values if available). Entity link navigates to that entity. Export filtered results as CSV.

3. **Entity history**: On any entity detail page (policy, customer, etc.), show "Audit History" tab or section. Lists all audit entries for that specific entity chronologically.

4. **Compliance pack export**: From policy detail page, "Export Compliance Pack" button. Shows progress as ZIP is generated. Downloads ZIP containing all documents, emails, and audit trail for the policy.

5. **KYC status panel** (on customer detail): Show KYC verification status (verified/pending/failed). List of checks with outcomes. "Record Check" button to add new check. Upload evidence documents.

### Acceptance criteria:
- DSAR tracking with 30-day deadline prominently displayed
- Overdue DSARs highlighted in red
- Audit log viewer performant with large datasets (server-side pagination)
- Compliance pack downloads as ZIP
- KYC status visible on customer pages
- All compliance tools permission-gated
