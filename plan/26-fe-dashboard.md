# Step 26 — Frontend: Dashboard

## Goal
Build the main dashboard page with KPI cards, charts, recent activity, and renewal alerts.

## Prerequisites
- Step 25 completed (frontend shell with routing and components)

---

## Prompt

You are building the dashboard page for a UK insurance broker policy admin SaaS React frontend. The backend `GET /api/reports/dashboard` endpoint provides all KPI data. The UI uses shadcn/ui + Tailwind + Recharts.

### Files to create/modify:

```
packages/web/src/
├── routes/_app/index.tsx         # MODIFY: replace placeholder with full dashboard
├── hooks/
│   └── use-dashboard.ts          # Dashboard data hook
├── components/
│   └── dashboard/
│       ├── kpi-card.tsx           # Single KPI metric card
│       ├── kpi-grid.tsx           # Grid of KPI cards
│       ├── gwp-chart.tsx          # GWP trend line chart
│       ├── policy-status-chart.tsx # Policy status donut chart
│       ├── renewal-alerts.tsx     # Upcoming renewals list
│       ├── recent-activity.tsx    # Recent activity feed
│       └── overdue-items.tsx      # Overdue invoices, complaints
```

### Requirements:

1. **KPI cards** — Row of metric cards showing:
   - Policies in Force (count, with trend arrow vs last month)
   - GWP Year to Date (formatted currency)
   - Commission Earned (formatted currency)
   - Renewals Due (next 30 days count)
   - Open Claims (count)
   - Open Complaints (count with SLA warning if any breached)
   - Overdue Invoices (count + total value)
   Each card: icon, label, value, optional trend indicator. Use shadcn Card.

2. **GWP chart**: Line chart showing monthly GWP for the current year. Use Recharts `LineChart` with responsive container. Show new business vs endorsements vs cancellations as stacked or separate lines.

3. **Policy status chart**: Donut/pie chart showing policies by status. Use Recharts `PieChart`. Clickable segments navigate to filtered policy list.

4. **Renewal alerts**: List of policies renewing in the next 14 days with: policy number, customer name, current premium, renewal status. Link to renewal detail. Show count badge.

5. **Recent activity**: Feed showing last 10 activities across the system: policy created, claim logged, payment received, etc. Pull from audit log or aggregate endpoint. Show user avatar, action description, timestamp.

6. **Overdue items**: Combined list of overdue invoices and approaching complaint SLA deadlines. Red styling for urgency.

7. **Layout**: Responsive grid — 4 KPIs across on desktop (2 on tablet, 1 on mobile), charts side by side (stacked on mobile), alerts and activity below.

8. **Data fetching**: Use TanStack Query with `useQuery` to fetch dashboard data. Show skeleton loading states. Auto-refresh every 60 seconds.

### Acceptance criteria:
- Dashboard loads within 2 seconds showing all KPIs
- Charts render correctly with real or sample data
- Renewal alerts link to renewal detail pages
- Responsive layout works on all screen sizes
- Loading skeletons show while data fetches
- Auto-refresh keeps data current
