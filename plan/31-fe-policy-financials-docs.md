# Step 31 — Frontend: Policy Financials & Documents UI

## Goal
Build the financials tab and documents tab on the policy detail page.

## Prerequisites
- Step 30 completed

---

## Prompt

You are building the policy financials and documents tabs for a UK insurance broker policy admin SaaS React frontend.

### Files to create:

```
packages/web/src/
├── components/
│   └── policies/
│       ├── financials-tab.tsx     # Financial breakdown display
│       ├── financial-history.tsx  # Financial history across versions
│       ├── premium-card.tsx       # Premium breakdown card
│       ├── documents-tab.tsx      # Document list with actions
│       ├── document-upload.tsx    # Upload document modal
│       └── document-viewer.tsx    # PDF viewer modal
```

### Requirements:

1. **Financials tab**:
   - Current version financial breakdown card:
     - Gross Premium, Broker Fee, IPT (rate + amount), Commission (rate + amount), Net to Insurer, Total Payable
     - Formatted as currency with labels
   - Financial history table across all versions: version number, transaction type, gross premium, IPT, commission, adjustment amount, date
   - Visual: bar chart showing premium over versions (if multiple)
   - Commission splits section: show payees, rates, amounts
   - Clawback alert: if there's a clawback, show red warning with amount

2. **Documents tab**:
   - Table: Document Type (badge), Filename, Version, Created Date, Actions (download, view, delete)
   - "Upload Document" button → upload modal (file picker, document type select)
   - "Generate Document" dropdown: Policy Schedule, Evidence of Cover, Invoice
   - Click filename → open PDF viewer modal (if PDF)
   - Download button → signed URL download
   - Superseded documents shown in gray with "superseded" label

3. **PDF viewer**: Modal with embedded PDF viewer using `<iframe>` or react-pdf. Full-screen option.

### Acceptance criteria:
- Financial breakdown shows all components accurately
- Financial history shows changes across versions
- Documents list with download working via signed URLs
- Document upload accepts PDF, DOCX, JPG, PNG
- Generate document triggers backend and shows new document
- PDF viewer displays documents inline
