-- 0002_tables.sql
-- Tables in FK dependency order

-- 1. companies
CREATE TABLE public.companies (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT        NOT NULL,
  logo_url   TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. users (extends auth.users)
CREATE TABLE public.users (
  id         UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name  TEXT        NOT NULL,
  email      TEXT        NOT NULL UNIQUE,
  role       user_role   NOT NULL DEFAULT 'user',
  company_id UUID        REFERENCES public.companies(id) ON DELETE CASCADE,
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Owner must have NULL company_id; admin and user must belong to a company
ALTER TABLE public.users ADD CONSTRAINT users_company_role_check
  CHECK (
    (role = 'owner' AND company_id IS NULL) OR
    (role IN ('admin', 'user') AND company_id IS NOT NULL)
  );

-- 3. projects
CREATE TABLE public.projects (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT        NOT NULL,
  user_id    UUID        NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  company_id UUID        NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. cash_entries
-- client_request_id: idempotency key (CC-3 / CLAUDE.md requirement)
-- amount CHECK (amount > 0): PRD F-20 server-side enforcement
CREATE TABLE public.cash_entries (
  id                  UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id          UUID           NOT NULL REFERENCES public.projects(id)  ON DELETE CASCADE,
  user_id             UUID           NOT NULL REFERENCES public.users(id)     ON DELETE CASCADE,
  company_id          UUID           NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  entry_name          TEXT           NOT NULL,
  amount              NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
  entry_date          DATE           NOT NULL,
  client_request_id   UUID           NOT NULL,
  receipt_url         TEXT,
  receipt_uploaded_at TIMESTAMPTZ,
  receipt_expires_at  TIMESTAMPTZ,
  receipt_expired     BOOLEAN        NOT NULL DEFAULT FALSE,
  created_at          TIMESTAMPTZ    NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ    NOT NULL DEFAULT now()
);

-- 5. notifications
CREATE TABLE public.notifications (
  id            UUID              PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id    UUID              NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  triggered_by  UUID              NOT NULL REFERENCES public.users(id)     ON DELETE CASCADE,
  type          notification_type NOT NULL,
  message       TEXT              NOT NULL,
  project_name  TEXT              NOT NULL,
  entry_name    TEXT,
  engineer_name TEXT              NOT NULL,
  project_id    UUID              REFERENCES public.projects(id) ON DELETE SET NULL,
  is_read       BOOLEAN           NOT NULL DEFAULT FALSE,
  created_at    TIMESTAMPTZ       NOT NULL DEFAULT now()
);
