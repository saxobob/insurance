# Step 01 — Project Scaffolding & Monorepo Setup

## Goal
Set up a pnpm monorepo with Turborepo containing three packages: `api` (Fastify backend), `web` (React frontend), and `shared` (shared TypeScript types and validation schemas). Configure tooling: TypeScript, ESLint, Prettier, and base configs.

## Context Files
- Read `CLAUDE.md` for project overview and architecture decisions
- Read `design.md` for business requirements
- Read `schema.sql` for database structure

---

## Prompt

You are building the foundation of a UK insurance broker policy administration SaaS system. Set up a pnpm monorepo with Turborepo.

### Directory structure to create:

```
/
├── package.json              # Root workspace config
├── pnpm-workspace.yaml       # Workspace definition
├── turbo.json                # Turborepo pipeline config
├── tsconfig.base.json        # Shared TypeScript config
├── .eslintrc.cjs             # Root ESLint config
├── .prettierrc               # Prettier config
├── .gitignore                # Updated gitignore
├── .env.example              # Environment variable template
│
├── packages/
│   ├── shared/
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   └── src/
│   │       ├── index.ts          # Re-exports
│   │       ├── types/
│   │       │   ├── index.ts
│   │       │   ├── broker.ts     # Broker, Office types
│   │       │   ├── user.ts       # User, Role, Permission types
│   │       │   ├── customer.ts   # Customer types (retail/commercial)
│   │       │   ├── policy.ts     # Policy, PolicyVersion, PolicyStatus enum
│   │       │   ├── financial.ts  # PolicyFinancial, Invoice, Receipt, CommissionSplit
│   │       │   ├── binder.ts     # Binder, Product types
│   │       │   ├── claim.ts      # Claim, FNOL types
│   │       │   ├── complaint.ts  # Complaint types
│   │       │   ├── document.ts   # Document types
│   │       │   └── common.ts     # Shared types (Address, AuditEntry, PaginatedResponse)
│   │       └── validation/
│   │           ├── index.ts
│   │           ├── customer.ts   # Zod schemas for customer input
│   │           ├── policy.ts     # Zod schemas for policy input
│   │           └── common.ts     # Shared validators (email, phone, UUID, UK postcode)
│   │
│   ├── api/
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   └── src/
│   │       └── index.ts          # Placeholder entry point
│   │
│   └── web/
│       ├── package.json
│       ├── tsconfig.json
│       ├── vite.config.ts
│       ├── index.html
│       └── src/
│           ├── main.tsx          # React entry
│           └── App.tsx           # Placeholder app
```

### Requirements:

1. **Root package.json**: Use pnpm workspaces, add scripts for `dev`, `build`, `lint`, `typecheck` that delegate to Turborepo.

2. **Turborepo config**: Define pipelines for `build`, `dev`, `lint`, `typecheck`, `test`. Ensure `shared` builds before `api` and `web`.

3. **TypeScript**: Target ES2022, strict mode, paths alias `@shared/*` pointing to the shared package in both api and web.

4. **Shared types**: Define TypeScript interfaces matching the PostgreSQL schema in `schema.sql`. Key types:
   - `PolicyStatus` enum: `draft | quoted | bound | issued | in_force | endorsement_pending | endorsed | cancelled | lapsed | expired`
   - `CustomerType` enum: `retail | commercial`
   - `TransactionType` enum: `new | endorsement | renewal | cancellation`
   - All entity types should have `id: string` (UUID), `created_at: string` (ISO date), and tenant `broker_id: string`
   - Use `Record<string, unknown>` for JSONB fields (address_json, rating_payload, etc.)
   - Financial amounts as `number` (the DB uses numeric(12,2), frontend handles formatting)

5. **Zod validation schemas**: Create input validation schemas for the most common operations:
   - `createCustomerSchema` — validates customer creation (name required, company_name required if commercial, email format, UK phone format)
   - `createPolicySchema` — validates policy creation (customer_id, product_id, inception_date, expiry_date required, expiry must be after inception)
   - Common validators: `emailSchema`, `ukPhoneSchema`, `ukPostcodeSchema`, `uuidSchema`

6. **ESLint**: Use flat config or `.eslintrc.cjs` with TypeScript parser, recommended rules, import ordering.

7. **Prettier**: 2-space indent, single quotes, trailing commas, 100 char print width.

8. **.env.example**: Include variables for `DATABASE_URL`, `REDIS_URL`, `JWT_SECRET`, `S3_BUCKET`, `S3_ENDPOINT`, `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`, `PORT`.

9. **.gitignore**: Node standard + `dist/`, `.turbo/`, `.env`, coverage, IDE files.

10. **API package**: Fastify with TypeScript. Add dependencies: `fastify`, `@fastify/cors`, `@fastify/cookie`, `drizzle-orm`, `drizzle-kit`, `postgres` (pg driver), `zod`. Just create the entry point that starts Fastify on PORT from env.

11. **Web package**: React 19 + Vite + TypeScript. Add dependencies: `react`, `react-dom`, `@tanstack/react-router`, `@tanstack/react-query`, `tailwindcss`, `postcss`, `autoprefixer`. Configure Tailwind with a minimal config. Create a placeholder App.tsx with "Insurance Broker Admin" heading.

### Acceptance criteria:
- `pnpm install` succeeds from root
- `pnpm build` compiles all three packages
- `pnpm dev` starts both api (port 3000) and web (port 5173) concurrently
- `pnpm typecheck` passes with no errors
- Shared types are importable in both api and web packages
