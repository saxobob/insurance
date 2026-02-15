# Step 28 — Frontend: Binder & Product Admin Pages

## Goal
Build binder configuration and product management admin pages.

## Prerequisites
- Steps 25–27 completed

---

## Prompt

You are building the binder and product admin pages for a UK insurance broker policy admin SaaS React frontend. These are settings/admin pages for configuring delegated authority arrangements.

### Files to create:

```
packages/web/src/
├── routes/_app/settings/
│   ├── binders/
│   │   ├── index.tsx             # Binder list
│   │   └── $binderId.tsx         # Binder detail with products
│   └── products/
│       └── index.tsx             # All products list
├── hooks/
│   ├── use-binders.ts            # Binder API hooks
│   └── use-products.ts           # Product API hooks
├── components/
│   └── settings/
│       ├── binder-form.tsx        # Create/edit binder form
│       ├── binder-detail.tsx      # Binder detail layout
│       ├── product-form.tsx       # Create/edit product form
│       ├── product-list.tsx       # Products table for a binder
│       └── api-test-button.tsx    # Test binder API connection button
```

### Requirements:

1. **Binder list page**:
   - Table: Binder Name, Holder, Products (count), API Rating (yes/no badge), Active (badge), Created
   - "Add Binder" button
   - Search by name/holder
   - Row click → binder detail

2. **Binder detail page**:
   - Binder info card: name, holder, API endpoint (masked), supports_api_rating
   - "Test Connection" button — calls test endpoint, shows success/fail toast
   - Products table for this binder
   - "Add Product" button
   - Edit binder button
   - Credentials management (set/update API credentials — password-style masked input)

3. **Binder form**: binder_name, binder_holder, api_endpoint (optional URL), supports_api_rating (toggle)

4. **Product form**: product_code, name, class_of_business (select from enum), retail_consumer (toggle), ipid_required (auto-set if retail), active (toggle)

5. **Product list**: Table showing product_code, name, class_of_business, retail badge, IPID required badge, active status. Inline edit capability or edit button.

### Acceptance criteria:
- Binder CRUD works with proper form validation
- Products are managed within binder context
- API test button provides visual feedback
- Credentials are never displayed in plain text
- Retail consumer products auto-check IPID required
- Class of business uses the defined enum values
