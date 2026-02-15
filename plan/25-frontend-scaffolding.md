# Step 25 — Frontend Scaffolding

## Goal
Set up the React frontend with routing, layout shell, authentication flow, API client, and design system (shadcn/ui + Tailwind).

## Prerequisites
- Steps 01–24 completed (all backend APIs exist)

---

## Prompt

You are building the frontend for a UK insurance broker policy admin SaaS. The backend API (Fastify) is complete. Build the React frontend shell with routing, auth, layout, and design system. The UI should look professional, modern, and "snazzy" — suitable for a paid SaaS product.

### Tech stack:
- React 19 + TypeScript + Vite (already scaffolded in Step 01)
- TanStack Router (file-based, type-safe routing)
- TanStack Query (React Query) for server state
- shadcn/ui + Tailwind CSS + Radix UI for components
- React Hook Form + Zod for forms
- Recharts for charts (added later)

### Files to create/modify:

```
packages/web/
├── tailwind.config.ts            # Tailwind with insurance-appropriate theme
├── postcss.config.js
├── src/
│   ├── main.tsx                  # Entry point with providers
│   ├── App.tsx                   # Root component
│   ├── routeTree.gen.ts          # Generated route tree
│   ├── styles/
│   │   └── globals.css           # Global styles, Tailwind imports, CSS variables
│   ├── lib/
│   │   ├── api-client.ts         # Axios/fetch wrapper with auth headers
│   │   ├── query-client.ts       # TanStack Query client config
│   │   ├── auth.ts               # Auth context, login/logout, token management
│   │   └── utils.ts              # Format helpers (currency, dates, etc.)
│   ├── hooks/
│   │   ├── use-auth.ts           # Auth hook
│   │   ├── use-api.ts            # API query/mutation hooks factory
│   │   └── use-permissions.ts    # Permission check hook
│   ├── components/
│   │   ├── ui/                   # shadcn/ui components (init via CLI)
│   │   ├── layout/
│   │   │   ├── root-layout.tsx   # Main layout with sidebar + topbar
│   │   │   ├── sidebar.tsx       # Navigation sidebar
│   │   │   ├── topbar.tsx        # Top bar with user menu, notifications
│   │   │   ├── breadcrumbs.tsx   # Breadcrumb navigation
│   │   │   └── page-header.tsx   # Reusable page header component
│   │   ├── common/
│   │   │   ├── data-table.tsx    # Reusable data table (TanStack Table + shadcn)
│   │   │   ├── loading.tsx       # Loading states
│   │   │   ├── error-boundary.tsx # Error boundary
│   │   │   ├── empty-state.tsx   # Empty state placeholder
│   │   │   ├── status-badge.tsx  # Coloured status badges
│   │   │   ├── confirm-dialog.tsx # Confirmation modal
│   │   │   └── search-input.tsx  # Debounced search input
│   │   └── auth/
│   │       ├── login-form.tsx    # Login page form
│   │       ├── mfa-form.tsx      # MFA code entry
│   │       └── protected-route.tsx # Auth guard for routes
│   ├── routes/
│   │   ├── __root.tsx            # Root route (layout)
│   │   ├── _auth.tsx             # Auth layout (for login pages)
│   │   ├── _auth/
│   │   │   └── login.tsx         # Login page
│   │   ├── _app.tsx              # App layout (authenticated, sidebar)
│   │   └── _app/
│   │       ├── index.tsx         # Dashboard (home page)
│   │       ├── customers/
│   │       │   ├── index.tsx     # Customer list
│   │       │   └── $customerId.tsx # Customer detail
│   │       ├── policies/
│   │       │   ├── index.tsx     # Policy list
│   │       │   └── $policyId.tsx # Policy detail
│   │       ├── quotes/
│   │       │   ├── index.tsx     # Quote list
│   │       │   └── new.tsx       # New quote wizard
│   │       ├── claims/
│   │       │   └── index.tsx     # Claims list (placeholder)
│   │       ├── complaints/
│   │       │   └── index.tsx     # Complaints list (placeholder)
│   │       ├── financials/
│   │       │   └── index.tsx     # Financials overview (placeholder)
│   │       ├── bordereaux/
│   │       │   └── index.tsx     # Bordereaux list (placeholder)
│   │       ├── renewals/
│   │       │   └── index.tsx     # Renewals pipeline (placeholder)
│   │       ├── reports/
│   │       │   └── index.tsx     # Reports dashboard (placeholder)
│   │       └── settings/
│   │           └── index.tsx     # Settings page (placeholder)
```

### Requirements:

1. **Tailwind theme**: Insurance-appropriate professional colour scheme:
   - Primary: deep blue (trust, reliability)
   - Accent: teal or emerald
   - Success/warning/error: standard green/amber/red
   - Background: light gray with white cards
   - Dark mode support (CSS variables)
   - Professional sans-serif font (Inter)

2. **shadcn/ui setup**: Initialize shadcn/ui and install these components:
   Button, Input, Label, Select, Textarea, Card, Table, Badge, Dialog, DropdownMenu, Sheet, Tabs, Separator, Avatar, Toast, Tooltip, Command, Popover, Calendar, Checkbox, RadioGroup, Switch, Form, Skeleton

3. **API client** (`lib/api-client.ts`):
   - Axios instance with base URL from env (`VITE_API_URL`)
   - Request interceptor: attach `Authorization: Bearer <token>` header
   - Response interceptor: handle 401 (redirect to login), 403 (show forbidden toast)
   - Auto-refresh tokens on 401 using refresh token

4. **Auth flow** (`lib/auth.ts`):
   - AuthContext providing: `user`, `isAuthenticated`, `login()`, `logout()`, `permissions[]`
   - Store tokens in localStorage (access) and httpOnly cookie (refresh — via API)
   - On app load: check for valid token, redirect to login if expired
   - Login form: email + password → tokens → redirect to dashboard
   - MFA flow: if login returns `requiresMfa`, show MFA code entry

5. **Permission hook** (`hooks/use-permissions.ts`):
   - `usePermission(code)` → boolean (does current user have this permission?)
   - `useAnyPermission(codes[])` → boolean
   - `<PermissionGate permission="policies:create">` component — only renders children if user has permission

6. **Layout** (`components/layout/`):
   - **Sidebar**: Collapsible, with navigation groups:
     - Dashboard (home icon)
     - Customers
     - Policies
     - Quotes → New Quote
     - Claims
     - Complaints
     - Financials → Invoices, Receipts, Commissions
     - Bordereaux
     - Renewals
     - Reports
     - Settings (bottom) → Users, Roles, Binders, Products, Email Templates, Tax Rates
   - **Topbar**: Broker name, search (global), notifications bell, user avatar with dropdown (profile, change password, logout)
   - **Breadcrumbs**: Auto-generated from route path
   - Sidebar items hidden if user lacks relevant permission

7. **Data table** (`components/common/data-table.tsx`):
   - Reusable table built on TanStack Table + shadcn Table
   - Features: sorting, filtering, pagination, row selection, column visibility toggle
   - Accepts columns definition and data
   - Server-side pagination (passes page/pageSize to API)
   - Loading skeleton while fetching

8. **Status badges**: Colour-coded badges for policy status, claim status, complaint status, invoice status. Use consistent colour mapping.

9. **Utility helpers** (`lib/utils.ts`):
   - `formatCurrency(amount)` → "£1,234.56"
   - `formatDate(date)` → "14 Feb 2026"
   - `formatDateTime(date)` → "14 Feb 2026, 10:30"
   - `formatPolicyNumber(number)` → display formatting
   - `cn()` — classnames merger (shadcn pattern)

10. **Route placeholders**: Create placeholder pages for all routes listed above. Each placeholder should show the page title, a brief description, and a "Coming soon" state. This ensures routing works before building full pages.

### Acceptance criteria:
- `pnpm dev` starts the frontend on port 5173
- Login flow works: email/password → token → redirect to dashboard
- Sidebar navigation between all sections works
- Unauthenticated access redirects to login
- Layout is responsive (sidebar collapses on mobile)
- shadcn/ui components render correctly with the custom theme
- Data table component works with sample data
- Permission-based menu hiding works
- Dark mode toggle works (optional but nice)
