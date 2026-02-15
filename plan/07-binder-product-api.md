# Step 07 — Binder & Product Configuration API

## Goal
Build binder and product management endpoints. Binders represent delegated underwriting arrangements; products are insurance products offered under each binder.

## Prerequisites
- Steps 01–06 completed

---

## Prompt

You are building the binder and product configuration API for a UK insurance broker policy admin SaaS. Binders are delegated authority arrangements with insurers/MGAs. Each binder has one or more products that brokers can quote and bind.

### Schema context:
- `binders`: id, broker_id, binder_name, binder_holder, api_endpoint, supports_api_rating, active, created_at
- `products`: id, binder_id, product_code, name, class_of_business, retail_consumer, ipid_required, active

### Files to create:

```
packages/api/src/
├── services/
│   ├── binder.service.ts         # Binder CRUD + API credential management
│   └── product.service.ts        # Product CRUD
├── routes/
│   ├── binders.ts                # Binder routes
│   └── products.ts               # Product routes (nested under binder or standalone)
```

### Requirements:

1. **Binder service** (`services/binder.service.ts`):
   - `createBinder(brokerId, data)`: Create binder with name, holder, API endpoint (optional), whether it supports API rating. Validate binder_name is unique per broker.
   - `updateBinder(brokerId, binderId, data)`: Update binder config. If API endpoint changes, log it (security-sensitive change).
   - `getBinder(brokerId, binderId)`: Get binder with its products.
   - `listBinders(brokerId, filters)`: List binders with optional filters: `active`, `search` (name/holder), pagination.
   - `deactivateBinder(brokerId, binderId)`: Set active=false. Don't delete — policies may reference it.
   - `testBinderConnection(brokerId, binderId)`: If binder has API endpoint, make a test call (GET or ping) and return success/failure. Log the test attempt.
   - `storeBinderCredentials(brokerId, binderId, credentials)`: Store API credentials (API key, auth headers) encrypted. Use pgcrypto or application-level encryption. Never return raw credentials in API responses — only show masked version.

2. **Product service** (`services/product.service.ts`):
   - `createProduct(brokerId, binderId, data)`: Create product under binder. Validate product_code is unique within the binder. Set ipid_required=true automatically if retail_consumer=true.
   - `updateProduct(brokerId, productId, data)`: Update product. Cannot change binder_id after creation.
   - `getProduct(brokerId, productId)`: Get product with binder info and active IPID template.
   - `listProducts(brokerId, filters)`: List products with filters: `binderId`, `classOfBusiness`, `active`, `retailConsumer`, pagination.
   - `deactivateProduct(brokerId, productId)`: Set active=false. Cannot deactivate if there are draft/quoted policies using it.

3. **Binder routes** (`routes/binders.ts`):
   - `GET /api/binders` — list binders (requires `binders:read`)
   - `GET /api/binders/:id` — get binder with products (requires `binders:read`)
   - `POST /api/binders` — create binder (requires `binders:manage`)
   - `PUT /api/binders/:id` — update binder (requires `binders:manage`)
   - `DELETE /api/binders/:id` — deactivate binder (requires `binders:manage`)
   - `POST /api/binders/:id/test` — test API connection (requires `binders:manage`)
   - `PUT /api/binders/:id/credentials` — store API credentials (requires `binders:manage`)

4. **Product routes** (`routes/products.ts`):
   - `GET /api/products` — list all products across binders (requires `products:read`)
   - `GET /api/products/:id` — get product detail (requires `products:read`)
   - `POST /api/binders/:binderId/products` — create product under binder (requires `products:manage`)
   - `PUT /api/products/:id` — update product (requires `products:manage`)
   - `DELETE /api/products/:id` — deactivate product (requires `products:manage`)

5. **Class of business values** (add to shared types):
   ```
   motor, home, travel, pet, property_owners, tradesman_liability,
   commercial_combined, professional_indemnity, employers_liability,
   public_liability, cyber, other
   ```

6. **Binder credential encryption**: Store API credentials encrypted at rest. Use a per-broker encryption key or application-level AES-256 encryption. The stored value should never be decryptable via SQL alone.

### Acceptance criteria:
- Binder CRUD works with tenant isolation
- Products are always scoped to a binder
- Deactivating a binder/product doesn't delete it (historical policies still reference it)
- API credentials are stored encrypted, never returned in plain text
- Product codes are unique within a binder
- Retail consumer products automatically require IPID
- Test connection endpoint makes a real HTTP call to binder API
