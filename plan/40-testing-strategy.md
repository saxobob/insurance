# Step 40 — Testing Strategy

## Goal
Set up comprehensive testing: unit tests, integration tests with test database, E2E tests, and tenant isolation tests.

## Prerequisites
- Steps 01–39 completed (full application built)

---

## Prompt

You are setting up the testing infrastructure for a UK insurance broker policy admin SaaS. The application uses Fastify (backend), React (frontend), and PostgreSQL. Set up Vitest for unit/integration tests and Playwright for E2E tests.

### Files to create:

```
# Root
vitest.config.ts                  # Root Vitest config (workspaces)

# API tests
packages/api/
├── vitest.config.ts
├── tests/
│   ├── setup.ts                  # Test setup (DB connection, seed, cleanup)
│   ├── helpers/
│   │   ├── test-app.ts           # Create test Fastify instance
│   │   ├── test-db.ts            # Test database helpers
│   │   ├── test-auth.ts          # Generate test JWT tokens
│   │   └── fixtures.ts           # Test data factories
│   ├── unit/
│   │   ├── services/
│   │   │   ├── ipt.service.test.ts
│   │   │   ├── financial.service.test.ts
│   │   │   ├── cancellation.service.test.ts
│   │   │   └── policy-number.service.test.ts
│   │   └── lib/
│   │       ├── password.test.ts
│   │       ├── jwt.test.ts
│   │       └── pagination.test.ts
│   ├── integration/
│   │   ├── auth.test.ts
│   │   ├── customers.test.ts
│   │   ├── policies.test.ts
│   │   ├── quotes.test.ts
│   │   ├── endorsements.test.ts
│   │   ├── cancellations.test.ts
│   │   ├── claims.test.ts
│   │   ├── complaints.test.ts
│   │   ├── invoices.test.ts
│   │   ├── commissions.test.ts
│   │   ├── bordereaux.test.ts
│   │   └── renewals.test.ts
│   └── security/
│       ├── tenant-isolation.test.ts
│       └── permission-checks.test.ts

# Web tests
packages/web/
├── vitest.config.ts
├── tests/
│   ├── setup.ts
│   ├── components/
│   │   ├── data-table.test.tsx
│   │   ├── status-badge.test.tsx
│   │   └── premium-breakdown.test.tsx
│   └── hooks/
│       ├── use-auth.test.ts
│       └── use-permissions.test.ts

# E2E tests
e2e/
├── playwright.config.ts
├── tests/
│   ├── auth.spec.ts              # Login, MFA, logout
│   ├── customer-flow.spec.ts     # Create customer, view, edit
│   ├── quote-to-bind.spec.ts     # Full quoting flow
│   ├── endorsement-flow.spec.ts  # Mid-term adjustment
│   ├── cancellation-flow.spec.ts # Cancel with return premium
│   └── claim-flow.spec.ts        # Create FNOL, update status
├── fixtures/
│   └── test-data.ts              # E2E test data
└── helpers/
    └── page-objects.ts           # Page object models
```

### Requirements:

1. **Test database setup** (`tests/setup.ts`):
   - Create a test database (or use test schema) before test run
   - Run migrations
   - Seed minimal test data
   - Truncate tables between test suites (not between individual tests — use transactions)
   - Drop test database after test run
   - Each test file uses a transaction that rolls back after the test

2. **Test helpers**:
   - `createTestApp()`: Build Fastify instance for testing (inject requests, no network)
   - `createTestToken(overrides?)`: Generate valid JWT for test requests
   - `createTestBroker()`, `createTestUser()`, `createTestCustomer()`, `createTestPolicy()`: Factory functions for creating test entities with sensible defaults
   - All factories accept overrides for specific fields

3. **Unit tests** — Pure logic tests (no DB):
   - IPT calculation: correct rate lookup, rounding, edge cases
   - Financial calculations: commission, net to insurer, return premium (pro-rata and short-period)
   - Policy number generation: format, uniqueness
   - Password hashing: hash and verify
   - JWT: sign, verify, expired tokens
   - Pagination: parse query params, defaults, limits

4. **Integration tests** — Full request/response with DB:
   - **Auth**: login success/failure, MFA flow, token refresh, permission denial
   - **Customers**: CRUD, search, duplicate detection, validation (commercial needs company_name)
   - **Policies**: create quote → rate → bind → issue → activate lifecycle
   - **Endorsements**: create, rate, approve, reject, financial adjustment accuracy
   - **Cancellations**: pro-rata and short-period calculations, clawback triggering
   - **Claims**: FNOL creation, status transitions, date validation
   - **Complaints**: creation, SLA calculation, resolution
   - **Invoices**: creation, receipt allocation, status updates
   - **Commissions**: splits validation, clawback creation
   - **Bordereaux**: run creation, item identification, validation
   - **Renewals**: identification, quote generation, acceptance

5. **Tenant isolation tests** — Critical security tests:
   - Broker A cannot read Broker B's customers
   - Broker A cannot read Broker B's policies
   - Broker A cannot read Broker B's claims
   - Cross-tenant query attempts return 404 (not 403, to avoid information leakage)
   - Create two test brokers with data, verify complete isolation

6. **Permission tests**:
   - Each endpoint rejects requests without required permission (403)
   - Readonly Auditor cannot create/update/delete
   - Permission denial is logged to audit_log

7. **E2E tests** (Playwright):
   - Login flow (email + password → dashboard)
   - Create customer → verify in list
   - Full quote-to-bind flow (select customer → select product → enter risk → rate → acknowledge IPID → bind)
   - Endorsement flow (endorse policy → see new version)
   - Cancellation flow (cancel → see return premium)
   - Claim FNOL (create claim → update status)

8. **Package.json scripts**:
   - `test` — run all unit tests
   - `test:integration` — run integration tests (requires DB)
   - `test:e2e` — run E2E tests (requires running app)
   - `test:security` — run tenant isolation + permission tests
   - `test:coverage` — run with coverage report

### Acceptance criteria:
- Unit tests pass without any external dependencies
- Integration tests run against a test database
- Tenant isolation tests verify cross-tenant access is blocked
- E2E tests run the full user flows
- Test coverage > 80% for services, > 60% overall
- Tests complete within reasonable time (unit < 30s, integration < 2min, E2E < 5min)
