# Step 04 — Authentication & Session Management

## Goal
Implement user authentication with login, logout, session/JWT management, password hashing, MFA (TOTP), and user invitation flow.

## Prerequisites
- Steps 01–03 completed (monorepo, database, API foundation)

---

## Prompt

You are building the authentication system for a UK insurance broker policy admin SaaS. The Fastify server, Drizzle ORM, and middleware foundation are already in place. Implement auth routes and supporting services.

### Schema context (from schema.sql):
- `users` table: id, broker_id, email (unique), full_name, mfa_enabled, active, created_at, role_id
- Users table does NOT have a password_hash column — you need to add this via a migration
- `roles` table: id, broker_id, name, description

### Files to create/modify:

```
packages/api/src/
├── db/
│   └── schema/
│       └── users.ts              # MODIFY: add password_hash, mfa_secret, last_login_at columns
├── services/
│   ├── auth.service.ts           # Auth business logic
│   └── user.service.ts           # User CRUD operations
├── routes/
│   ├── auth.ts                   # Auth routes (login, logout, refresh, mfa)
│   └── users.ts                  # User management routes (invite, list, update)
└── lib/
    ├── jwt.ts                    # JWT sign/verify helpers
    ├── password.ts               # Argon2 hash/verify
    └── mfa.ts                    # TOTP generation/verification
```

### Requirements:

1. **Schema migration** — Add columns to `users` table:
   - `password_hash text` (nullable — null for invited-but-not-yet-activated users)
   - `mfa_secret text` (nullable — set during MFA enrolment)
   - `mfa_backup_codes text[]` (nullable — backup codes for MFA recovery)
   - `last_login_at timestamptz` (nullable)
   - `invite_token text` (nullable — for invitation flow)
   - `invite_expires_at timestamptz` (nullable)

2. **Password hashing** (`lib/password.ts`):
   - Use `argon2` for hashing (argon2id variant)
   - `hashPassword(plain: string): Promise<string>`
   - `verifyPassword(plain: string, hash: string): Promise<boolean>`

3. **JWT helpers** (`lib/jwt.ts`):
   - `signAccessToken(payload: { userId, email, brokerId, roleId }): string` — short-lived (15 min)
   - `signRefreshToken(payload: { userId }): string` — longer-lived (7 days)
   - `verifyToken(token: string): TokenPayload` — throws on invalid/expired
   - Use `jsonwebtoken` package with `JWT_SECRET` from config

4. **MFA** (`lib/mfa.ts`):
   - `generateMfaSecret(): { secret, otpauthUrl, qrCodeDataUrl }` — generate TOTP secret, return QR code as data URL
   - `verifyMfaToken(secret: string, token: string): boolean` — verify a 6-digit TOTP code
   - `generateBackupCodes(count: number): string[]` — generate single-use backup codes
   - Use `otpauth` or `speakeasy` package

5. **Auth service** (`services/auth.service.ts`):
   - `login(email, password)`: Validate credentials, check user is active, return tokens. If MFA enabled, return `{ requiresMfa: true, mfaChallengeToken }` instead of full tokens.
   - `completeMfaLogin(challengeToken, mfaCode)`: Verify MFA code, return tokens.
   - `refreshTokens(refreshToken)`: Verify refresh token, issue new access + refresh tokens.
   - `logout(userId)`: Invalidate refresh token (store blacklist in Redis or DB).
   - `enrollMfa(userId)`: Generate secret, return QR code and backup codes.
   - `confirmMfa(userId, code)`: Verify code against secret, enable MFA on user.
   - `disableMfa(userId, password)`: Require password re-entry, disable MFA.

6. **User service** (`services/user.service.ts`):
   - `inviteUser(brokerId, email, fullName, roleId)`: Create user with invite_token, send invite email (stub for now — just log the invite URL).
   - `acceptInvite(token, password)`: Validate token not expired, set password_hash, clear invite fields, activate user.
   - `listUsers(brokerId, pagination)`: List users for broker with role info.
   - `updateUser(userId, updates)`: Update name, role, active status. Log changes.
   - `changePassword(userId, oldPassword, newPassword)`: Verify old password, set new hash.

7. **Auth routes** (`routes/auth.ts`):
   - `POST /api/auth/login` — body: `{ email, password }` → tokens or MFA challenge
   - `POST /api/auth/mfa-verify` — body: `{ challengeToken, code }` → tokens
   - `POST /api/auth/refresh` — body: `{ refreshToken }` → new tokens
   - `POST /api/auth/logout` — invalidate session (requires auth)
   - `POST /api/auth/mfa/enroll` — start MFA enrolment (requires auth)
   - `POST /api/auth/mfa/confirm` — confirm MFA with first code (requires auth)
   - `DELETE /api/auth/mfa` — disable MFA (requires auth + password)
   - `POST /api/auth/change-password` — body: `{ oldPassword, newPassword }` (requires auth)

8. **User management routes** (`routes/users.ts`):
   - `GET /api/users` — list users for current broker (requires auth + `users:read` permission)
   - `POST /api/users/invite` — invite new user (requires auth + `users:manage` permission)
   - `POST /api/users/accept-invite` — accept invitation (no auth, uses invite token)
   - `PUT /api/users/:id` — update user (requires auth + `users:manage` permission)
   - `GET /api/users/me` — get current user profile (requires auth)

9. **Update auth plugin** (`plugins/auth.ts`):
   - Actually verify JWT using `verifyToken()` from jwt.ts
   - Populate `request.user` with decoded payload including permissions loaded from DB
   - Set `request.brokerId` from the decoded token

### Acceptance criteria:
- User can log in with email/password and receive JWT tokens
- Access token expires after 15 minutes, refresh token after 7 days
- MFA enrolment generates QR code, confirmation enables MFA on account
- Login with MFA returns challenge requiring TOTP code
- Invited user can accept invite and set password
- Password is hashed with Argon2, never stored in plain text
- Invalid credentials return 401 with generic "Invalid email or password" (no user enumeration)
- All auth events logged to audit_log
