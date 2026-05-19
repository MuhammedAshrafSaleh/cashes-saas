# 🗄️ Supabase Database Schema
**Project:** Cashes — Financial Ledger & Cash Management App
**Version:** 1.0.0
**Backend:** Supabase (PostgreSQL 15 + Auth + Storage + pg_cron)

---

## 1. Overview

```
auth.users (Supabase Built-in)
    └── public.users      → extends auth.users with role & company
            └── companies ← user.company_id
            └── projects  ← project.user_id
                    └── cash_entries ← entry.project_id
                            └── receipt_url (nullable) → Storage
notifications          ← company_id scoped
```

---

## 2. Enums

```sql
-- User roles across the system
CREATE TYPE user_role AS ENUM ('owner', 'admin', 'user');

-- Notification activity types
CREATE TYPE notification_type AS ENUM (
  'new_assignment',   -- User created a new project
  'update_log',       -- User added OR edited a cash entry
  'structural_alert', -- User deleted a cash entry
  'archived'          -- User deleted a project
);
```

---

## 3. Tables

---

### 3.1 `companies`

```sql
CREATE TABLE public.companies (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  logo_url    TEXT,                          -- Supabase Storage URL
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

| Column | Type | Notes |
|---|---|---|
| `id` | UUID | PK, auto-generated |
| `name` | TEXT | Company display name, required |
| `logo_url` | TEXT | Nullable — path to logo in Storage bucket |
| `created_at` | TIMESTAMPTZ | Auto |
| `updated_at` | TIMESTAMPTZ | Auto, updated via trigger |

---

### 3.2 `users`

> Extends Supabase `auth.users`. Created by Owner only — no self-registration.

```sql
CREATE TABLE public.users (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name   TEXT NOT NULL,
  email       TEXT NOT NULL UNIQUE,
  role        user_role NOT NULL DEFAULT 'user',
  company_id  UUID REFERENCES public.companies(id) ON DELETE CASCADE,
  avatar_url  TEXT,                          -- Supabase Storage URL
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

| Column | Type | Notes |
|---|---|---|
| `id` | UUID | PK, mirrors `auth.users.id` |
| `full_name` | TEXT | Required |
| `email` | TEXT | Unique, mirrors `auth.users.email` |
| `role` | user_role | `owner` / `admin` / `user` |
| `company_id` | UUID | FK → companies. NULL only for `owner` role |
| `avatar_url` | TEXT | Nullable — path in Storage bucket |
| `created_at` | TIMESTAMPTZ | Auto |
| `updated_at` | TIMESTAMPTZ | Auto |

**Constraints:**
```sql
-- Owner must have NULL company_id; admin and user must have a company
ALTER TABLE public.users ADD CONSTRAINT users_company_role_check
  CHECK (
    (role = 'owner' AND company_id IS NULL) OR
    (role IN ('admin', 'user') AND company_id IS NOT NULL)
  );
```

---

### 3.3 `projects`

```sql
CREATE TABLE public.projects (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  company_id  UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

| Column | Type | Notes |
|---|---|---|
| `id` | UUID | PK |
| `name` | TEXT | Project display name, required |
| `user_id` | UUID | FK → users (the engineer who owns this project) |
| `company_id` | UUID | FK → companies (denormalized for faster RLS queries) |
| `created_at` | TIMESTAMPTZ | Auto |
| `updated_at` | TIMESTAMPTZ | Auto |

> `company_id` is denormalized intentionally for performance — avoids joining through users on every query.

---

### 3.4 `cash_entries`

```sql
CREATE TABLE public.cash_entries (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id          UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  user_id             UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  company_id          UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  entry_name          TEXT NOT NULL,              -- Vendor / entity name
  amount              NUMERIC(12, 2) NOT NULL,    -- e.g. 45200.00
  entry_date          DATE NOT NULL,
  receipt_url         TEXT,                        -- Supabase Storage path (nullable)
  receipt_uploaded_at TIMESTAMPTZ,                 -- When the receipt was uploaded
  receipt_expires_at  TIMESTAMPTZ,                 -- receipt_uploaded_at + 30 days
  receipt_expired     BOOLEAN NOT NULL DEFAULT FALSE, -- Flag set by pg_cron on expiry
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

| Column | Type | Notes |
|---|---|---|
| `id` | UUID | PK |
| `project_id` | UUID | FK → projects (cascade delete) |
| `user_id` | UUID | FK → users (cascade delete) |
| `company_id` | UUID | Denormalized FK → companies (RLS performance) |
| `entry_name` | TEXT | Vendor/entity name — e.g. "Weekly Site Fuel" |
| `amount` | NUMERIC(12,2) | Max 12 digits, 2 decimal places |
| `entry_date` | DATE | Date of the expense (user-set, not system date) |
| `receipt_url` | TEXT | Nullable — Storage path. Becomes NULL after 30 days |
| `receipt_uploaded_at` | TIMESTAMPTZ | Set when image is first attached |
| `receipt_expires_at` | TIMESTAMPTZ | `receipt_uploaded_at + INTERVAL '30 days'` |
| `receipt_expired` | BOOLEAN | Set to TRUE by pg_cron when image is deleted |
| `created_at` | TIMESTAMPTZ | Auto |
| `updated_at` | TIMESTAMPTZ | Auto |

**Auto-set expiry trigger:**
```sql
CREATE OR REPLACE FUNCTION set_receipt_expiry()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.receipt_url IS NOT NULL AND NEW.receipt_uploaded_at IS NOT NULL THEN
    NEW.receipt_expires_at := NEW.receipt_uploaded_at + INTERVAL '30 days';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_receipt_expiry
  BEFORE INSERT OR UPDATE ON public.cash_entries
  FOR EACH ROW EXECUTE FUNCTION set_receipt_expiry();
```

---

### 3.5 `notifications`

```sql
CREATE TABLE public.notifications (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id          UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  triggered_by        UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  type                notification_type NOT NULL,
  message             TEXT NOT NULL,          -- Full readable message (AR/EN snapshot)
  project_name        TEXT NOT NULL,          -- Snapshot in case project gets deleted
  entry_name          TEXT,                   -- Snapshot of the entry involved (nullable for project-level actions)
  engineer_name       TEXT NOT NULL,          -- Snapshot in case user gets deleted
  project_id          UUID REFERENCES public.projects(id) ON DELETE SET NULL,
  is_read             BOOLEAN NOT NULL DEFAULT FALSE,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

| Column | Type | Notes |
|---|---|---|
| `id` | UUID | PK |
| `company_id` | UUID | Scopes notification to one company's Admin |
| `triggered_by` | UUID | FK → the engineer who performed the action |
| `type` | notification_type | `new_assignment` / `update_log` / `structural_alert` / `archived` |
| `message` | TEXT | Full human-readable message — e.g. "تم تعديل بند Weekly Site Fuel في مشروع The Obsidian Plaza" |
| `project_name` | TEXT | Snapshot — preserved even if project is deleted |
| `entry_name` | TEXT | Nullable — snapshot of the specific entry name involved |
| `engineer_name` | TEXT | Snapshot — preserved even if user is deleted |
| `project_id` | UUID | Nullable FK → projects. Used for deep-link navigation. Set to NULL if project is deleted |
| `is_read` | BOOLEAN | Admin marks as read; can then delete |
| `created_at` | TIMESTAMPTZ | Auto — used for sorting |

**Message Templates by Type:**

| Type | Message (AR) | Message (EN) | Trigger |
|---|---|---|---|
| `new_assignment` | تم إنشاء مشروع جديد: {project_name} | New project created: {project_name} | User creates a project |
| `update_log` | تم إضافة بند {entry_name} في مشروع {project_name} | Entry "{entry_name}" added in project {project_name} | User adds a cash entry |
| `update_log` | تم تعديل بند {entry_name} في مشروع {project_name} | Entry "{entry_name}" updated in project {project_name} | User edits a cash entry |
| `structural_alert` | تم حذف بند {entry_name} من مشروع {project_name} | Entry "{entry_name}" deleted from project {project_name} | User deletes a cash entry |
| `archived` | تم حذف مشروع {project_name} | Project {project_name} has been deleted | User deletes a project |

**Navigation Behavior (on tap):**

```
Admin taps notification
    ├── project_id IS NOT NULL → navigate to that project under triggered_by user (read-only view)
    └── project_id IS NULL     → show inline message "هذا المشروع تم حذفه"
                                  (project was deleted — no navigation target)
```

> All text fields (`project_name`, `entry_name`, `engineer_name`, `message`) are stored as **snapshots** — the notification remains readable and complete even after the original data is deleted.

---

## 4. Indexes

```sql
-- Users — fast lookup by company and role
CREATE INDEX idx_users_company_id ON public.users(company_id);
CREATE INDEX idx_users_role       ON public.users(role);

-- Projects — fast lookup by user and company
CREATE INDEX idx_projects_user_id    ON public.projects(user_id);
CREATE INDEX idx_projects_company_id ON public.projects(company_id);

-- Cash Entries — fast lookup by project + expiry check
CREATE INDEX idx_cash_entries_project_id   ON public.cash_entries(project_id);
CREATE INDEX idx_cash_entries_company_id   ON public.cash_entries(company_id);
CREATE INDEX idx_cash_entries_expires_at   ON public.cash_entries(receipt_expires_at)
  WHERE receipt_expired = FALSE;             -- Partial index for pg_cron queries

-- Notifications — fast lookup by company + unread
CREATE INDEX idx_notifications_company_id ON public.notifications(company_id);
CREATE INDEX idx_notifications_unread     ON public.notifications(company_id, is_read)
  WHERE is_read = FALSE;
```

---

## 5. Updated_at Auto-Trigger

```sql
-- Reusable function for auto-updating updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all relevant tables
CREATE TRIGGER trg_companies_updated_at
  BEFORE UPDATE ON public.companies
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_projects_updated_at
  BEFORE UPDATE ON public.projects
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_cash_entries_updated_at
  BEFORE UPDATE ON public.cash_entries
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

---

## 6. Row Level Security (RLS)

> RLS enforces multi-tenant data isolation at the database level.
> The helper function below reads the current user's role and company from `public.users`.

```sql
-- Enable RLS on all tables
ALTER TABLE public.companies      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cash_entries   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications  ENABLE ROW LEVEL SECURITY;

-- Helper: get current user's role
CREATE OR REPLACE FUNCTION auth_role()
RETURNS user_role AS $$
  SELECT role FROM public.users WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Helper: get current user's company_id
CREATE OR REPLACE FUNCTION auth_company_id()
RETURNS UUID AS $$
  SELECT company_id FROM public.users WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;
```

---

### 6.1 `companies` RLS

```sql
-- Owner: full access to all companies
CREATE POLICY "owner_all_companies" ON public.companies
  FOR ALL USING (auth_role() = 'owner');

-- Admin: read-only access to their own company
CREATE POLICY "admin_read_own_company" ON public.companies
  FOR SELECT USING (
    auth_role() = 'admin' AND id = auth_company_id()
  );

-- User: read-only access to their own company
CREATE POLICY "user_read_own_company" ON public.companies
  FOR SELECT USING (
    auth_role() = 'user' AND id = auth_company_id()
  );
```

---

### 6.2 `users` RLS

```sql
-- Owner: full access to all users
CREATE POLICY "owner_all_users" ON public.users
  FOR ALL USING (auth_role() = 'owner');

-- Admin: read + delete users within their company
CREATE POLICY "admin_read_company_users" ON public.users
  FOR SELECT USING (
    auth_role() = 'admin' AND company_id = auth_company_id()
  );

CREATE POLICY "admin_delete_company_users" ON public.users
  FOR DELETE USING (
    auth_role() = 'admin'
    AND company_id = auth_company_id()
    AND role = 'user'            -- Admin cannot delete other admins
  );

-- User: read and update their own record only
CREATE POLICY "user_read_own_profile" ON public.users
  FOR SELECT USING (auth_role() = 'user' AND id = auth.uid());

CREATE POLICY "user_update_own_profile" ON public.users
  FOR UPDATE USING (auth_role() = 'user' AND id = auth.uid());
```

---

### 6.3 `projects` RLS

```sql
-- Owner: read-only access to all projects (across all companies)
CREATE POLICY "owner_read_all_projects" ON public.projects
  FOR SELECT USING (auth_role() = 'owner');

-- Admin: read-only access to projects within their company
CREATE POLICY "admin_read_company_projects" ON public.projects
  FOR SELECT USING (
    auth_role() = 'admin' AND company_id = auth_company_id()
  );

-- User: full CRUD on their own projects only
CREATE POLICY "user_own_projects" ON public.projects
  FOR ALL USING (
    auth_role() = 'user' AND user_id = auth.uid()
  );
```

---

### 6.4 `cash_entries` RLS

```sql
-- Owner: read-only access to all cash entries
CREATE POLICY "owner_read_all_entries" ON public.cash_entries
  FOR SELECT USING (auth_role() = 'owner');

-- Admin: read-only access to cash entries within their company
CREATE POLICY "admin_read_company_entries" ON public.cash_entries
  FOR SELECT USING (
    auth_role() = 'admin' AND company_id = auth_company_id()
  );

-- User: full CRUD on their own entries only
CREATE POLICY "user_own_entries" ON public.cash_entries
  FOR ALL USING (
    auth_role() = 'user' AND user_id = auth.uid()
  );
```

---

### 6.5 `notifications` RLS

```sql
-- Owner: read access to all notifications (for oversight)
CREATE POLICY "owner_read_all_notifications" ON public.notifications
  FOR SELECT USING (auth_role() = 'owner');

-- Admin: full access to notifications in their company
CREATE POLICY "admin_own_company_notifications" ON public.notifications
  FOR ALL USING (
    auth_role() = 'admin' AND company_id = auth_company_id()
  );

-- User: INSERT only — user creates notifications, never reads them
CREATE POLICY "user_insert_notifications" ON public.notifications
  FOR INSERT WITH CHECK (
    auth_role() = 'user'
    AND triggered_by = auth.uid()
    AND company_id = auth_company_id()
  );
```

---

## 7. Storage Buckets

```
Supabase Storage
├── company-logos/     → Public bucket
│   └── {company_id}.{ext}
│
├── user-avatars/      → Public bucket
│   └── {user_id}.{ext}
│
└── receipt-images/    → Private bucket (RLS enforced)
    └── {company_id}/
        └── {user_id}/
            └── {entry_id}.{ext}
```

**Bucket Policies:**

| Bucket | Read | Write | Delete |
|---|---|---|---|
| `company-logos` | Public | Owner only | Owner only |
| `user-avatars` | Public | Own user only | Own user only |
| `receipt-images` | Own user + Admin (same company) + Owner | Own user only | Own user + pg_cron |

> **Images Tab** في Project Details يعرض الـ `receipt_url` من `cash_entries` مباشرة — لا يحتاج bucket منفصل.

---

## 8. Image Expiry — pg_cron Job

```sql
-- Enable pg_cron extension (done once in Supabase dashboard)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Job runs every day at 02:00 AM UTC
SELECT cron.schedule(
  'expire-receipts-daily',
  '0 2 * * *',
  $$
  UPDATE public.cash_entries
  SET
    receipt_url     = NULL,
    receipt_expired = TRUE,
    updated_at      = now()
  WHERE
    receipt_expired = FALSE
    AND receipt_expires_at <= now()
    AND receipt_url IS NOT NULL;
  $$
);
```

> **Note:** The pg_cron job sets `receipt_url = NULL` and flags the record. A companion **Supabase Edge Function** (HTTP cron) handles the actual file deletion from Storage using the Admin API.

---

## 9. Notification Auto-Insert Function

> Called from the Flutter app via Supabase RPC when a user performs a CRUD action.

```sql
CREATE OR REPLACE FUNCTION create_notification(
  p_type          notification_type,
  p_project_name  TEXT,
  p_project_id    UUID DEFAULT NULL,
  p_entry_name    TEXT DEFAULT NULL,
  p_message_ar    TEXT DEFAULT NULL,
  p_message_en    TEXT DEFAULT NULL
)
RETURNS void AS $$
DECLARE
  v_engineer_name TEXT;
  v_company_id    UUID;
  v_message       TEXT;
BEGIN
  -- Get current user's name and company
  SELECT full_name, company_id
  INTO v_engineer_name, v_company_id
  FROM public.users
  WHERE id = auth.uid();

  -- Build message: use provided message or auto-generate
  v_message := COALESCE(p_message_ar, CASE p_type
    WHEN 'new_assignment'   THEN 'تم إنشاء مشروع جديد: ' || p_project_name
    WHEN 'update_log'       THEN 'تم تعديل بند ' || COALESCE(p_entry_name, '') || ' في مشروع ' || p_project_name
    WHEN 'structural_alert' THEN 'تم حذف بند ' || COALESCE(p_entry_name, '') || ' من مشروع ' || p_project_name
    WHEN 'archived'         THEN 'تم حذف مشروع ' || p_project_name
    ELSE p_project_name
  END);

  -- Insert notification
  INSERT INTO public.notifications (
    company_id,
    triggered_by,
    type,
    message,
    project_name,
    entry_name,
    engineer_name,
    project_id
  ) VALUES (
    v_company_id,
    auth.uid(),
    p_type,
    v_message,
    p_project_name,
    p_entry_name,
    v_engineer_name,
    p_project_id
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Usage from Flutter:**
```dart
// User creates a project
await supabase.rpc('create_notification', params: {
  'p_type': 'new_assignment',
  'p_project_name': project.name,
  'p_project_id': project.id,
});

// User edits a cash entry
await supabase.rpc('create_notification', params: {
  'p_type': 'update_log',
  'p_project_name': project.name,
  'p_project_id': project.id,
  'p_entry_name': entry.entryName,
});

// User deletes a cash entry
await supabase.rpc('create_notification', params: {
  'p_type': 'structural_alert',
  'p_project_name': project.name,
  'p_project_id': project.id,
  'p_entry_name': entry.entryName,
});

// User deletes a project (project_id = null — no navigation target)
await supabase.rpc('create_notification', params: {
  'p_type': 'archived',
  'p_project_name': project.name,
  'p_project_id': null,
});
```

---

## 10. Computed / Helper Views

```sql
-- Project totals view — used for home screen portfolio value
CREATE OR REPLACE VIEW project_totals AS
SELECT
  p.id              AS project_id,
  p.name            AS project_name,
  p.user_id,
  p.company_id,
  p.created_at,
  COALESCE(SUM(ce.amount), 0) AS total_amount,
  COUNT(ce.id)                AS entry_count
FROM public.projects p
LEFT JOIN public.cash_entries ce ON ce.project_id = p.id
GROUP BY p.id, p.name, p.user_id, p.company_id, p.created_at;

-- User portfolio summary — total across all projects
CREATE OR REPLACE VIEW user_portfolio AS
SELECT
  user_id,
  company_id,
  COUNT(id)                   AS total_projects,
  COALESCE(SUM(total_amount), 0) AS portfolio_value
FROM project_totals
GROUP BY user_id, company_id;
```

---

## 11. Schema Summary

| Table | Rows (Expected v1) | Key Relations |
|---|---|---|
| `companies` | 10–200 | Root tenant entity |
| `users` | 100–5,000 | Belongs to company |
| `projects` | 500–50,000 | Belongs to user + company |
| `cash_entries` | 5,000–500,000 | Belongs to project + user + company. receipt_url nullable |
| `notifications` | 1,000–50,000 | Scoped to company |

---

## 12. Entity Relationship (Quick Reference)

```
companies
  ├── id (PK)
  └── ─────────────────────────────┐
                                   │
users                              │
  ├── id (PK)                      │
  ├── company_id (FK → companies) ─┘
  └── ─────────────────────────────┐
                                   │
projects                           │
  ├── id (PK)                      │
  ├── user_id    (FK → users)      │
  ├── company_id (FK → companies) ─┘
  └── ─────────────────────────────┐
                                   │
cash_entries                       │
  ├── id (PK)                      │
  ├── project_id (FK → projects) ──┘
  ├── user_id    (FK → users)
  ├── company_id (FK → companies)
  ├── entry_name
  ├── amount
  ├── entry_date
  ├── receipt_url        ← nullable (TEXT)
  ├── receipt_expires_at ← upload_date + 30 days
  └── receipt_expired    ← flag set by pg_cron

notifications
  ├── id (PK)
  ├── company_id   (FK → companies)
  ├── triggered_by (FK → users)
  ├── project_id   (FK nullable → projects)
  ├── type
  ├── message       (snapshot)
  ├── project_name  (snapshot)
  ├── entry_name    (snapshot)
  ├── engineer_name (snapshot)
  └── is_read
```
