# Step 41 — Deployment, CI/CD & Environment Configuration

## Goal
Set up Docker containers, docker-compose for local development, GitHub Actions CI/CD pipeline, and environment configuration for staging/production.

## Prerequisites
- Steps 01–40 completed

---

## Prompt

You are setting up the deployment infrastructure for a UK insurance broker policy admin SaaS. The application uses Node.js (Fastify API), React (Vite frontend), PostgreSQL, and Redis. Target deployment: UK-based cloud hosting (AWS, Azure, or equivalent). Set up Docker, CI/CD, and environment configuration.

### Files to create:

```
# Docker
Dockerfile.api                    # API service Dockerfile
Dockerfile.web                    # Web frontend Dockerfile (nginx)
docker-compose.yml                # Local development stack
docker-compose.prod.yml           # Production-like stack
.dockerignore

# CI/CD
.github/
├── workflows/
│   ├── ci.yml                    # CI: lint, typecheck, test on every PR
│   ├── deploy-staging.yml        # Deploy to staging on merge to develop
│   └── deploy-production.yml     # Deploy to production on release tag
├── CODEOWNERS
└── pull_request_template.md

# Environment
.env.example                      # Updated with all variables
.env.development                  # Local development defaults (git-ignored)
.env.staging.example              # Staging config template
.env.production.example           # Production config template

# Infrastructure
infra/
├── nginx.conf                    # Nginx config for frontend + API proxy
├── init-db.sh                    # Database initialization script
└── backup.sh                     # Database backup script
```

### Requirements:

1. **API Dockerfile** (`Dockerfile.api`):
   - Multi-stage build: build stage (compile TypeScript) → production stage (Node.js alpine)
   - Copy only compiled output + node_modules (production deps only)
   - Non-root user for security
   - Health check: `curl http://localhost:3000/api/health`
   - Expose port 3000

2. **Web Dockerfile** (`Dockerfile.web`):
   - Multi-stage: build stage (Vite build) → nginx alpine serving static files
   - Nginx config to serve SPA (fallback to index.html for client-side routing)
   - API proxy: `/api/*` → api service
   - Expose port 80

3. **docker-compose.yml** (local dev):
   - Services: api, web, postgres, redis, minio (S3-compatible)
   - PostgreSQL 18 with volume for data persistence
   - Redis for job queues and caching
   - MinIO for local S3-compatible document storage
   - API mounts source for hot-reload (tsx watch)
   - Web runs Vite dev server
   - Network: all services on same bridge network
   - Healthchecks on postgres and redis

4. **CI pipeline** (`.github/workflows/ci.yml`):
   - Triggers: push to any branch, PR to main/develop
   - Steps:
     1. Checkout code
     2. Setup Node.js + pnpm
     3. Install dependencies (`pnpm install --frozen-lockfile`)
     4. Lint (`pnpm lint`)
     5. Type check (`pnpm typecheck`)
     6. Unit tests (`pnpm test`)
     7. Integration tests (start PostgreSQL service container, run migrations, seed, test)
     8. Build (`pnpm build`)
   - PostgreSQL service container for integration tests
   - Cache pnpm store for faster installs
   - Fail fast on any step failure

5. **Staging deployment** (`.github/workflows/deploy-staging.yml`):
   - Triggers: push to `develop` branch
   - Steps:
     1. Run CI steps
     2. Build Docker images
     3. Push to container registry (ECR/ACR/GHCR)
     4. Deploy to staging environment (placeholder — depends on hosting choice)
     5. Run smoke tests against staging
     6. Run database migrations on staging

6. **Production deployment** (`.github/workflows/deploy-production.yml`):
   - Triggers: push of version tag (`v*`)
   - Steps:
     1. Run full CI suite
     2. Build production Docker images with version tag
     3. Push to container registry
     4. Deploy with blue/green or rolling update (placeholder)
     5. Run migrations
     6. Verify health endpoint
     7. Notify team (Slack webhook or similar)

7. **Environment configuration**:
   - `.env.example` — complete list of all env vars with descriptions:
     ```
     # Server
     PORT=3000
     NODE_ENV=development
     CORS_ORIGIN=http://localhost:5173

     # Database
     DATABASE_URL=postgresql://postgres:postgres@localhost:5432/insurance
     DB_POOL_SIZE=20

     # Redis
     REDIS_URL=redis://localhost:6379

     # Auth
     JWT_SECRET=change-me-in-production
     JWT_ACCESS_EXPIRY=15m
     JWT_REFRESH_EXPIRY=7d

     # Storage (S3-compatible)
     S3_ENDPOINT=http://localhost:9000
     S3_BUCKET=insurance-docs
     S3_ACCESS_KEY=minioadmin
     S3_SECRET_KEY=minioadmin
     S3_REGION=eu-west-2

     # Email
     SMTP_HOST=localhost
     SMTP_PORT=1025
     SMTP_USER=
     SMTP_PASS=
     EMAIL_FROM=noreply@insurancebroker.co.uk

     # Encryption
     ENCRYPTION_KEY=change-me-32-byte-key-here

     # Frontend
     VITE_API_URL=http://localhost:3000/api
     ```

8. **Database initialization** (`infra/init-db.sh`):
   - Create database if not exists
   - Create `meta` schema
   - Run migrations
   - Seed system data (permissions, roles)
   - Optionally provision a demo tenant

9. **Database backup** (`infra/backup.sh`):
   - pg_dump with timestamp
   - Upload to S3 backup bucket
   - Retain last 30 daily backups
   - Cron-compatible

10. **Nginx config** (`infra/nginx.conf`):
    - Serve frontend static files
    - Proxy `/api/*` to backend service
    - Gzip compression
    - Security headers (HSTS, X-Frame-Options, CSP, X-Content-Type-Options)
    - Rate limiting on auth endpoints

### Acceptance criteria:
- `docker compose up` starts the full local development stack
- API, web, database, Redis, and MinIO all running and connected
- CI pipeline runs lint, typecheck, and tests on every PR
- Docker images build successfully
- Environment variables are documented and validated on startup
- Nginx serves frontend and proxies API correctly
- Database backup script works and uploads to S3
- Non-root users in Docker containers
- Security headers set in nginx
