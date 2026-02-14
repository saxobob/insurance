# Insurance Broker Policy Administration System

A cloud-hosted, multi-tenant SaaS platform for small UK high-street insurance brokers to manage policy administration, compliance, and accounting workflows.

## Overview

This system enables independent brokers to move away from Excel and email-based workflows by providing:

- **Policy management** - Quote, bind, issue, and manage policy versions with full audit trails
- **Binder integration** - Rate quotes against insurer/MGA binder APIs and automate acceptance checks
- **Compliance** - FCA-ready record-keeping, TCF outcome tracking, GDPR data subject rights support
- **Financial management** - Premium accounting, commission splits, clawbacks, IPT calculation and historic rate tracking
- **Bordereaux generation** - Automated premium and renewal reporting to insurers
- **Claims & complaints** - FNOL capture and DISP-compliant complaints handling
- **Reporting** - MI dashboards and exportable reports by broker, office, binder, and product

## Target Market

- Small independent high-street brokerages
- Local broker chains (1-30 users per broker)
- Brokers placing business onto delegated authority binders

## Pricing

**Base tier**: £40/user/month (includes core policy admin, IPID handling, bordereaux, accounting, email)

**Add-ons**: Higher API quotas, premium support, advanced MI, payment gateway integration

## Documentation

- **[design.md](./design.md)** - Comprehensive business and functional requirements (start here)
- **[CLAUDE.md](./CLAUDE.md)** - Architecture and development guidance for contributors

## Regulatory Context

This system must support compliance with:

- **FCA** - Record-keeping, audit trails, transaction logging, regulatory reporting
- **TCF** (Treating Customers Fairly) - Demonstrable customer outcomes at each stage
- **DISP** - Dispute resolution and complaints handling timescales
- **GDPR** - Data subject rights, consent management, data protection impact assessments
- **IDD** - Insurance Product Information Document (IPID) requirements for consumer products
- **IPT** - Insurance Premium Tax calculation and historic rate management

## Technical Stack

- **Database**: PostgreSQL (multi-tenant, schema-per-tenant architecture, UK data residency)
- **Backend**: (TBD - to be specified in technical design document)
- **Frontend**: (TBD - to be specified in technical design document)
- **Deployment**: Cloud-hosted UK infrastructure (AWS/Azure/GCP with UK region)

## Multi-Tenancy Model

Each broker is a separate tenant with:
- Dedicated PostgreSQL schema (`broker_<uuid>`)
- Isolated customer, policy, and financial data
- Role-based access control per user
- Optional office/branch structure for regional management

Security achieved through:
- Schema isolation at database level
- Row-level security (RLS) policies
- Application-level tenant context enforcement
- Comprehensive audit logging

## Getting Started

1. Read [design.md](./design.md) for business requirements
2. Read [CLAUDE.md](./CLAUDE.md) for technical architecture
3. Review the database schema (in `/db` directory when available)
4. Set up development environment (instructions coming soon)

## Project Status

**Current Phase**: Design & specification (business requirements complete, technical architecture in progress)

- ✅ Business requirements (design.md)
- ✅ Database schema design
- ⏳ Backend implementation
- ⏳ Frontend implementation
- ⏳ Binder integration patterns
- ⏳ Testing & QA
- ⏳ Regulatory compliance validation

## Key Design Decisions

1. **Schema-per-tenant** PostgreSQL for better isolation than row-level security
2. **Immutable policy versions** to maintain complete audit trail
3. **Separate financials table** to handle complex commission splits and historical rate tracking
4. **JSONB for flexible data** to accommodate different binder rating structures
5. **Scheduled bordereaux batches** rather than real-time submission

See [CLAUDE.md](./CLAUDE.md) for detailed rationale.

## Data & Compliance

- **Data residency**: UK
- **Retention**: 7 years default (configurable per broker, aligned with FCA/HMRC requirements)
- **Encryption**: TLS 1.2+ in transit, encryption at rest for sensitive fields
- **Backups**: Daily incremental, 30-day hot retention, configurable archival
- **Audit logging**: Every data mutation with user, timestamp, IP, and reason

## Support & Contributing

This is an early-stage project. For questions or contributions, see CLAUDE.md.

---

*Insurance Broker Policy Administration System - UK SaaS for high-street brokers*
