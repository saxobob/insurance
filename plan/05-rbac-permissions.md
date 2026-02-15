# Step 05 — RBAC: Roles & Permissions

## Goal
Implement role-based access control with predefined roles, granular permissions, permission-checking middleware, and admin UI API for managing roles.

## Prerequisites
- Steps 01–04 completed (monorepo, database, API, auth)

---

## Prompt

You are building the RBAC system for a UK insurance broker policy admin SaaS. Auth is already working with JWT tokens. Now implement roles, permissions, and access control.

### Schema context:
- `roles`: id, broker_id (nullable — null = system-wide), name, description
- `permissions`: id, code (unique), description
- `role_permissions`: role_id, permission_id (composite PK)
- `users`: role_id FK to roles

### Files to create/modify:

```
packages/api/src/
├── db/seed/
│   └── permissions-seed.ts       # Seed all permission codes
├── services/
│   └── role.service.ts           # Role & permission management
├── routes/
│   └── roles.ts                  # Role management routes
├── middleware/
│   └── require-permission.ts     # MODIFY: load permissions from DB via role
└── lib/
    └── permissions.ts            # Permission code constants
```

### Requirements:

1. **Permission codes** (`lib/permissions.ts`):
   Define all permission codes as constants. Group by domain:

   ```
   // Customers
   customers:read, customers:create, customers:update, customers:delete

   // Policies
   policies:read, policies:create, policies:update, policies:bind, policies:cancel

   // Quotes
   quotes:read, quotes:create, quotes:rate

   // Endorsements
   endorsements:create, endorsements:approve

   // Claims
   claims:read, claims:create, claims:update

   // Complaints
   complaints:read, complaints:create, complaints:update, complaints:export

   // Financial
   invoices:read, invoices:create
   receipts:read, receipts:create, receipts:allocate
   commissions:read, commissions:manage

   // Bordereaux
   bordereaux:read, bordereaux:generate, bordereaux:transmit

   // Documents
   documents:read, documents:upload, documents:delete

   // Admin
   users:read, users:manage
   roles:read, roles:manage
   binders:read, binders:manage
   products:read, products:manage
   settings:read, settings:manage

   // Audit & Compliance
   audit:read
   compliance:export
   gdpr:manage

   // Reporting
   reports:read, reports:export
   ```

2. **Predefined roles** (seed data):
   - **Broker Admin**: All permissions
   - **Broker User**: customers:*, policies:*, quotes:*, endorsements:create, claims:create/read, invoices:read, receipts:read, documents:read/upload, reports:read
   - **Compliance Officer**: All read permissions + complaints:*, audit:read, compliance:export, gdpr:manage, reports:*
   - **Claims Handler**: claims:*, policies:read, customers:read, documents:read/upload
   - **Readonly Auditor**: All `:read` permissions + audit:read + compliance:export

3. **Permissions seed** (`permissions-seed.ts`):
   - Insert all permission codes into `permissions` table (idempotent — skip existing)
   - Create the 5 predefined roles in `roles` table with `broker_id = NULL` (system roles)
   - Link roles to permissions via `role_permissions`

4. **Role service** (`services/role.service.ts`):
   - `getPermissionsForRole(roleId)`: Load all permission codes for a role
   - `getUserPermissions(userId)`: Load user's role, then get permissions
   - `listRoles(brokerId)`: List system roles + broker-custom roles
   - `createRole(brokerId, name, description, permissionCodes[])`: Create custom role for broker
   - `updateRole(roleId, name, description, permissionCodes[])`: Update custom role (cannot edit system roles)
   - `deleteRole(roleId)`: Delete custom role only if no users assigned
   - `assignRoleToUser(userId, roleId)`: Update user's role_id

5. **Permission middleware** (`middleware/require-permission.ts`):
   - Modify to load permissions from DB using `getUserPermissions(userId)`
   - Cache permissions in request lifecycle (don't re-query for same request)
   - Consider caching permissions in Redis with short TTL (60s) for performance
   - `requirePermission('policies:create')` — single permission check
   - `requireAnyPermission(['policies:update', 'endorsements:create'])` — any of the listed
   - `requireAllPermissions(['policies:update', 'endorsements:approve'])` — all required

6. **Role routes** (`routes/roles.ts`):
   - `GET /api/roles` — list available roles (requires `roles:read`)
   - `GET /api/roles/:id` — get role with its permissions (requires `roles:read`)
   - `POST /api/roles` — create custom role (requires `roles:manage`)
   - `PUT /api/roles/:id` — update custom role (requires `roles:manage`)
   - `DELETE /api/roles/:id` — delete custom role (requires `roles:manage`)
   - `GET /api/permissions` — list all available permission codes (requires `roles:read`)

7. **Update auth flow**: When generating JWT on login, include the user's permissions array in the token payload (or load them on each request — decide based on performance). If including in token, permissions are snapshotted at login time; changes require re-login or token refresh.

### Acceptance criteria:
- Seed creates all permission codes and 5 predefined roles
- User with "Broker Admin" role can access all endpoints
- User with "Readonly Auditor" role can only access read endpoints; POST/PUT/DELETE returns 403
- Permission check failure is logged to audit_log with user_id, attempted action, and IP
- Broker admin can create custom roles with selected permissions
- System roles cannot be edited or deleted
- Role assignment updates take effect on next token refresh
