# Step 20 — Email System & Templates API

## Goal
Build transactional email sending with templates, merge tokens, delivery tracking, and email audit trail.

## Prerequisites
- Steps 01–19 completed

---

## Prompt

You are building the email system for a UK insurance broker policy admin SaaS. The system sends transactional emails (quote confirmations, policy documents, renewal notices, claim acknowledgements) using templates with merge tokens. All sent emails are stored for regulatory audit.

### Schema context:
- `emails`: id, broker_id, customer_id, policy_id, subject, sent_to, sent_at, body
- `email_templates`: id, broker_id (nullable=system template), template_name, subject_template, body_template, template_type, active, created_at

### Template types:
`quote_confirmation, policy_issued, renewal_notice, cancellation_notice, endorsement_notice, invoice, claim_acknowledgement, complaint_acknowledgement, payment_confirmation, welcome, password_reset, user_invitation`

### Files to create:

```
packages/api/src/
├── services/
│   ├── email.service.ts          # Email sending & recording
│   └── email-template.service.ts # Template management
├── routes/
│   ├── emails.ts                 # Email history routes
│   └── email-templates.ts        # Template admin routes
├── lib/
│   └── email-provider.ts         # SMTP/Resend provider abstraction
```

### Requirements:

1. **Email provider** (`lib/email-provider.ts`):
   - Abstract interface: `sendEmail(to, subject, htmlBody, attachments?): Promise<{ messageId, status }>`
   - Implement with Nodemailer (SMTP) as default
   - Optionally support Resend API as alternative provider
   - Config from env: `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`, `EMAIL_FROM`
   - In development: use Ethereal (fake SMTP) or just log emails

2. **Email template service** (`services/email-template.service.ts`):
   - `createTemplate(brokerId, data)`: Create broker-specific template. If broker_id is null, it's a system default.
   - `updateTemplate(brokerId, templateId, data)`: Update template content.
   - `getTemplate(brokerId, templateType)`: Get the active template for this type. Preference: broker-specific > system default.
   - `listTemplates(brokerId)`: List all templates (broker + system defaults).
   - `renderTemplate(template, mergeData)`: Replace merge tokens in subject and body:
     - Tokens use `{{tokenName}}` syntax
     - Available tokens: `{{customerName}}`, `{{policyNumber}}`, `{{premium}}`, `{{expiryDate}}`, `{{inceptionDate}}`, `{{productName}}`, `{{brokerName}}`, `{{invoiceNumber}}`, `{{invoiceTotal}}`, `{{claimReference}}`, `{{complaintReference}}`, `{{inviteUrl}}`, `{{resetUrl}}`
     - Use a simple string replacement (or Handlebars for more complex templates)
   - `previewTemplate(brokerId, templateId, sampleData)`: Render with sample data for preview
   - `deactivateTemplate(brokerId, templateId)`: Deactivate a template

3. **Email service** (`services/email.service.ts`):
   - `sendTemplatedEmail(brokerId, templateType, recipientEmail, mergeData, attachments?, customerId?, policyId?)`:
     1. Load template for broker
     2. Render subject and body with merge data
     3. Send via email provider
     4. Store in emails table with all details
     5. Add customer timeline entry if customerId provided
     6. Return sent email record
   - `sendRawEmail(brokerId, to, subject, body, attachments?, customerId?, policyId?)`: Send without template
   - `getEmail(brokerId, emailId)`: Get sent email record
   - `listEmails(brokerId, filters, pagination)`: List with filters:
     - `customerId`, `policyId`, `templateType`, `dateFrom/dateTo`, `search` (subject/recipient)
   - `resendEmail(brokerId, emailId)`: Resend a previously sent email
   - `getEmailsForCustomer(brokerId, customerId)`: All emails for a customer (for timeline)
   - `getEmailsForPolicy(brokerId, policyId)`: All emails for a policy (for compliance pack)

4. **Seed system default templates** (add to seed data):
   Create default templates for each template type with professional, insurance-appropriate content. Include merge tokens.

5. **Email routes** (`routes/emails.ts`):
   - `GET /api/emails` — list sent emails (requires `audit:read`)
   - `GET /api/emails/:id` — get email detail (requires `audit:read`)
   - `POST /api/emails/:id/resend` — resend email (requires `policies:update`)
   - `POST /api/emails/send` — send ad-hoc email (requires `policies:update`)
     Body: `{ customerId?, policyId?, to, subject, body, attachments? }`

6. **Template routes** (`routes/email-templates.ts`):
   - `GET /api/email-templates` — list templates (requires `settings:read`)
   - `GET /api/email-templates/:id` — get template (requires `settings:read`)
   - `POST /api/email-templates` — create template (requires `settings:manage`)
   - `PUT /api/email-templates/:id` — update template (requires `settings:manage`)
   - `DELETE /api/email-templates/:id` — deactivate template (requires `settings:manage`)
   - `POST /api/email-templates/:id/preview` — preview with sample data (requires `settings:read`)
     Body: `{ sampleData: Record<string, string> }`

### Acceptance criteria:
- Emails render templates with merge tokens correctly
- Broker-specific templates override system defaults
- All sent emails stored in DB for audit/compliance
- Email history viewable per customer and per policy
- Templates support HTML content with professional formatting
- Development mode logs emails instead of sending
- Attachments (e.g., policy schedule PDF) can be included
- Template preview shows rendered output with sample data
