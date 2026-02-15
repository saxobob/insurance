# Step 37 — Frontend: Reporting & MI Dashboards

## Goal
Build reporting dashboards with charts, tables, and export controls.

## Prerequisites
- Steps 25–36 completed

---

## Prompt

You are building the reporting pages for a UK insurance broker policy admin SaaS React frontend. Backend report endpoints exist at `/api/reports/*`.

### Files to create/modify:

```
packages/web/src/
├── routes/_app/reports/
│   ├── index.tsx                 # Report hub / selection
│   ├── gwp.tsx                   # GWP report
│   ├── financial.tsx             # Financial summary report
│   ├── claims.tsx                # Claims report
│   ├── complaints.tsx            # Complaints report
│   └── tcf.tsx                   # TCF dashboard
├── hooks/
│   └── use-reports.ts
├── components/
│   └── reports/
│       ├── report-layout.tsx      # Shared report layout (date range, export)
│       ├── date-range-picker.tsx  # Date range selector
│       ├── export-button.tsx      # CSV/PDF export button
│       ├── gwp-charts.tsx         # GWP visualizations
│       ├── financial-charts.tsx   # Financial visualizations
│       └── tcf-indicators.tsx     # TCF outcome indicators
```

### Requirements:

1. **Report hub**: Card grid linking to each report type with icon, title, brief description.

2. **Shared report layout**: Date range picker (presets: this month, last month, this quarter, this year, custom), export buttons (CSV, PDF), auto-refresh toggle. All reports use this layout wrapper.

3. **GWP report**: Line chart (monthly GWP), breakdown table by product/binder, new business vs endorsements vs cancellations stacked bar chart. Date range filter.

4. **Financial report**: Summary cards (total premium, fees, commission, IPT, net). Cash flow chart. Outstanding debt aging chart. Payment method breakdown pie chart.

5. **Claims report**: Claims by status bar chart, claims per month trend, average acknowledgement time, total estimated losses. Table with detail.

6. **Complaints report**: SLA compliance gauge, complaints by channel pie, resolution times histogram, FOS referral rate, outcome breakdown.

7. **TCF dashboard**: TCF outcome indicator cards: complaint rate per 1000 policies, average claim turnaround, IPID acknowledgement rate, customer churn rate. Traffic light indicators (green/amber/red).

8. **Export**: CSV downloads the report data. PDF generates a printable version.

### Acceptance criteria:
- All reports load with correct data for selected date range
- Charts render using Recharts with responsive containers
- Date range presets work correctly
- CSV export downloads with correct headers and data
- TCF indicators show traffic light status
- Reports perform within 5 seconds
