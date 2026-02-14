# Insurance Broker Policy Administration System — Design (design.md)

**Target audience:** UK high-street insurance brokers (small brokers writing onto a binder)

**Delivery model:** Multi-tenant, cloud-hosted SaaS (UK data residency), priced at **£40 per user / month** (base tier)

**Purpose of this document**

This document captures a comprehensive set of *business-level* requirements for a UK cloud-hosted policy administration system targeted at high-street brokers who place business onto a binder. The scope emphasises broker-facing business functions rather than database schema or low-level implementation details. It covers regulatory and compliance needs (FCA, TCF, GDPR), policy lifecycle and versioning, IPID and documentation flows, issuance, complaints and claims notification, rate calculations (from binder/rating engines), emailing, simple accounting (premium, fee, commission, IPT), bordereaux outputs (premium & renewal), retail & commercial lines, reporting, billing and go-to-market considerations.

> **Notes & assumptions**
> - System will host customer and policy data in UK-located cloud infrastructure (to meet data-residency preferences and regulatory comfort).
> - "Binder" = delegated authority agreement / underwriting arrangement held by insurer or MGAs; the system must integrate with binder-provided rate logic and acceptance rules via APIs (or CSV/flat-file exchange where necessary).
> - This document is business-focused: it specifies what the system must do, user interactions, regulatory controls, flows and acceptance criteria. It intentionally avoids explicit physical data models.

---

## Table of contents

1. Executive summary
2. Goals and non-goals
3. Stakeholders and actors
4. High level product vision & pricing
5. Compliance & regulatory requirements
   - FCA
   - TCF
   - GDPR / Data protection
   - AML / KYC (high level)
6. Product scope — core business functions
   - Onboarding & KYC
   - Quoting & binder rate calculations
   - Policy creation, issuance & policy versions
   - IPID management and document generation
   - Endorsements, mid-term adjustments and cancellations
   - Claims notification
   - Complaints handling
   - Accounting (premium, fees, commission, IPT)
   - Bordereaux generation (premium and renewal)
   - Renewals & retention
   - Reporting & MI
   - Communication (email, document storage)
   - Integrations and automation
7. Functional requirements (detailed)
   - User roles & permissions
   - Policy lifecycle states
   - Binder integration patterns
   - Pricing/rate calculation rules
   - Document and correspondence requirements
   - Complaints and claims workflows
   - Accounting & invoice lifecycle
   - Bordereaux format requirements
   - Multi-line handling: retail vs commercial
   - Audit, logging and traceability
8. Non-functional requirements
   - Availability, scalability and performance
   - Security & encryption
   - Data residency & backups
   - Observability & supportability
   - Accessibility & UX
   - Localization & currency/tax
9. Privacy & DPIA considerations
10. Operational considerations & runbook excerpts
11. Data retention & disposal policy (business perspective)
12. Acceptances, test criteria and sample user stories
13. Edge cases and exceptions
14. Go-to-market, pricing and commercial considerations
15. Roadmap & feature prioritisation
16. Appendices
   - Sample bordereaux column lists
   - Example IPID fields & generation notes
   - Complaint log fields
   - Claims notification fields
   - Typical policy version examples and events

---

# 1. Executive summary

Small high-street brokers require a simple, compliant, and low-cost policy administration platform that supports placing with delegated binders. The product must remove manual Excel and email-heavy workflows, reduce compliance risk (FCA/TCF/GDPR), and automate routine tasks such as rate calculation from a binder, document issuance, bordereau generation and premium accounting. The target price point is **£40/user/month** which positions the product as affordable SaaS for local brokerages.

Key business benefits for customers:
- Fast quoting & binding using binder rate logic and acceptance checks.
- Audit-ready record-keeping for FCA & TCF obligations.
- Simplified accounts capture for premiums, fees, commission & IPT.
- Easy generation of premium and renewal bordereaux for onward submission.
- Built-in complaints and claims notification workflows.
- IPID and policy document generation for consumer-facing retail lines.

---

# 2. Goals and non-goals

## Goals
- Replace Excel/Word/email-based policy admin and bordereau production for high-street brokers.
- Ensure the product supports regulatory controls and record-keeping for FCA, TCF and GDPR.
- Allow brokers to quote, bind and issue policies against delegated binder terms with appropriate audit trails.
- Provide straightforward accounting features to capture premium, commission, fees, and IPT per policy and per transaction.
- Deliver configurable bordereaux exports (CSV/Excel) and renewal lists.
- Offer a low-cost, usable SaaS product priced at £40/user/month.

## Non-goals
- Not intended to be a full general ledger or complex accounting package.
- Not intended to replace insurer claims management platforms — only capture first notification and basic claims metadata.
- Not intended to provide underwriting authority itself. The binder holder remains the source of authority and rate logic.
- Not intended to provide complex actuarial modelling or capital modelling.

---

# 3. Stakeholders and actors

**Primary users**
- Broker user (broker admin, broker user): creates quotes, issues policies, handles customers, records receipts.
- Broker manager / owner: sees MI, subscribes to services, configures users and roles.
- Compliance officer (broker side): monitors complaints, tracks TCF outcomes.
- Claims handler (broker): records claims notifications, progresses external communication.

**Secondary users**
- Insurer/MGA binder administrator: provides binder terms, rates and receives bordereaux.
- Policyholder (customer): receives IPID, policy document, and invoices via email.
- Accountants: receive export data for reconciliation.

**System actors / integrations**
- Binder rating engine (API/CSV)
- Email provider (SMTP or transactional provider)
- Payment gateway (for broker to accept card payments if offered)
- Document store & e-sign provider
- AML/KYC provider
- Third-party accounting package (optional export)

---

# 4. High level product vision & pricing

Deliver a cloud-hosted, low-friction policy admin system for small brokers who place business onto delegated binders. A minimal fuss setup with prebuilt onboarding templates for common retail lines (motor, home, travel, pet) and common commercial classes (property owners, tradesman liability, small commercial combined).

**Pricing**
- Base: £40 / user / month — includes policy admin, document generation, bordereaux exports, basic accounting, email integration, and up to a modest number of binder rate API calls per month.
- Add-ons (examples):
  - Additional binder API call volumes, premium bordereaux automation, advanced MI dashboards, premium reconciliation automation, payment gateway.
  - SLA / premium support tier.

Bundle & trial options should be defined in go-to market section.

---

# 5. Compliance & regulatory requirements

This section captures the legal and regulatory requirements the product must support *from a business standpoint* (not a legal opinion). Final compliance decisions must be corroborated by legal/compliance teams.

## 5.1. FCA (Financial Conduct Authority)

High-level expectations:
- Maintain accurate, complete, and retrievable records of communications, quotes, policies, endorsements, cancellations, complaints and claims for at least the retention period mandated (default 6 years, configurable) and in a format suitable for regulatory review.
- Provide evidence of advice / explanation for insurances sold where advice is given. Capture that the broker has assessed suitability where applicable.
- Treating Customers Fairly (TCF) outcomes should be demonstrably met — record decisions, reasons, and customer communications.
- Complaints handling must comply with DISP (FCA Dispute Resolution rules) — logging, acknowledging, timescales, escalation to the Financial Ombudsman Service (FOS) where required.
- Transaction & audit logs showed who did what and when — for internal governance and FCA inspection.

Functional requirements related to FCA:
- All customer-facing communications (quote, IPID, policy documents) must be stored and retrievable for regulatory queries.
- Generate complaint logs that include date received, who logged it, dates of acknowledgements, outcome and whether FOS is involved.
- Configurable retention policy to match regulatory guidance (default 6 years for advice/sales records; longer if required).
- Exportable compliance packs for an account (PDF/zip) containing all records for a given basket of policies.

## 5.2. Treating Customers Fairly (TCF)

System must be capable of capturing and demonstrating the six TCF outcomes across sales and service activities (e.g. product design, customer understanding, product suitability, claim handling, etc.).

Requirements:
- TCF outcome checklists per sale that can be quickly completed and stored with the policy record.
- Timestamped evidence of customer acceptance for key documents (IPID, policy summary) where necessary.
- MI dashboard showing TCF KPIs (e.g., complaint rates, claim turnaround, customer churn) per broker.

## 5.3. GDPR / Data Protection (UK GDPR)

Key obligations to support brokers:
- Provide data subject rights support (DSARs): search, export, redact, and delete (where permitted). Keep an audit trail of DSAR responses.
- Data minimisation and purpose limitation: collect only necessary customer data, and allow brokers to configure retention policies.
- Consent & lawful basis management: capture the lawful basis for processing personal data (e.g., performance of contract), and document marketing consents separately.
- Breach notification support: identify personal data breaches, create incident records, and support notification to ICO and affected persons as required.

Functional requirements:
- Export personal data in machine-readable format (CSV/structured JSON) on request.
- Provide an admin UI for DSAR handling with templates and status tracking.
- Support fine-grained, role-based access controls for personal data.
- Full encryption-at-rest and in-transit.

## 5.4. AML / KYC (brief)

While AML regulation is often more relevant to financial money laundering control regimes, brokers should be able to capture basic KYC checks and identity evidence as part of onboarding. Provide integration points to third-party KYC providers and a place to store ID verification status.

---

# 6. Product scope — core business functions

This section enumerates the business functions the system must provide.

## 6.1. Onboarding & KYC

Business requirements:
- Broker admin can create a new customer (individual or corporate) with core details: name, addresses, contact info, tax identifiers, company number (if corporate), risk details.
- Capture whether customer is a retail consumer or commercial client (affects IPID and regulatory flows).
- Upload and store KYC evidence (ID documents, proof of address) and record KYC outcome (pass/require further checks).
- Customer interactions stored in timeline: quotes, communications, documents, claims, complaints.
- Data subject consent capture: marketing preferences and lawful basis.

Acceptance criteria:
- Creating a customer generates a unique customer reference and timeline entry.

## 6.2. Quoting & binder rate calculations

Business requirements:
- Broker can create a quote for a product defined by a binder. A binder product is a configuration that maps to insurer/MGA underwriting rules.
- Rate retrieval from binder: must support two patterns:
  1. **API-based** rate calculation: send quote payload to binder API and receive calculated premium and acceptance result.
  2. **Batch/flat-file**: upload a CSV/Excel and retrieve a rate or range.
- Support for variable rating bases per binder: per-risk (sum insured), per-vehicle, per-premises, per-GWP, etc.
- Support for additional fees, discounts, endorsements and commission splits.
- For retail products (consumer), system must generate and present IPID and key product information at quote stage.

Edge cases:
- Binder API returns error/unavailable — system should support retry, fallback to manual entry and log the exception for broker action.

## 6.3. Policy creation, issuance & policy versions

Business requirements:
- Policies have lifecycles: Draft -> Quoted -> Bound -> Issued -> In Force -> Endorsement Pending -> Endorsed -> Cancelled -> Lapsed -> Expired.
- Support policy versioning: each change (endorsement, mid-term adjustment, cancellation) creates a new policy *version* with reference to the prior version and a change summary.
- Keep full audit trail of who made changes, when, and why — including supporting documents and any signed authority.
- Issuance must generate policy documentation (policy schedule, certificate) and update accounting entries as required.
- For policies subject to binder conditions, any mid-term changes that affect rating must re-run binder rate calculation or record manual premium adjustment instructions to insurer.

Policy document requirements:
- Policy schedule with explicit version ID, effective dates, insured items, sums insured, premiums, fees, commission, IPT, and binder reference.
- Policy documents should contain a human-readable change log for the current version.

## 6.4. IPID management and document generation

Business requirements:
- IPID generation for consumer products: the system must store IPIDs provided by the insurer or allow creation of a broker-managed IPID template that is pre-approved.
- Associate IPID to quotes and policy versions; present to the customer at quotation stage and capture acknowledgement.
- Template-driven document generation: policy schedule, evidence of cover, invoice, renewal notice, IPID, and endorsement notices.
- Support for multi-language templates (English primary; potential later support for other languages).

## 6.5. Endorsements, mid-term adjustments and cancellations

Business requirements:
- Capture endorsement requests from broker or customer; create new policy version on approval.
- Capture reason codes for changes and whether the change was accepted by binder/insurer.
- Capture premium adjustments: additional premium, return premium, commission adjustments, IPT recalculation.
- Handle cancellations (pro rata, short-period rates) per binder instruction; produce cancellation documentation and update accounting lines.

## 6.6. Claims notification

Business requirements:
- Capture first notification of loss (FNOL) with required fields: date of loss, location, policy reference, claimant name, description, estimated loss, supporting documents and whether incident was reported to police.
- Allow claims to be linked to policies and policy versions; store claim status and claim handler notes.
- Provide templated confirmation email to customer acknowledging the claim notification.
- Optional integration point to insurer claims API (where available) to push FNOL directly.

## 6.7. Complaints handling

Business requirements:
- Centralised complaint log: date received, complainant, channel (phone/email/post), description, immediate actions, acknowledgment date, internal owner, outcome, remediation and whether FOS involved.
- SLA tracking and alerts when complaint response windows are breached.
- Exportable complaint pack for FCA or FOS submission.

## 6.8. Accounting: premium, fee, commission, IPT

Business requirements:
- Record financial components per policy: gross premium, fees (broker fees), commission rates and amounts, taxes (IPT), and net to insurer if relevant.
- Provide workflows for issuance invoicing, receipt of premiums, and basic reconciliation (manual match, import bank statement CSV to match receipts).
- Support commission structures: percentage-based commission, fixed commission, tiered commission, multiple payees (split commission between broker and introducer).
- Support commission clawback calculations on cancellations or mid-term adjustments.
- IPT calculation by class of business and tax rate (configurable, as rates may change). Keep a historical record of tax rates used for each policy.
- Provide exports for accountants (CSV) and summaries for insurer remittances.

**Important**: This is *not* a full accounts package — complex ledger postings remain outside scope, but export hooks should be built for integration with accounting software.

## 6.9. Bordereaux generation (premium and renewal)

Business requirements:
- Produce scheduled bordereaux files (CSV/Excel) per binder with configurable column mappings to insurer requirements.
- Two primary bordereaux types:
  - **Premium bordereau**: includes new business / adjustments / cancellations in a period with financial columns and policy references.
  - **Renewal bordereau**: list of upcoming renewals (policies due for renewal within a chosen period), grouped by binder/product, including renewal quotes or status.
- Support manual run and scheduled run (e.g., daily/weekly/monthly) and delivery via secure SFTP/email/insurer API.
- Validation rules before sending: required fields, totals reconcile, IPT & commission sums validate.
- Deliver status notifications (success/failure) and archive sent bordereaux with transmission logs.

## 6.10. Renewals & retention

Business requirements:
- Renewal batch processing: identify expiring policies, apply renewal rating (via binder), create renewal quote, send customer renewal notice and produce renewal bordereau.
- Keep renewal history and track whether the customer accepted renewal, switched insurer, cancelled or lapsed.
- Renewal acceptance capture: online acceptance or broker confirmation with audit trail.

## 6.11. Reporting & MI

Business requirements:
- Standard dashboards for brokers: policies in force, premium written (GWP), commission due, IPT collected, renewal pipeline, claims and complaint KPIs.
- Exportable reports (CSV/PDF) by date range, binder, product, and broker user.
- Custom report builder for ad-hoc extracts (limited to fields exposed by UI) to satisfy broker-specific needs.

## 6.12. Communication & emailing

Business requirements:
- Send transactional emails: quote, policy documents, invoices, renewal notices, claim/complaint acknowledgements.
- Store outbound and inbound email threads associated with customer records.
- Support email templates with merge tokens (customer name, policy ref, IPID link, attachments).
- Provide a letter/print-style document generator for offline mailing as required.

## 6.13. Integrations & automation

Targets for integration:
- Binder rating APIs (real-time or batch).
- Insurer API endpoints for bordereaux, FNOL, endorsement notifications.
- Email & transactional services.
- AML/KYC providers.
- Payment gateways (optional add-on) for direct premium collection or broker administration fees.
- Accounting software exports (Xero, QuickBooks) via CSV or connectors.

Automation:
- Scheduled jobs for bordereaux, renewals, overdue reminders, complaint SLA alerts and scheduled backups.

---

# 7. Functional requirements (detailed)

This section contains explicit, testable requirements grouped by business capability. Requirement IDs can be used for acceptance tests.

> **Note:** Each requirement should have acceptance criteria; we include them inline.

## 7.1. User roles & permissions

R-UR-001: The system shall support role-based access control with predefined roles: Broker Admin, Broker User, Compliance Officer, Claims Handler, Readonly Auditor.
- Acceptance: Admin can create roles and assign permissions. Users with Readonly Auditor cannot edit policy records.

R-UR-002: The system shall allow Broker Admin to invite users by email and set role and permissions; the invite shall be tracked against the account.
- Acceptance: Invite link expires after configurable time and shows who invited.

R-UR-003: The system shall support multi-factor authentication (MFA) for admin-level users.
- Acceptance: MFA enrolment and enforcement available.

## 7.2. Policy lifecycle and states

R-POL-001: The system shall implement policy states (Draft, Quoted, Bound, Issued, InForce, EndorsementPending, Endorsed, Cancelled, Lapsed, Expired).
- Acceptance: Policy transitions must be audited with timestamp, user and reason.

R-POL-002: The system shall maintain a version history for each policy; each version increments a version number and stores a change summary.
- Acceptance: User can view and compare two policy versions (side-by-side summary view).

R-POL-003: The system shall lock a policy from edition when it is in "Issued" state unless the user has an override permission.
- Acceptance: Edit attempts without permission are denied and logged.

## 7.3. Binder integration and rate calc

R-BND-001: The system shall allow broker admins to register binder configurations with metadata: binder ID, binder holder, accepted classes, rating API endpoint, field mapping, schedule frequency for bordereaux.
- Acceptance: Binder config saved and accessible to quotes.

R-BND-002: The system shall call binder rate APIs with validated payload and persist both request and response for audit.
- Acceptance: Stored payloads available for inspection and debugging.

R-BND-003: The system shall permit manual premium override by a user with permission; any override must be accompanied by a reason and approval (audit trail).
- Acceptance: Override saved and visible on the policy schedule and bordereaux.

R-BND-004: When binder API is unavailable, the system shall allow a manual rating workflow with mandatory documentation to support regulatory audit.
- Acceptance: Policy can be created with manual premium and marked as "Manual Rating".

## 7.4. Document generation and IPID

R-DOC-001: The system shall generate policy schedules, IPID, evidence of cover and invoices from templates.
- Acceptance: Generated doc contains policy ref, version ID, cover details and financial breakdown.

R-DOC-002: For retail consumer policies requiring IPID, the system shall present IPID at quote and record the customer's acknowledgement prior to binding.
- Acceptance: A quote cannot be bound for consumer product unless IPID acknowledged.

R-DOC-003: Document versions shall be stored and accessible; older versions may be exported as part of compliance packs.
- Acceptance: Exportable ZIP with docs and metadata for a policy.

## 7.5. Endorsements & cancellations

R-END-001: The system shall create an endorsement record referencing the parent policy version and describing change, effective date and financial impact.
- Acceptance: Endorsement creates a new version and updates bordereaux.

R-END-002: The system shall support cancellation processing with pro rata and short rate calculations configurable per binder rules.
- Acceptance: Cancellation generates cancellation schedule and accounting entries for return premium and commission adjustments.

R-END-003: Commission clawbacks shall be automatically calculated if a policy is cancelled within a defined clawback window, and expose reversals on the broker's commission ledger.
- Acceptance: Clawback calculation is visible on the policy's accounting tab.

## 7.6. Claims & FNOL

R-CLM-001: The system shall capture FNOL with required fields and create a unique claim reference linked to policy and policy version.
- Acceptance: FNOL creates a claim record and sends an acknowledgment email to the customer.

R-CLM-002: The system shall allow attaching documents (photos, police report, estimate) to a claim and track status changes.
- Acceptance: Files are stored securely and their upload is audited.

R-CLM-003: The system shall provide an integration point to push FNOL to insurer claims API where available.
- Acceptance: Push success/failure logged and visible in claim timeline.

## 7.7. Complaints

R-CMP-001: The system shall log complaints with all DISP-required fields and track time to acknowledge and time to final response.
- Acceptance: SLA alerts fire when response windows approach.

R-CMP-002: The system shall export complaint packs for FOS escalation with required supporting documents and communication history.
- Acceptance: Exported pack includes complaint timeline, policies, emails and outcome codes.

## 7.8. Accounting & financial flows

R-ACC-001: The system shall store the financial breakdown per policy and create accounting line items for: gross premium, broker fee(s), IPT, commission, insurer due.
- Acceptance: Financial breakdown shown on policy and included in bordereaux exports.

R-ACC-002: The system shall permit recording premium receipts and allocate receipts against invoice(s) and policies.
- Acceptance: User can mark invoice paid and the payment captured for reconciliation.

R-ACC-003: The system shall support commission splits and exports showing commission payable to parties.
- Acceptance: Commission split entries exported in CSV for payroll or accounts processing.

R-ACC-004: The system shall have the ability to flag and calculate IPT based on historic tax rate at the date of the transaction.
- Acceptance: IPT line shows tax rate used and source configuration.

## 7.9. Bordereaux

R-BOR-001: The system shall support configurable bordereau templates per binder with mapping of policy fields to required columns.
- Acceptance: Admin can create or edit mapping templates and preview data before export.

R-BOR-002: Bordereaux exports shall include checksums and validation reports showing records omitted or failing validation.
- Acceptance: Export contains validation summary and record counts.

R-BOR-003: The system shall schedule automatic bordereaux transmission and keep an audit log of deliveries and responses.
- Acceptance: Delivery logs visible with download and send timestamps.

## 7.10. Reporting & MI

R-MI-001: Implement standard dashboards: GWP by month, policies in force, renewals due in X days, claims per month, complaints per month, commission payable, IPT collected.
- Acceptance: Dashboard displays within 5 seconds for broker with up to 10k policies.

R-MI-002: Provide exportable reports for regulators and insurers.
- Acceptance: Reports downloadable in CSV and PDF formats.

## 7.11. Audit & traceability

R-AUD-001: All user actions that create, edit, or delete customer or policy data shall be logged with: user id, timestamp, IP, action, and reason (where applicable).
- Acceptance: Admin can query audit log by entity and time range.

R-AUD-002: The system shall store both request and responses for binder API interactions for at least 90 days accessible via UI (longer retention in archive).
- Acceptance: API call history accessible.

---

# 8. Non-functional requirements

## 8.1. Availability & SLA

- Target availability: **99.9%** for core policy admin functions (excludes scheduled maintenance windows).
- Planned maintenance windows communicated 7 days in advance for non-critical patches.
- Recovery time objective (RTO): 4 hours for core systems; Recovery point objective (RPO): 4 hours.

## 8.2. Performance

- Common operations (open policy, create quote, generate doc) should complete within 2–5 seconds under normal load for a single user.
- Batch operations (bordereaux generation for 100k rows) should complete within an operationally reasonable window (e.g., via background job with progress logging and notification).

## 8.3. Security

- All data must be encrypted in transit (TLS 1.2+). Encryption at-rest for sensitive fields.
- Role-based access control and administrative audit logs.
- Regular vulnerability scanning, penetration testing at least annually, and prompt patching of critical vulnerabilities.
- Compliance with secure coding standards and OWASP Top 10 mitigation.

## 8.4. Data residency & backups

- Primary data residency: UK.
- Backups: incremental daily backups retained for at least 30 days in hot storage, with configurable long-term archival (6–10 years) for compliance.
- Restore procedures, annual DR test and quarterly restore drills for key data.

## 8.5. Observability & supportability

- Central logging and metrics (request rates, error rates, background job health) with alerting thresholds.
- Support: ticketing system, knowledgebase, and in-app help. SLA-based response for premium customers.

## 8.6. Accessibility

- UI should meet WCAG 2.1 AA standards for accessibility where feasible.

---

# 9. Privacy & DPIA considerations

- Conduct a DPIA (Data Protection Impact Assessment) for broker data processing and for any high-risk automated decision making.
- Document lawful bases for processing (contract performance for policy administration; legitimate interest for fraud detection; consent for marketing).
- Provide a clear data processing addendum (DPA) for brokers to accept as part of onboarding.

---

# 10. Operational considerations & runbook excerpts (business view)

This section contains brief operational notes that broker users and support teams will find useful.

## 10.1. Onboarding runbook (short)
- Collect broker legal name, FCA number (if applicable), office contact, settlement bank details for commissions.
- Create account, add administrative users, configure license & subscription.
- Configure binders by uploading binder metadata and linking to binder API credentials.
- Run test submission, confirm rate responses and bordereaux mapping.

## 10.2. Incident handling (data loss or breach)
- Immediately escalate to product and security teams and create incident ticket.
- Broker support should notify affected customers and ICO within statutory timeframes (72 hours where possible) per DPA.
- Provide breach pack and remediation plan.

---

# 11. Data retention & disposal (business policy)

- Default retention: Sales and policy records — 7 years after expiry; complaints — 7 years after closure; claims-related records — 7 years after final settlement; financial records — 7 years in line with HMRC guidance.
- Retention must be configurable per-broker and aligned with legal requirements.
- Secure deletion workflows must be audited and reversible only via privileged processes for a limited period.

---

# 12. Acceptance tests & sample user stories

## 12.1. Sample user stories (prioritised)

**US-001 (High priority):** As a broker user I want to create a quote for a binder product and receive the rated premium so I can offer price to the customer.
- Acceptance: Quote payload is sent to binder API and response stored; if binder returns accept, quote shows premium and breakdown.

**US-002 (High priority):** As a broker user I want to bind a policy and issue policy documents so the customer has evidence of cover.
- Acceptance: Policy moves to Issued state, documents generated and emailed; accounting entries created.

**US-003:** As a compliance officer I want to export a compliance pack for a policy including all versioned docs and communications so I can respond to FCA review.
- Acceptance: Pack includes docs, email thread and audit entries.

**US-004:** As an accounts clerk I want to record a premium receipt and reconcile it to an invoice so we can prepare remittances.
- Acceptance: Receipt is recorded and invoice marked paid; exportable payment ledger available.

**US-005:** As a broker user I want to run the monthly premium bordereau for a binder and send it to the insurer by SFTP so the insurer receives the portfolio movement.
- Acceptance: Bordereau generated, validated and transmitted; delivery logged.

## 12.2. Acceptance test examples

- When creating a consumer quote, system should not permit binding until IPID acknowledgement is recorded.
- When a mid-term adjustment increases premium, commission and IPT must be recalculated taking historical commission rules into account.
- When a policy is cancelled within a clawback window, commission reversal calculation must appear in the commission ledger.

---

# 13. Edge cases and exceptions (business flows)

- Binder API returns multiple options or tiers — present options to the broker with explanation and require selection.
- Large sum insured commercial items requiring manual underwriting — route to manual underwriting queue with required documents and a deadline timer.
- Duplicate customer records — detect possible duplicates by matching name, DOB/company number and inform user when creating new record.
- Retroactive endorsements — require insurer/binder approval and visible evidence attached.

---

# 14. Go-to-market, pricing and commercial considerations

**Target customer:** small independent high-street brokerages and local broker chains, typically 1–30 users.

**Pricing model:**
- £40 / user / month base plan (core product).
- Optional add-ons: premium bordereau automation, payment gateway, higher SLA/support, additional binder API calls, advanced MI.

**Sales & distribution:**
- Direct sales (online self-serve for single-location brokers).
- Channel partners (accountants, broker associations) for introductions.
- Onboarding package includes configuration of up to N binders and templates; additional binder setups charged separately.

**Support & SLA:**
- Base support: business hours email with 48-hour response SLA.
- Premium support: 24/7 phone and 4-hour incident response for critical outages (add-on).

**Retention & churn metrics to monitor:**
- Monthly recurring revenue (MRR), churn rate, average revenue per user (ARPU), renewal rate, time to first binder integration, adoption by active users.

---

# 15. Roadmap & feature prioritisation (business view)

**MVP (0–3 months)**
- Core: customer, quote, binder API rating, bind & issue, basic IPID handling, policy versioning, document generation, basic bordereaux export, basic accounting lines (premium/fee/commission/IPT), user management, audit trail.

**Phase 2 (3–6 months)**
- Renewals automation, complaint handling workflow, claims FNOL capture, scheduled bordereaux, advanced templating, basic bank statement import for reconciliation, external integrations (payment, accounting export).

**Phase 3 (6–12 months)**
- Advanced MI dashboards, commission clawback automation, insurer API integrations for FNOL and endorsement notifications, subscription add-ons (payment gateway), advanced user permissioning, multi-language support.

**Later (12+ months)**
- Marketplace connectors for more insurers, deep accounting integration (Xero/QuickBooks plugins), mobile-first UI, advanced compliance pack builder.

---

# 16. Appendices

## Appendix A — Sample bordereaux column lists (premium bordereau)

Example minimal premium bordereau columns (custom mapping required per binder):
- Bordereau Reference
- Producer (Broker) Code
- Insurer/Binder Code
- Policy Number / Binder Policy Reference
- Policy Version
- Customer Name
- Customer Reference
- Class of Business (e.g., Retail Motor, Home, Tradesman)
- Product Code
- Effective Date (start)
- Expiry Date (end)
- Sum Insured
- Gross Premium
- IPT Amount
- Broker Fee
- Commission Rate (percent)
- Commission Amount
- Net Premium Payable to Insurer
- Transaction Type (New / Renewal / Adjustment / Cancellation)
- Transaction Date
- Cancellation Reason (if applicable)
- Reference to supporting document(s) (URL or doc ID)

## Appendix B — Renewal bordereau minimal columns
- Bordereau Reference
- Producer Code
- Policy Number
- Policy Version
- Customer Name
- Renewal Effective Date
- Renewal Premium (quoted)
- Expiry Date
- Renewal Status (pending/accepted/declined)
- Remarks

## Appendix C — Example IPID fields & notes
IPID must be short, clear and consumer-friendly. Common fields or summary sections:
- Product name & short description
- Name of insurer / underwriting company
- Significant benefits & restrictions
- Key exclusions
- Duration of contract and cancellation rights
- How to make a claim (quick steps)
- Complaints & FOS contact details
- Price / premium example or scenario (if required)

Notes: For consumer products ensure IPID is presented early in sales funnel and acknowledgement captured prior to binding.

## Appendix D — Complaint log fields
- Complaint ID
- Date Received
- Received By (channel)
- Complainant Name & policy ref
- Summary of complaint
- Immediate actions
- Date of acknowledgment to customer
- Owner (internal)
- Status
- Final decision & remediation
- Whether referred to FOS and dates
- Documents attached

## Appendix E — Claim notification / FNOL fields
- Claim ID
- Policy ref & version
- Date/time of loss
- Location of loss
- Claimant name and contact
- Brief description of events
- Estimated loss (if known)
- Reported to police (Y/N) & report number
- Preferred contact method
- Documents (photos, invoices)
- Claim handler notes & status history

## Appendix F — Typical policy version examples
1. Policy issued as version 1.0 — original schedule and premium.
2. Mid-term endorsement version 1.1 — change of vehicle; premium recalculated, commission adjusted.
3. Mid-term cancellation version 2.0 — short-period cancellation; return premium net of fees; commission clawback applied.
4. Renewal issued version 3.0 — new inception date and new premium.

---

# Closing notes for sellers & product owners

This document provides a robust business-level specification for a UK cloud-hosted broker policy administration system aimed at high-street brokers placing onto binders. It's intentionally comprehensive but should be validated by legal/compliance and sales teams prior to product development. Next recommended steps:
- Prioritise MVP features (see roadmap).
- Draft legal Data Processing Agreement and integrate with onboarding.
- Build standard binder integration templates and a small library of common retail product templates (home, motor, travel) to speed customer onboarding.
- Prepare a templated FCA compliance pack and a broker-facing knowledgebase for complaints, TCF and record keeping.

---

*Document prepared as a business-functional design. For implementation or architecture-level details (database design, cloud infra architecture, API contracts and message schemas), we recommend a follow-up technical design document.*

