# Step 15 — Complaints Handling API

## Goal
Build FCA DISP-compliant complaints logging, SLA tracking, FOS escalation, and complaint pack export.

## Prerequisites
- Steps 01–14 completed

---

## Prompt

You are building the complaints handling API for a UK insurance broker policy admin SaaS. Complaints handling must comply with FCA DISP (Dispute Resolution) rules, which mandate specific timescales and record-keeping.

### Schema context:
- `complaints`: id, broker_id, customer_id, policy_id, received_at, channel, summary, acknowledged_at, resolved_at, outcome, fos_referred, owner_id, internal_notes, created_at

### DISP timescales:
- Acknowledge complaint: same business day or next business day
- Final response: within 8 weeks of receipt
- If not resolved in 8 weeks: must inform customer of right to refer to FOS

### Files to create:

```
packages/api/src/
├── services/
│   └── complaint.service.ts      # Complaint business logic
├── routes/
│   └── complaints.ts             # Complaint routes
├── jobs/
│   └── complaint-sla.job.ts      # SLA monitoring job
```

### Requirements:

1. **Complaint service** (`services/complaint.service.ts`):
   - `createComplaint(brokerId, userId, data)`: Log a complaint:
     1. Create complaint record with received_at, channel, summary
     2. Link to customer and/or policy if applicable
     3. Assign owner (internal complaint handler)
     4. Generate complaint reference: `CMP/{YEAR}/{SEQUENCE}`
     5. Add customer timeline entry
     6. Return created complaint
     Input: `{ customerId?, policyId?, receivedAt, channel: 'phone'|'email'|'post'|'in_person'|'online', summary, ownerId }`

   - `acknowledgeComplaint(brokerId, complaintId, userId)`: Record acknowledgement:
     1. Set acknowledged_at to now
     2. Generate acknowledgement email/letter (stub)
     3. Log action

   - `updateComplaint(brokerId, complaintId, updates)`: Update summary, internal_notes, owner_id. Log changes.

   - `resolveComplaint(brokerId, complaintId, userId, data)`: Resolve the complaint:
     1. Set resolved_at to now
     2. Set outcome (upheld, partially_upheld, rejected, resolved_to_satisfaction)
     3. Document remediation actions taken
     4. Generate final response letter (stub)
     5. Log resolution
     Input: `{ outcome, remediation?, finalResponseNotes }`

   - `referToFos(brokerId, complaintId, userId)`: Mark as referred to FOS:
     1. Set fos_referred = true
     2. Log FOS referral with date
     3. Add internal note

   - `getComplaint(brokerId, complaintId)`: Get complaint with customer info, policy info, timeline (from audit_log), SLA status
   - `listComplaints(brokerId, filters, pagination)`: List with filters:
     - `status` — open (resolved_at IS NULL), resolved, fos_referred
     - `customerId`, `policyId`, `ownerId`
     - `channel`
     - `receivedFrom/receivedTo` date range
     - `slaBreached` — filter to only SLA-breached complaints
   - `getComplaintStats(brokerId)`: Dashboard: open complaints, avg resolution time, SLA compliance %, FOS referral rate
   - `exportComplaintPack(brokerId, complaintId)`: Generate ZIP containing:
     - Complaint record as PDF
     - All related policy documents
     - All emails/communications with customer
     - Audit trail for the complaint
     - Outcome and remediation notes
     For FOS or FCA submission.

   - `getSlaStatus(complaint)`: Calculate SLA status:
     - `acknowledgementDue`: received_at + 1 business day
     - `acknowledgementBreached`: acknowledged_at is null AND now > acknowledgementDue
     - `finalResponseDue`: received_at + 8 weeks
     - `finalResponseBreached`: resolved_at is null AND now > finalResponseDue
     - `fosRightNotified`: if 8 weeks passed without resolution, customer must be told about FOS

2. **SLA monitoring job** (`jobs/complaint-sla.job.ts`):
   - Run daily (or more frequently)
   - Find complaints approaching SLA deadlines:
     - Acknowledgement due within 4 hours
     - Final response due within 1 week
   - Send alerts to complaint owners (stub — log for now)
   - Find complaints past 8-week deadline without resolution — flag for FOS notification

3. **Complaint routes** (`routes/complaints.ts`):
   - `POST /api/complaints` — create complaint (requires `complaints:create`)
   - `GET /api/complaints` — list with filters (requires `complaints:read`)
   - `GET /api/complaints/stats` — complaint statistics (requires `complaints:read`)
   - `GET /api/complaints/:id` — get complaint detail with SLA (requires `complaints:read`)
   - `PUT /api/complaints/:id` — update complaint (requires `complaints:update`)
   - `POST /api/complaints/:id/acknowledge` — acknowledge (requires `complaints:update`)
   - `POST /api/complaints/:id/resolve` — resolve complaint (requires `complaints:update`)
     Body: `{ outcome, remediation?, finalResponseNotes }`
   - `POST /api/complaints/:id/refer-fos` — refer to FOS (requires `complaints:update`)
   - `GET /api/complaints/:id/export` — download complaint pack ZIP (requires `complaints:export`)

4. **Outcome codes** (add to shared types):
   `upheld, partially_upheld, rejected, resolved_to_satisfaction`

5. **Channel codes**: `phone, email, post, in_person, online`

### Acceptance criteria:
- Complaint logging captures all DISP-required fields
- SLA calculations are accurate (acknowledgement within 1 business day, resolution within 8 weeks)
- SLA breaches are flagged and visible in the complaint list
- Complaint pack export includes all related documents and communications
- FOS referral is tracked with date
- Complaint stats show compliance rates
- All mutations logged to audit_log and customer timeline
- Complaint owner receives alerts for approaching SLA deadlines
