# Step 27 — Frontend: Customer Management Pages

## Goal
Build customer list, detail, create/edit forms, and timeline view.

## Prerequisites
- Steps 25–26 completed

---

## Prompt

You are building the customer management pages for a UK insurance broker policy admin SaaS React frontend. Backend endpoints exist at `/api/customers/*`.

### Files to create/modify:

```
packages/web/src/
├── routes/_app/customers/
│   ├── index.tsx                 # Customer list page
│   ├── $customerId.tsx           # Customer detail page
│   └── new.tsx                   # Create customer page
├── hooks/
│   └── use-customers.ts          # Customer API hooks
├── components/
│   └── customers/
│       ├── customer-table.tsx     # Customer data table with search/filters
│       ├── customer-form.tsx      # Create/edit customer form
│       ├── customer-detail.tsx    # Customer detail layout with tabs
│       ├── customer-timeline.tsx  # Timeline component
│       ├── customer-policies.tsx  # Customer's policies list
│       └── duplicate-warning.tsx  # Duplicate detection alert
```

### Requirements:

1. **Customer list page**:
   - Data table with columns: Name, Type (retail/commercial badge), Email, Phone, Policies (count), Created
   - Search bar (searches name, email, phone)
   - Filter by customer type (retail/commercial)
   - Sort by name or created date
   - "Add Customer" button (permission-gated)
   - Row click navigates to customer detail

2. **Customer detail page** — Tabbed layout:
   - **Overview tab**: Customer info card (name, type, email, phone, address, company details if commercial, GDPR lawful basis, marketing consent)
   - **Policies tab**: Table of customer's policies with status, product, premium, dates
   - **Timeline tab**: Chronological activity feed (policy events, emails, documents, notes)
   - **Documents tab**: Documents associated with this customer
   - **KYC tab**: KYC check status and history
   - Edit button to modify customer details
   - Delete button (only if no policies, with confirmation dialog)

3. **Customer form**:
   - React Hook Form with Zod validation
   - Fields: customer_type (radio), full_name, email, phone, address (line1, line2, city, county, postcode), gdpr_lawful_basis (select), marketing_consent (checkbox)
   - If commercial: show company_name (required) and company_number fields
   - UK postcode validation
   - On submit: show duplicate detection warnings before creating
   - Both create and edit modes using same form component

4. **Timeline component**:
   - Vertical timeline with event type icons
   - Event types colour-coded (policy=blue, claim=red, email=gray, payment=green, note=yellow)
   - "Add Note" button to add manual timeline entry
   - Paginated (load more)

5. **Duplicate detection**: When creating, if API returns potential duplicates, show warning dialog listing matches with option to proceed or view existing customer.

### Acceptance criteria:
- Customer list loads with pagination and search
- Creating a customer validates all fields (commercial requires company_name)
- Detail page shows all tabs with correct data
- Timeline shows chronological events with icons
- Duplicate warning appears for potential matches
- Edit form pre-fills existing data
- Delete requires confirmation and prevents deletion with policies
