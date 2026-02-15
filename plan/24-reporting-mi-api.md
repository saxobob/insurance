# Step 24 — Reporting & MI API

## Goal
Build dashboard aggregation queries, standard reports, and CSV/PDF export for management information.

## Prerequisites
- Steps 01–23 completed

---

## Prompt

You are building the reporting and management information (MI) API for a UK insurance broker policy admin SaaS. Brokers need dashboards showing key metrics and exportable reports for management and regulatory purposes.

### Files to create:

```
packages/api/src/
├── services/
│   └── reporting.service.ts      # Report queries & generation
├── routes/
│   └── reports.ts                # Reporting routes
```

### Requirements:

1. **Reporting service** (`services/reporting.service.ts`):
   - `getDashboardMetrics(brokerId)`: Real-time dashboard KPIs:
     - Policies in force (count)
     - GWP (total gross written premium for current year)
     - Commission earned (current year)
     - IPT collected (current year)
     - Renewals due next 30 days (count + premium)
     - Open claims (count)
     - Open complaints (count + SLA compliance %)
     - Overdue invoices (count + total amount)

   - `getGwpReport(brokerId, dateFrom, dateTo, groupBy)`: GWP breakdown:
     - Group by: month, product, binder, class_of_business
     - Include: new business, endorsements, cancellations, net GWP
     - Return as time series for charting

   - `getPolicyReport(brokerId, dateFrom, dateTo)`: Policy activity:
     - New policies by month
     - Cancellations by month
     - Policies by status
     - Policies by product/binder
     - Average premium

   - `getFinancialReport(brokerId, dateFrom, dateTo)`: Financial summary:
     - Revenue: broker fees + commission
     - Premium flow: gross premium → IPT → commission → net to insurer
     - Outstanding debt: invoices unpaid, aging breakdown
     - Receipts by payment method

   - `getRenewalReport(brokerId, dateFrom, dateTo)`: Renewal performance:
     - Renewal rate (accepted / total due)
     - Premium retention (renewal premium / expiring premium)
     - Declined reasons breakdown
     - Pipeline by status

   - `getClaimsReport(brokerId, dateFrom, dateTo)`: Claims MI:
     - Claims by status, by product
     - Average time to acknowledge
     - Total estimated losses
     - Claims frequency (claims / policies in force)

   - `getComplaintsReport(brokerId, dateFrom, dateTo)`: Complaints MI:
     - Complaints by channel, by outcome
     - SLA compliance rate (acknowledged in time, resolved in time)
     - FOS referral rate
     - Average resolution time

   - `getCommissionReport(brokerId, dateFrom, dateTo)`: Commission breakdown:
     - By payee, by product, by binder
     - Clawbacks
     - Net commission

   - `getBordereauReport(brokerId, dateFrom, dateTo)`: Bordereau activity:
     - Runs by status
     - Items by validation status
     - Transmission success rate

   - `exportReport(brokerId, reportType, dateFrom, dateTo, format)`: Export as CSV or PDF
   - `getTcfDashboard(brokerId)`: TCF outcome indicators:
     - Complaint rate per 1000 policies
     - Claims turnaround times
     - Customer churn rate
     - IPID acknowledgement rate for consumer products

2. **Reporting routes** (`routes/reports.ts`):
   - `GET /api/reports/dashboard` — dashboard KPIs (requires `reports:read`)
   - `GET /api/reports/gwp` — GWP report (requires `reports:read`)
   - `GET /api/reports/policies` — policy report (requires `reports:read`)
   - `GET /api/reports/financial` — financial report (requires `reports:read`)
   - `GET /api/reports/renewals` — renewal report (requires `reports:read`)
   - `GET /api/reports/claims` — claims report (requires `reports:read`)
   - `GET /api/reports/complaints` — complaints report (requires `reports:read`)
   - `GET /api/reports/commissions` — commission report (requires `reports:read`)
   - `GET /api/reports/bordereaux` — bordereau report (requires `reports:read`)
   - `GET /api/reports/tcf` — TCF dashboard (requires `reports:read`)
   - `GET /api/reports/export` — export any report (requires `reports:export`)
     Query: `?report=gwp&from=&to=&format=csv`
   All report endpoints accept `?from=&to=` date range query params.

3. **Performance**: Report queries should complete within 5 seconds for brokers with up to 10,000 policies. Use database-level aggregation (GROUP BY, SUM, COUNT) rather than loading all records into memory.

### Acceptance criteria:
- Dashboard returns all KPI metrics in a single call
- GWP report breaks down by month and product
- Financial report shows premium flow from gross to net
- All reports accept date range filters
- CSV export contains headers and formatted data
- Queries perform within 5 seconds on 10k policy dataset
- TCF dashboard shows compliance indicators
