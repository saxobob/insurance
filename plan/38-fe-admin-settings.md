# Step 38 — Frontend: Admin & Settings Pages

## Goal
Build admin pages for user management, roles, email templates, tax rates, and broker settings.

## Prerequisites
- Steps 25–37 completed

---

## Prompt

You are building the admin settings pages for a UK insurance broker policy admin SaaS React frontend. These pages are for Broker Admin users to configure the system.

### Files to create/modify:

```
packages/web/src/
├── routes/_app/settings/
│   ├── index.tsx                 # Settings hub
│   ├── users/
│   │   └── index.tsx             # User management
│   ├── roles/
│   │   └── index.tsx             # Role & permission editor
│   ├── email-templates/
│   │   └── index.tsx             # Email template editor
│   ├── tax-rates/
│   │   └── index.tsx             # Tax rate configuration
│   └── broker/
│       └── index.tsx             # Broker profile settings
├── components/
│   └── settings/
│       ├── user-table.tsx         # User list with actions
│       ├── invite-user-form.tsx   # Invite user dialog
│       ├── role-editor.tsx        # Role with permission checkboxes
│       ├── email-template-editor.tsx # Template editor with preview
│       ├── tax-rate-table.tsx     # Tax rates list with add/edit
│       └── broker-settings-form.tsx # Broker profile form
```

### Requirements:

1. **Settings hub**: Card grid linking to each settings section. Only show cards the user has permission to access.

2. **User management**: Table with name, email, role, active status, last login, MFA status. Actions: edit role, deactivate, resend invite. "Invite User" button → dialog with email, name, role selector.

3. **Role editor**: List of roles (system + custom). Click role → show permissions as grouped checkboxes (grouped by domain: Customers, Policies, Quotes, etc.). System roles shown as read-only. "Create Role" button for custom roles.

4. **Email template editor**: List of templates by type. Click → code editor (or textarea) for subject and body templates. Show available merge tokens as a reference list. "Preview" button renders with sample data in a side panel.

5. **Tax rate configuration**: Table of tax rates: class of business, rate, effective from, effective to. "Add Rate" button. Edit inline. Cannot edit rates already used by policies (show warning).

6. **Broker settings**: Broker name, FCA number, default retention period, default invoice payment terms (days), logo upload, contact details. These are broker-wide settings.

### Acceptance criteria:
- User invitation sends invite (or logs it in dev)
- Role editor shows all permissions grouped logically
- System roles cannot be modified
- Email template preview renders correctly
- Tax rate validation prevents conflicts (overlapping dates for same class)
- All settings pages permission-gated to admin users
