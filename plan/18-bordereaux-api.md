# Step 18 — Bordereaux Generation API

## Goal
Build configurable bordereau generation (premium and renewal), validation, CSV/Excel export, SFTP transmission, and scheduling.

## Prerequisites
- Steps 01–17 completed

---

## Prompt

You are building the bordereaux generation API for a UK insurance broker policy admin SaaS. Bordereaux are periodic reports of policy activity sent to insurers/MGAs. Each binder has specific column requirements.

### Schema context:
- `bordereaux_runs`: id, binder_id, run_type, period_start, period_end, file_name, status, created_at
- `bordereaux_items`: id, bordereau_run_id, policy_id, policy_version_id, included, validation_errors (JSONB), created_at
- Run types: `premium`, `renewal`
- Run statuses: `draft`, `validating`, `validated`, `generating`, `generated`, `transmitting`, `transmitted`, `failed`

### Files to create:

```
packages/api/src/
├── services/
│   ├── bordereau.service.ts      # Bordereau generation logic
│   ├── bordereau-validator.service.ts  # Validation rules
│   └── sftp.service.ts           # SFTP transmission
├── routes/
│   └── bordereaux.ts             # Bordereau routes
├── jobs/
│   └── bordereau.job.ts          # Scheduled bordereau generation
```

### Requirements:

1. **Bordereau service** (`services/bordereau.service.ts`):
   - `createRun(brokerId, binderId, runType, periodStart, periodEnd)`: Start a bordereau run:
     1. Validate binder exists and belongs to broker
     2. Check no overlapping run exists for same binder/type/period
     3. Create bordereaux_run with status='draft'
     4. Identify qualifying policy versions in the period:
        - Premium bordereau: new business, endorsements, cancellations with effective_date in period
        - Renewal bordereau: policies with expiry_date in period (upcoming renewals)
     5. Create bordereaux_items for each qualifying policy version
     6. Return run with item count

   - `validateRun(brokerId, runId)`: Validate all items:
     1. Set status to 'validating'
     2. For each item, check:
        - Required fields present (per binder template config)
        - Financial totals are consistent
        - No duplicate policy versions in same run
        - Transaction type is valid
     3. Store validation_errors in bordereaux_items (JSONB array)
     4. Set status to 'validated'
     5. Return validation summary (total items, valid, invalid, errors by type)

   - `excludeItem(brokerId, runId, itemId, reason)`: Exclude an item from the run (set included=false)
   - `includeItem(brokerId, runId, itemId)`: Re-include a previously excluded item

   - `generateFile(brokerId, runId)`: Generate the output file:
     1. Set status to 'generating'
     2. Build CSV/Excel with columns mapped per binder config
     3. Include only items where included=true AND no validation_errors
     4. Upload file to S3 storage
     5. Set file_name and status='generated'
     6. Return download URL

   - `transmitRun(brokerId, runId)`: Send to insurer:
     1. Set status to 'transmitting'
     2. If binder has SFTP config: upload via SFTP
     3. If binder has API endpoint: POST file
     4. Log transmission result
     5. Set status to 'transmitted' or 'failed'

   - `getRun(brokerId, runId)`: Get run with items, validation summary, file download URL
   - `listRuns(brokerId, filters, pagination)`: List runs with filters: binderId, runType, status, dateRange
   - `previewRun(brokerId, runId)`: Return first 20 rows of the bordereau as JSON for preview

2. **Column mapping** (binder configuration):
   Add a `bordereau_template_config` JSONB column to `binders` table (migration needed) containing:
   ```json
   {
     "premium": {
       "columns": [
         { "header": "Policy Number", "field": "policy.policy_number" },
         { "header": "Customer Name", "field": "customer.full_name" },
         { "header": "Gross Premium", "field": "financials.gross_premium" },
         ...
       ],
       "schedule": "monthly",
       "deliveryMethod": "sftp",
       "sftpHost": "...",
       "sftpPath": "..."
     },
     "renewal": { ... }
   }
   ```
   See Appendix A in design.md for sample premium bordereau columns.

3. **SFTP service** (`services/sftp.service.ts`):
   - `uploadFile(host, port, username, privateKey, remotePath, localBuffer)`: Upload file via SFTP
   - Use `ssh2-sftp-client` package
   - Handle connection errors, timeouts
   - Log all transmission attempts

4. **Scheduled job** (`jobs/bordereau.job.ts`):
   - For each binder with a schedule configured:
     - Determine period based on schedule (daily/weekly/monthly)
     - Auto-create run, validate, generate, and transmit
   - Run on cron schedule (configurable)
   - Send notification on success/failure (stub)

5. **Bordereau routes** (`routes/bordereaux.ts`):
   - `GET /api/bordereaux` — list runs (requires `bordereaux:read`)
   - `GET /api/bordereaux/:id` — get run detail (requires `bordereaux:read`)
   - `POST /api/bordereaux` — create manual run (requires `bordereaux:generate`)
     Body: `{ binderId, runType, periodStart, periodEnd }`
   - `POST /api/bordereaux/:id/validate` — validate run (requires `bordereaux:generate`)
   - `POST /api/bordereaux/:id/generate` — generate file (requires `bordereaux:generate`)
   - `POST /api/bordereaux/:id/transmit` — transmit to insurer (requires `bordereaux:transmit`)
   - `GET /api/bordereaux/:id/preview` — preview data (requires `bordereaux:read`)
   - `GET /api/bordereaux/:id/download` — download generated file (requires `bordereaux:read`)
   - `PUT /api/bordereaux/:id/items/:itemId/exclude` — exclude item (requires `bordereaux:generate`)
   - `PUT /api/bordereaux/:id/items/:itemId/include` — include item (requires `bordereaux:generate`)

### Acceptance criteria:
- Bordereau captures correct policies for the period
- Validation catches missing fields, duplicate entries, inconsistent totals
- Column mapping is configurable per binder
- Generated CSV matches binder's required format
- SFTP transmission connects and uploads (test with mock SFTP)
- Scheduled jobs auto-generate bordereaux per binder config
- No duplicate policy versions across bordereau runs for same period
- Excluded items don't appear in generated file
- All runs logged with file and transmission status
