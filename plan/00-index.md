# Insurance Broker Policy Admin System — Build Plan

## Tech Stack

| Layer | Choice | Why |
|-------|--------|-----|
| **Frontend** | React 19 + TypeScript + Vite | Fast DX, ecosystem maturity |
| **UI Kit** | shadcn/ui + Tailwind CSS + Radix | Beautiful, accessible, customisable — "snazzy" without a framework lock-in |
| **Routing** | TanStack Router | Type-safe, file-based routing with loaders |
| **State/Data** | TanStack Query (React Query) | Server-state caching, mutations, optimistic updates |
| **Forms** | React Hook Form + Zod | Performant forms with schema validation |
| **Tables** | TanStack Table | Sorting, filtering, pagination for data-heavy views |
| **Backend** | Node.js + TypeScript + Fastify | Faster than Express, built-in validation, great plugin system |
| **ORM** | Drizzle ORM | SQL-first, lightweight, excellent TypeScript inference |
| **Database** | PostgreSQL 18 | Already designed; schema-per-tenant multi-tenancy |
| **Auth** | Lucia Auth + oslo (or custom JWT) | Session-based auth with MFA support |
| **Email** | Resend (or Nodemailer + SMTP) | Transactional email with templates |
| **File Storage** | S3-compatible (MinIO local, AWS S3 prod) | Document storage with signed URLs |
| **Doc Generation** | PDFKit or Carbone | Template-driven PDF generation |
| **Jobs** | BullMQ + Redis | Scheduled jobs (bordereaux, renewals, reminders) |
| **Monorepo** | pnpm workspaces + Turborepo | Shared types, fast builds |
| **Testing** | Vitest + Playwright | Unit/integration + E2E |

---

## Step Index

### Foundation & Infrastructure (Steps 01–05)

| # | File | Summary |
|---|------|---------|
| 01 | [01-project-scaffolding.md](01-project-scaffolding.md) | Monorepo setup, pnpm workspaces, Turborepo, shared tsconfig, ESLint, Prettier |
| 02 | [02-database-setup.md](02-database-setup.md) | Drizzle schema, migrations, tenant provisioning scripts, seed data |
| 03 | [03-backend-api-foundation.md](03-backend-api-foundation.md) | Fastify server, plugin structure, tenant middleware, error handling, request logging |
| 04 | [04-authentication.md](04-authentication.md) | Login, session management, JWT tokens, MFA enrolment/verification, password hashing |
| 05 | [05-rbac-permissions.md](05-rbac-permissions.md) | Roles, permissions, middleware guards, permission seeding, user invitations |

### Core Domain — Backend APIs (Steps 06–15)

| # | File | Summary |
|---|------|---------|
| 06 | [06-customer-management-api.md](06-customer-management-api.md) | Customer CRUD, search, duplicate detection, timeline, GDPR lawful basis |
| 07 | [07-binder-product-api.md](07-binder-product-api.md) | Binder configuration CRUD, product management, binder API credential storage |
| 08 | [08-quoting-rating-api.md](08-quoting-rating-api.md) | Quote creation, binder API rating calls, manual rating fallback, IPID gate |
| 09 | [09-policy-lifecycle-api.md](09-policy-lifecycle-api.md) | Policy CRUD, status transitions, version creation, policy number generation |
| 10 | [10-policy-financials-api.md](10-policy-financials-api.md) | Premium breakdown, IPT calculation with historic rates, broker fees |
| 11 | [11-document-generation-api.md](11-document-generation-api.md) | PDF templates, policy schedule, evidence of cover, IPID generation, storage |
| 12 | [12-endorsements-api.md](12-endorsements-api.md) | Mid-term adjustments, new version creation, premium recalculation, re-rating |
| 13 | [13-cancellations-api.md](13-cancellations-api.md) | Pro-rata/short-period calculation, return premium, cancellation documents |
| 14 | [14-claims-fnol-api.md](14-claims-fnol-api.md) | FNOL capture, claim status workflow, document attachments, insurer push |
| 15 | [15-complaints-api.md](15-complaints-api.md) | DISP-compliant logging, SLA tracking, FOS escalation, complaint packs |

### Financial & Operational — Backend APIs (Steps 16–24)

| # | File | Summary |
|---|------|---------|
| 16 | [16-invoicing-receipts-api.md](16-invoicing-receipts-api.md) | Invoice generation, receipt recording, allocation, reconciliation |
| 17 | [17-commission-api.md](17-commission-api.md) | Commission splits, multiple payees, clawback calculation, ledger exports |
| 18 | [18-bordereaux-api.md](18-bordereaux-api.md) | Template mapping, validation, CSV/Excel generation, SFTP transmission, scheduling |
| 19 | [19-renewals-api.md](19-renewals-api.md) | Expiry detection, renewal quote generation, customer notifications, acceptance |
| 20 | [20-email-system-api.md](20-email-system-api.md) | Email templates, merge tokens, send/track, inbound storage, audit trail |
| 21 | [21-audit-log-api.md](21-audit-log-api.md) | Automatic mutation logging middleware, query/filter UI API, retention |
| 22 | [22-kyc-checks-api.md](22-kyc-checks-api.md) | KYC record CRUD, provider integration stub, evidence storage |
| 23 | [23-gdpr-dsar-api.md](23-gdpr-dsar-api.md) | DSAR request handling, data export, redaction, secure deletion, audit |
| 24 | [24-reporting-mi-api.md](24-reporting-mi-api.md) | Dashboard aggregation queries, GWP, policy counts, claims/complaints KPIs, CSV/PDF export |

### Frontend (Steps 25–39)

| # | File | Summary |
|---|------|---------|
| 25 | [25-frontend-scaffolding.md](25-frontend-scaffolding.md) | Vite + React + TanStack Router, shadcn/ui install, Tailwind theme, layout shell, auth flow |
| 26 | [26-fe-dashboard.md](26-fe-dashboard.md) | KPI cards, charts (Recharts), recent activity feed, renewal alerts |
| 27 | [27-fe-customers.md](27-fe-customers.md) | Customer list (data table), customer detail page, timeline tab, create/edit forms |
| 28 | [28-fe-binders-products.md](28-fe-binders-products.md) | Binder list, binder detail with products, create/edit binder & product forms |
| 29 | [29-fe-quoting.md](29-fe-quoting.md) | Multi-step quote wizard, binder selection, risk capture, rating call, IPID acknowledgement, premium display |
| 30 | [30-fe-policies.md](30-fe-policies.md) | Policy list with filters, policy detail with version tabs, status badge, timeline |
| 31 | [31-fe-policy-financials-docs.md](31-fe-policy-financials-docs.md) | Financial breakdown tab, document list with download, version comparison |
| 32 | [32-fe-endorsements-cancellations.md](32-fe-endorsements-cancellations.md) | Endorsement form, cancellation form, premium adjustment display, approval flow |
| 33 | [33-fe-claims-complaints.md](33-fe-claims-complaints.md) | Claims list & FNOL form, complaints list & log form, SLA indicators |
| 34 | [34-fe-invoicing-receipts.md](34-fe-invoicing-receipts.md) | Invoice list, receipt recording, allocation modal, reconciliation view |
| 35 | [35-fe-commissions.md](35-fe-commissions.md) | Commission splits table, clawback alerts, ledger export |
| 36 | [36-fe-bordereaux-renewals.md](36-fe-bordereaux-renewals.md) | Bordereau runs list, preview/validate, renewals pipeline view |
| 37 | [37-fe-reporting.md](37-fe-reporting.md) | MI dashboards, report builder, CSV/PDF export controls |
| 38 | [38-fe-admin-settings.md](38-fe-admin-settings.md) | User management, role/permission editor, email template editor, tax rate config, broker settings |
| 39 | [39-fe-gdpr-compliance.md](39-fe-gdpr-compliance.md) | DSAR handling UI, audit log viewer, compliance pack export, KYC status view |

### Testing & Deployment (Steps 40–41)

| # | File | Summary |
|---|------|---------|
| 40 | [40-testing-strategy.md](40-testing-strategy.md) | Vitest unit tests, integration tests with test DB, Playwright E2E, tenant isolation tests |
| 41 | [41-deployment-cicd.md](41-deployment-cicd.md) | Docker, docker-compose, GitHub Actions CI/CD, environment config, migration strategy |

---

## How to Use These Prompts

Each step file contains a **self-contained prompt** you can feed to Claude (Haiku or Sonnet) to build that step. The prompts:

1. Reference the existing `schema.sql`, `design.md`, and `CLAUDE.md` for context
2. Specify exact files to create and their locations
3. Include acceptance criteria so you can verify the output
4. Build on previous steps (run them in order)

**Workflow:**
1. Complete steps in order (each builds on the last)
2. Copy the prompt from the step file into a new Claude session
3. Review and test the output before moving to the next step
4. If a step is too large, the prompt is designed to be splittable at the `---` section breaks
