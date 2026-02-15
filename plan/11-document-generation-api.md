# Step 11 — Document Generation & IPID API

## Goal
Build template-driven PDF document generation for policy schedules, evidence of cover, invoices, IPID documents, and a document storage/retrieval system.

## Prerequisites
- Steps 01–10 completed

---

## Prompt

You are building the document generation system for a UK insurance broker policy admin SaaS. The system needs to generate PDF documents from templates, store them in S3-compatible storage, and manage document versions.

### Schema context:
- `documents`: id, broker_id, policy_version_id, customer_id, document_type, file_name, storage_key, created_at, version_number, superseded_by
- `ipid_templates`: id, product_id, template_content, version, approved_by, approved_at, active, created_at
- `ipid_acknowledgements`: id, policy_version_id, acknowledged_at, acknowledged_by

### Files to create:

```
packages/api/src/
├── services/
│   ├── document.service.ts       # Document CRUD & storage
│   ├── document-generator.service.ts  # PDF generation from templates
│   ├── ipid.service.ts           # IPID template management
│   └── storage.service.ts        # S3-compatible file storage
├── routes/
│   ├── documents.ts              # Document routes
│   └── ipid.ts                   # IPID template routes
├── templates/
│   ├── policy-schedule.ts        # Policy schedule PDF template
│   ├── evidence-of-cover.ts      # Evidence of cover template
│   ├── invoice.ts                # Invoice PDF template
│   ├── renewal-notice.ts         # Renewal notice template
│   ├── cancellation-notice.ts    # Cancellation confirmation template
│   └── endorsement-notice.ts     # Endorsement confirmation template
```

### Requirements:

1. **Storage service** (`services/storage.service.ts`):
   - `uploadFile(key, buffer, contentType)`: Upload file to S3-compatible storage
   - `getSignedUrl(key, expiresIn?)`: Generate pre-signed download URL (default 1 hour expiry)
   - `deleteFile(key)`: Delete file from storage
   - Use AWS SDK v3 with S3 client. In dev, point to MinIO (local S3-compatible).
   - Storage keys follow pattern: `{brokerId}/documents/{year}/{documentId}.pdf`

2. **Document generator** (`services/document-generator.service.ts`):
   - Use PDFKit (or Carbone if template-based approach preferred) to generate PDFs
   - `generatePolicySchedule(policy, version, financials, customer, product)`: Generate policy schedule PDF containing:
     - Broker details, policy number, version number
     - Customer details
     - Product and binder info
     - Cover period (inception to expiry)
     - Risk items with sums insured
     - Financial breakdown (premium, fees, IPT, total)
     - Change log (for versions > 1)
   - `generateEvidenceOfCover(policy, version, customer, product)`: Shorter document confirming cover is in place
   - `generateInvoice(invoice, financials, customer, broker)`: Invoice PDF with line items
   - `generateRenewalNotice(policy, renewalQuote, customer)`: Renewal offer document
   - `generateCancellationNotice(policy, version, customer, returnPremium)`: Cancellation confirmation
   - `generateEndorsementNotice(policy, version, customer, changes)`: Endorsement confirmation

3. **Document service** (`services/document.service.ts`):
   - `createDocument(brokerId, data, fileBuffer)`: Upload file to storage, create document record. Set storage_key.
   - `getDocument(brokerId, documentId)`: Get document record with signed download URL.
   - `listDocuments(brokerId, filters)`: List documents with filters: policy_version_id, customer_id, document_type, date range.
   - `supersedDocument(brokerId, documentId, newDocumentId)`: Mark old document as superseded by new version.
   - `generateAndStoreDocument(brokerId, documentType, contextData)`: Generate PDF using appropriate template, upload, create record, return document with download URL.
   - `exportCompliancePack(brokerId, policyId)`: Generate ZIP file containing all documents for a policy across all versions, plus audit log entries as CSV. For FCA compliance review.

4. **IPID service** (`services/ipid.service.ts`):
   - `createTemplate(brokerId, productId, content, createdBy)`: Create new IPID template. Deactivate any existing active template for the product.
   - `approveTemplate(brokerId, templateId, approvedBy)`: Set approved_by and approved_at. Only approved templates can be used.
   - `getActiveTemplate(brokerId, productId)`: Get the active, approved IPID template for a product.
   - `listTemplates(brokerId, productId?)`: List IPID templates with version history.
   - `generateIpidPdf(brokerId, productId)`: Generate IPID as PDF from the active template content.

5. **Document routes** (`routes/documents.ts`):
   - `GET /api/documents` — list documents with filters (requires `documents:read`)
   - `GET /api/documents/:id` — get document with download URL (requires `documents:read`)
   - `GET /api/documents/:id/download` — redirect to signed download URL (requires `documents:read`)
   - `POST /api/documents/upload` — upload a document manually (requires `documents:upload`, multipart form)
   - `DELETE /api/documents/:id` — soft-delete document (requires `documents:delete`)
   - `POST /api/policies/:id/documents/generate` — generate document for policy (requires `documents:upload`)
     Body: `{ documentType: 'policy_schedule' | 'evidence_of_cover' | 'invoice' | ... }`
   - `GET /api/policies/:id/compliance-pack` — download compliance pack ZIP (requires `compliance:export`)

6. **IPID routes** (`routes/ipid.ts`):
   - `GET /api/products/:productId/ipid` — get active IPID template (requires `products:read`)
   - `GET /api/products/:productId/ipid/history` — IPID version history (requires `products:read`)
   - `POST /api/products/:productId/ipid` — create new IPID template (requires `products:manage`)
   - `POST /api/ipid/:templateId/approve` — approve template (requires `products:manage`)
   - `GET /api/ipid/:templateId/preview` — preview IPID as PDF (requires `products:read`)

7. **Document types enum** (add to shared types):
   `policy_schedule, evidence_of_cover, invoice, renewal_notice, cancellation_notice, endorsement_notice, ipid, claim_acknowledgement, complaint_acknowledgement, kyc_evidence, other`

### Acceptance criteria:
- Policy schedule PDF contains all required fields (policy ref, version, cover dates, financials)
- Documents are stored in S3 with signed URLs for secure access
- Document versioning tracks superseded documents
- IPID templates require approval before use
- Compliance pack ZIP contains all policy documents and audit trail
- Upload accepts common file types (PDF, DOCX, JPG, PNG)
- Storage keys are organised by broker for tenant isolation
