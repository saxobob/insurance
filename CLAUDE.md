# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

UK cloud-hosted insurance broker policy administration system (SaaS) for small high-street brokers placing business onto binders.

- **Target market**: Small independent brokerages (1-30 users)
- **Pricing**: £40/user/month base tier
- **Regulatory context**: FCA-regulated, must comply with TCF, GDPR, DISP
- **Data residency**: UK

## Key Documents

- `../design.md` - Comprehensive business requirements and functional specification (read this first for context)
- SQL schema files in `/db` - Multi-tenant PostgreSQL database schema

## Architecture Decisions

### Multi-Tenancy Strategy

**Schema-per-tenant approach** (not shared tables with RLS):
- Each broker gets their own PostgreSQL schema: `broker_<uuid>`
- Shared `meta` schema for cross-tenant tables (broker registry, system config)
- Connection-level `search_path` sets tenant context
- Defense-in-depth: application-level + schema isolation + RLS + audit logging

**Rationale**: Better isolation than single-schema RLS for FCA regulatory compliance while remaining operationally manageable at scale.

### Database: PostgreSQL

**Core entity relationships**:
```
Broker (tenant)
  └─ Offices (branches)
      └─ Users (employees)
  └─ Customers (policyholders)
  └─ Binders (underwriting arrangements)
      └─ Products
  └─ Policies
      └─ Policy Versions (full audit trail)
          └─ Policy Financials
          └─ Documents
  └─ Claims, Complaints, Renewals
```

**Critical tables**:
- `policy_versions` - Immutable version history, never update existing versions
- `policy_financials` - Separate table for premium/commission/IPT breakdown per version
- `audit_log` - Every mutation logged with user_id, timestamp, reason
- `tax_rates` - Historic IPT rates (rates change over time, must use rate active at transaction date)

**Financial flows**:
- Invoices → Receipts → Receipt Allocations (payment reconciliation)
- Commission Splits (multiple payees per policy)
- Commission Clawbacks (cancellation within clawback window)

### Regulatory Requirements

**FCA compliance considerations**:
- 7-year retention policy (configurable per broker)
- Complete audit trail: who did what, when, why
- IPID acknowledgement required before binding consumer policies
- Complaints must track DISP timescales (acknowledgement, final response)
- Bordereau validation before insurer transmission

**GDPR/Data protection**:
- Each broker is separate data controller
- DSAR (Data Subject Access Request) support required
- Lawful basis tracking per customer
- Marketing consent separate from contractual processing
- Secure deletion workflows with audit trail

**Key policy lifecycle states**:
Draft → Quoted → Bound → Issued → InForce → EndorsementPending → Endorsed → Cancelled/Lapsed/Expired

**Version-triggering events**:
- Endorsement (mid-term adjustment)
- Cancellation (with return premium calculation)
- Renewal (new policy period)

### Binder Integration Pattern

Brokers place business onto insurer/MGA binders (delegated authority arrangements).

**Rating flow**:
1. Capture quote details in UI
2. Call binder API with rating payload (or manual entry if API unavailable)
3. Store both request AND response in `policy_versions.rating_payload/rating_response`
4. Present premium breakdown to user
5. On bind: create policy, version, financials, documents

**Bordereau flow**:
1. Scheduled job (daily/weekly/monthly per binder config)
2. Extract policies/versions in period for binder
3. Validate against binder template rules
4. Generate CSV/Excel with insurer-specific column mapping
5. Transmit via SFTP/API
6. Log transmission in `bordereaux_runs` and link policies in `bordereaux_items`

## Security Considerations

**Tenant isolation enforcement**:
- Application layer MUST check `broker_id` on every query
- Database schema isolation as secondary defense
- RLS policies as tertiary defense
- Never use queries without tenant context

**Data encryption**:
- TLS 1.2+ in transit
- Encryption at rest for sensitive fields (consider pgcrypto for PII)
- Each broker could have separate encryption keys for additional isolation

**Access control**:
- Role-based permissions (roles → permissions → users)
- Multi-factor authentication for admin roles
- Audit log every permission check failure

## Business Domain Glossary

- **Binder**: Delegated underwriting authority from insurer/MGA to broker
- **Bordereau**: Periodic report of policies written, sent to insurer (premium bordereau = new business/adjustments/cancellations; renewal bordereau = upcoming renewals)
- **IPID**: Insurance Product Information Document (required for consumer insurance products under IDD)
- **IPT**: Insurance Premium Tax (UK tax on insurance premiums, rate varies by class of business)
- **FNOL**: First Notification of Loss (initial claim report)
- **DISP**: FCA's Dispute Resolution rules (governs complaints handling)
- **TCF**: Treating Customers Fairly (FCA principle, requires demonstrable outcomes)
- **GWP**: Gross Written Premium
- **Endorsement**: Mid-term policy change/adjustment

## Development Workflow Notes

**Schema migrations**:
- Migrations must run against ALL tenant schemas, not just `meta`
- Test migration rollback before deploying to production
- Track which schema version each tenant is on

**Testing tenant isolation**:
- Every integration test should verify cross-tenant queries are blocked
- Automated security tests should attempt cross-tenant access
- Mock different `broker_id` contexts in unit tests

**Bordereau validation rules**:
- Required fields per binder template (configured in `binders.bordereau_template_config`)
- Totals must reconcile (sum of premiums = sum of gross_premium from included policies)
- No duplicate policy versions in same bordereau run
- Transaction type must be valid (New/Renewal/Adjustment/Cancellation)

## Known Design Trade-offs

1. **Schema-per-tenant** scales to ~1000 brokers before operational overhead becomes significant. For larger scale, migrate largest brokers to dedicated database instances.

2. **JSONB for flexible data** (addresses, rating payloads) trades query performance for schema flexibility. Binders have different rating structures; JSONB avoids EAV anti-pattern.

3. **Immutable policy versions** mean storage grows with every endorsement. This is intentional for regulatory audit trail. Implement archival strategy for policies expired >7 years.

4. **Bordereau generation as scheduled batch job** rather than real-time. Insurers expect periodic submission; real-time would create operational burden on insurer side.

5. **Manual premium override** allowed with approval workflow (R-BND-003). Regulatory requirement for cases where binder API unavailable, but creates audit/compliance risk if misused.
