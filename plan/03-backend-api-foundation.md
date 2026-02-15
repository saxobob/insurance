# Step 03 — Backend API Foundation

## Goal
Build the Fastify server with plugin architecture, tenant-aware middleware, structured error handling, request validation, and logging. This is the backbone all API routes plug into.

## Prerequisites
- Step 01 (monorepo) and Step 02 (database/Drizzle) completed

---

## Prompt

You are building the Fastify API server for a UK insurance broker policy admin SaaS. The monorepo and Drizzle ORM are already set up in `packages/api`. Build the server foundation with middleware and plugin structure.

### Files to create/modify:

```
packages/api/src/
├── index.ts                    # Server entry point (modify existing)
├── app.ts                      # Fastify app factory
├── config.ts                   # Environment config loader with validation
├── plugins/
│   ├── cors.ts                 # CORS plugin
│   ├── auth.ts                 # Auth decorator (adds user to request)
│   ├── tenant.ts               # Tenant context plugin (adds tenantDb to request)
│   ├── audit.ts                # Audit logging plugin (auto-logs mutations)
│   └── error-handler.ts        # Global error handler
├── middleware/
│   ├── require-auth.ts         # Prehandler: reject if not authenticated
│   ├── require-permission.ts   # Prehandler: check user has specific permission
│   └── require-tenant.ts       # Prehandler: ensure tenant context is set
├── routes/
│   ├── index.ts                # Route registrar (auto-loads all route files)
│   └── health.ts               # GET /health — DB connectivity check
├── lib/
│   ├── errors.ts               # Custom error classes (NotFound, Forbidden, Conflict, ValidationError)
│   ├── response.ts             # Standard response envelope helpers
│   ├── pagination.ts           # Pagination helpers (parse query params, build response)
│   └── logger.ts               # Pino logger config
└── types/
    └── fastify.d.ts            # Fastify type augmentation (user, tenantDb on request)
```

### Requirements:

1. **App factory** (`app.ts`):
   - Export `buildApp()` that creates and configures a Fastify instance
   - Register plugins in order: cors → error-handler → auth → tenant → audit → routes
   - Use Fastify's plugin system (fastify.register) for encapsulation
   - Set Fastify logger to Pino with pretty-print in development

2. **Config** (`config.ts`):
   - Load and validate all env vars using Zod
   - Export a typed `config` object with: `port`, `databaseUrl`, `redisUrl`, `jwtSecret`, `s3Bucket`, `s3Endpoint`, `nodeEnv`, `corsOrigin`
   - Throw on startup if required vars are missing

3. **Tenant middleware** (`plugins/tenant.ts`):
   - Read `x-broker-id` header from request (set by auth layer after JWT decode)
   - Call `getTenantDb(brokerId)` from Step 02 to get tenant-scoped DB
   - Decorate the request with `request.tenantDb` and `request.brokerId`
   - If no broker ID, skip (some routes like /health don't need tenant context)

4. **Auth plugin** (`plugins/auth.ts`):
   - Read JWT from `Authorization: Bearer <token>` header or session cookie
   - Decode and validate JWT (for now, use a simple verify — full auth in Step 04)
   - Decorate request with `request.user` containing `{ id, email, brokerId, roleId, permissions[] }`
   - If no token, set `request.user = null` (unauthenticated)

5. **Audit plugin** (`plugins/audit.ts`):
   - Hook into `onResponse` for POST/PUT/PATCH/DELETE requests
   - If the route handler set `request.auditLog = { entityType, entityId, action, reason }`, write to `audit_log` table
   - Include `request.user.id`, `request.ip`, timestamp

6. **Middleware guards**:
   - `requireAuth`: Prehandler that returns 401 if `request.user` is null
   - `requirePermission(code: string)`: Prehandler that returns 403 if user lacks the permission. Log the failed check.
   - `requireTenant`: Prehandler that returns 400 if `request.brokerId` is not set

7. **Error handling** (`plugins/error-handler.ts`):
   - Catch all errors and return consistent JSON envelope: `{ success: false, error: { code, message, details? } }`
   - Map custom errors: NotFoundError → 404, ForbiddenError → 403, ConflictError → 409, ValidationError → 400
   - Zod validation errors → 400 with field-level details
   - Unknown errors → 500 with generic message (log full error server-side)
   - Never leak stack traces in production

8. **Response helpers** (`lib/response.ts`):
   - `success<T>(data: T)` → `{ success: true, data }`
   - `paginated<T>(data: T[], total: number, page: number, pageSize: number)` → `{ success: true, data, pagination: { total, page, pageSize, totalPages } }`

9. **Pagination helpers** (`lib/pagination.ts`):
   - `parsePagination(query: { page?: string, pageSize?: string })` → `{ page: number, pageSize: number, offset: number }` with defaults (page=1, pageSize=25, max 100)
   - Drizzle-compatible: returns `offset` and `limit` for queries

10. **Health route** (`routes/health.ts`):
    - `GET /api/health` — returns `{ status: 'ok', db: 'connected' }` after a simple DB query
    - No auth required

11. **Type augmentation** (`types/fastify.d.ts`):
    - Extend `FastifyRequest` to add `user`, `brokerId`, `tenantDb`, `auditLog` properties

12. **Entry point** (`index.ts`):
    - Call `buildApp()`, listen on configured port
    - Graceful shutdown on SIGTERM/SIGINT (close DB pool, stop server)

### Acceptance criteria:
- Server starts on configured port
- `GET /api/health` returns 200 with DB status
- Unauthenticated requests to protected routes return 401
- Requests without tenant context return 400 on tenant-required routes
- All errors return consistent JSON envelope
- Pino logs show request method, URL, status code, and duration
- TypeScript compiles with no errors
