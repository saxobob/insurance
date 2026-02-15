# Step 29 — Frontend: Quoting Flow UI

## Goal
Build the multi-step quote wizard: product selection, customer selection, risk capture, rating, IPID acknowledgement, premium display, and bind action.

## Prerequisites
- Steps 25–28 completed

---

## Prompt

You are building the quoting flow UI for a UK insurance broker policy admin SaaS React frontend. This is the primary workflow — brokers create quotes by selecting a customer, choosing a product, entering risk details, and getting a rated premium. The flow is a multi-step wizard.

### Files to create/modify:

```
packages/web/src/
├── routes/_app/quotes/
│   ├── index.tsx                 # MODIFY: quote list
│   └── new.tsx                   # MODIFY: multi-step quote wizard
├── hooks/
│   └── use-quotes.ts             # Quote API hooks
├── components/
│   └── quotes/
│       ├── quote-wizard.tsx       # Main wizard container with steps
│       ├── step-customer.tsx      # Step 1: Select or create customer
│       ├── step-product.tsx       # Step 2: Select product/binder
│       ├── step-risk-details.tsx  # Step 3: Enter risk items
│       ├── step-rating.tsx        # Step 4: Rate and view premium
│       ├── step-ipid.tsx          # Step 5: IPID acknowledgement (conditional)
│       ├── step-review.tsx        # Step 6: Review and bind
│       ├── quote-summary-card.tsx # Sidebar summary during wizard
│       ├── premium-breakdown.tsx  # Premium/IPT/fee breakdown display
│       └── quote-table.tsx        # Quote list table
```

### Requirements:

1. **Quote list page**:
   - Data table: Quote/Policy Number, Customer, Product, Status (draft/quoted/bound badge), Premium, Created
   - Filter by status, product, date range
   - Search by policy number or customer name
   - "New Quote" button

2. **Multi-step wizard** — Step indicator at top showing progress:

   **Step 1 — Select Customer**:
   - Search existing customers with autocomplete
   - Or "Create New Customer" inline (mini form or link to full form)
   - Show selected customer's details card

   **Step 2 — Select Product**:
   - List available products grouped by binder
   - Show: product name, class of business, retail/commercial badge
   - Filter by class of business
   - Only show active products

   **Step 3 — Risk Details**:
   - Dynamic form based on product type (risk items)
   - Fields: item_type, sum_insured, and item_data (flexible JSONB)
   - For common types (motor, home), provide structured sub-forms:
     - Motor: vehicle reg, make, model, year, value, driver details
     - Home: property type, bedrooms, rebuild value, contents value
   - For other types: generic key-value pairs
   - Inception date and expiry date pickers (default 12-month period)
   - Add multiple risk items if needed

   **Step 4 — Rate Quote**:
   - "Get Quote" button calls the rating API
   - Loading state while calling binder API
   - On success: show premium breakdown (gross, IPT, fees, total)
   - On failure: show error with option for manual rating
   - Manual rating form: gross premium, broker fee, commission rate, reason (required)
   - Show premium breakdown component

   **Step 5 — IPID Acknowledgement** (only for consumer products):
   - Display IPID document (embedded PDF viewer or content)
   - "Customer has acknowledged the IPID" checkbox
   - Cannot proceed without acknowledgement
   - Skip this step entirely for commercial products

   **Step 6 — Review & Bind**:
   - Summary of all entered data: customer, product, risk items, premium breakdown
   - "Bind Quote" button
   - Confirmation dialog before binding
   - On success: redirect to policy detail page
   - "Save as Draft" option to save without binding

3. **Wizard sidebar**: Running summary card showing:
   - Selected customer name
   - Selected product
   - Cover period
   - Premium (when rated)
   - Current step

4. **Navigation**: Back/Next buttons between steps. Can't skip ahead until current step is valid. Can go back to modify.

5. **State management**: Use React state or form context to maintain wizard data across steps. Don't lose data on back navigation.

### Acceptance criteria:
- Full wizard flow from customer selection to binding works
- Rating calls backend and displays premium breakdown
- Manual rating fallback works with required reason
- IPID step only appears for consumer products
- Cannot bind without IPID acknowledgement on consumer products
- Wizard state is preserved when navigating between steps
- Draft can be saved at any point after Step 3
- Bound quote redirects to policy detail
- Form validation prevents invalid submissions at each step
