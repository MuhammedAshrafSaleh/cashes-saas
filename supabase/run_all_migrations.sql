-- ============================================================
-- Cashes App — Full Database Migration
-- Run this once in the Supabase SQL Editor (Dashboard → SQL Editor)
-- Order: enums → tables → indexes → functions/triggers →
--        rls → storage policies → views → notification rpc → pg_cron
-- ============================================================


-- ─────────────────────────────────────────────
-- 0001: Enums
-- ─────────────────────────────────────────────

CREATE TYPE user_role AS ENUM ('owner', 'admin', 'user');

CREATE TYPE notification_type AS ENUM (
  'new_assignment',
  'update_log',
  'structural_alert',
  'archived'
);


-- ─────────────────────────────────────────────
-- 0002: Tables (FK dependency order)
-- ─────────────────────────────────────────────

CREATE TABLE public.companies (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT        NOT NULL,
  logo_url   TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

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

ALTER TABLE public.users ADD CONSTRAINT users_company_role_check
  CHECK (
    (role = 'owner' AND company_id IS NULL) OR
    (role IN ('admin', 'user') AND company_id IS NOT NULL)
  );

CREATE TABLE public.projects (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT        NOT NULL,
  user_id    UUID        NOT NULL REFERENCES public.users(id)    ON DELETE CASCADE,
  company_id UUID        NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

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

CREATE TABLE public.notifications (
  id            UUID              PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id    UUID              NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  triggered_by  UUID              NOT NULL REFERENCES public.users(id)    ON DELETE CASCADE,
  type          notification_type NOT NULL,
  message       TEXT              NOT NULL,
  project_name  TEXT              NOT NULL,
  entry_name    TEXT,
  engineer_name TEXT              NOT NULL,
  project_id    UUID              REFERENCES public.projects(id) ON DELETE SET NULL,
  is_read       BOOLEAN           NOT NULL DEFAULT FALSE,
  created_at    TIMESTAMPTZ       NOT NULL DEFAULT now()
);


-- ─────────────────────────────────────────────
-- 0003: Indexes
-- ─────────────────────────────────────────────

CREATE INDEX idx_users_company_id ON public.users(company_id);
CREATE INDEX idx_users_role       ON public.users(role);

CREATE INDEX idx_projects_user_id    ON public.projects(user_id);
CREATE INDEX idx_projects_company_id ON public.projects(company_id);

CREATE INDEX idx_cash_entries_project_id ON public.cash_entries(project_id);
CREATE INDEX idx_cash_entries_company_id ON public.cash_entries(company_id);

CREATE INDEX idx_cash_entries_expires_at ON public.cash_entries(receipt_expires_at)
  WHERE receipt_expired = FALSE;

CREATE UNIQUE INDEX uniq_cash_entries_idempotency
  ON public.cash_entries(user_id, client_request_id);

CREATE INDEX idx_notifications_company_id ON public.notifications(company_id);

CREATE INDEX idx_notifications_unread ON public.notifications(company_id, is_read)
  WHERE is_read = FALSE;


-- ─────────────────────────────────────────────
-- 0004: Functions & Triggers
-- ─────────────────────────────────────────────

-- 1. updated_at auto-trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

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

-- 2. Receipt expiry auto-set trigger
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

-- 3. Sync auth.users → public.users on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, full_name, email, role, company_id)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    NEW.email,
    COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'user'),
    NULLIF(NEW.raw_user_meta_data->>'company_id', '')::UUID
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- 4. RLS helper functions
CREATE OR REPLACE FUNCTION auth_role()
RETURNS user_role AS $$
  SELECT role FROM public.users WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION auth_company_id()
RETURNS UUID AS $$
  SELECT company_id FROM public.users WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;


-- ─────────────────────────────────────────────
-- 0005: RLS Policies
-- ─────────────────────────────────────────────

ALTER TABLE public.companies     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cash_entries  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- companies
CREATE POLICY "owner_all_companies" ON public.companies
  FOR ALL USING (auth_role() = 'owner');

CREATE POLICY "admin_read_own_company" ON public.companies
  FOR SELECT USING (
    auth_role() = 'admin' AND id = auth_company_id()
  );

CREATE POLICY "user_read_own_company" ON public.companies
  FOR SELECT USING (
    auth_role() = 'user' AND id = auth_company_id()
  );

-- users
CREATE POLICY "owner_all_users" ON public.users
  FOR ALL USING (auth_role() = 'owner');

CREATE POLICY "admin_read_company_users" ON public.users
  FOR SELECT USING (
    auth_role() = 'admin' AND company_id = auth_company_id()
  );

CREATE POLICY "admin_delete_company_users" ON public.users
  FOR DELETE USING (
    auth_role() = 'admin'
    AND company_id = auth_company_id()
    AND role = 'user'
  );

CREATE POLICY "user_read_own_profile" ON public.users
  FOR SELECT USING (auth_role() = 'user' AND id = auth.uid());

CREATE POLICY "user_update_own_profile" ON public.users
  FOR UPDATE USING (auth_role() = 'user' AND id = auth.uid());

-- projects
CREATE POLICY "owner_read_all_projects" ON public.projects
  FOR SELECT USING (auth_role() = 'owner');

CREATE POLICY "admin_read_company_projects" ON public.projects
  FOR SELECT USING (
    auth_role() = 'admin' AND company_id = auth_company_id()
  );

CREATE POLICY "user_own_projects" ON public.projects
  FOR ALL USING (
    auth_role() = 'user' AND user_id = auth.uid()
  );

-- cash_entries
CREATE POLICY "owner_read_all_entries" ON public.cash_entries
  FOR SELECT USING (auth_role() = 'owner');

CREATE POLICY "admin_read_company_entries" ON public.cash_entries
  FOR SELECT USING (
    auth_role() = 'admin' AND company_id = auth_company_id()
  );

CREATE POLICY "user_own_entries" ON public.cash_entries
  FOR ALL USING (
    auth_role() = 'user' AND user_id = auth.uid()
  );

-- notifications
CREATE POLICY "owner_read_all_notifications" ON public.notifications
  FOR SELECT USING (auth_role() = 'owner');

CREATE POLICY "admin_own_company_notifications" ON public.notifications
  FOR ALL USING (
    auth_role() = 'admin' AND company_id = auth_company_id()
  );

CREATE POLICY "user_insert_notifications" ON public.notifications
  FOR INSERT WITH CHECK (
    auth_role() = 'user'
    AND triggered_by = auth.uid()
    AND company_id = auth_company_id()
  );


-- ─────────────────────────────────────────────
-- 0006: Storage Policies
-- ─────────────────────────────────────────────

-- receipt-images (private)
CREATE POLICY "receipt_user_write" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'receipt-images'
    AND (storage.foldername(name))[2] = auth.uid()::text
  );

CREATE POLICY "receipt_user_read" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'receipt-images'
    AND (
      (storage.foldername(name))[2] = auth.uid()::text
      OR auth_role() = 'owner'
      OR (
        auth_role() = 'admin'
        AND (storage.foldername(name))[1] = auth_company_id()::text
      )
    )
  );

CREATE POLICY "receipt_user_delete" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'receipt-images'
    AND (storage.foldername(name))[2] = auth.uid()::text
  );

-- company-logos (public bucket — restrict writes to owner)
CREATE POLICY "logo_owner_write" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'company-logos'
    AND auth_role() = 'owner'
  );

CREATE POLICY "logo_owner_modify" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'company-logos'
    AND auth_role() = 'owner'
  );

CREATE POLICY "logo_owner_delete" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'company-logos'
    AND auth_role() = 'owner'
  );

-- user-avatars (public bucket — restrict writes to own user)
CREATE POLICY "avatar_self_write" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'user-avatars'
    AND storage.filename(name) LIKE auth.uid()::text || '.%'
  );

CREATE POLICY "avatar_self_modify" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'user-avatars'
    AND storage.filename(name) LIKE auth.uid()::text || '.%'
  );

CREATE POLICY "avatar_self_delete" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'user-avatars'
    AND storage.filename(name) LIKE auth.uid()::text || '.%'
  );


-- ─────────────────────────────────────────────
-- 0007: Views
-- ─────────────────────────────────────────────

CREATE OR REPLACE VIEW project_totals AS
SELECT
  p.id                         AS project_id,
  p.name                       AS project_name,
  p.user_id,
  p.company_id,
  p.created_at,
  COALESCE(SUM(ce.amount), 0) AS total_amount,
  COUNT(ce.id)                 AS entry_count
FROM public.projects p
LEFT JOIN public.cash_entries ce ON ce.project_id = p.id
GROUP BY p.id, p.name, p.user_id, p.company_id, p.created_at;

CREATE OR REPLACE VIEW user_portfolio AS
SELECT
  user_id,
  company_id,
  COUNT(project_id)              AS total_projects,
  COALESCE(SUM(total_amount), 0) AS portfolio_value
FROM project_totals
GROUP BY user_id, company_id;


-- ─────────────────────────────────────────────
-- 0008: create_notification RPC
-- ─────────────────────────────────────────────

CREATE OR REPLACE FUNCTION create_notification(
  p_type         notification_type,
  p_project_name TEXT,
  p_project_id   UUID DEFAULT NULL,
  p_entry_name   TEXT DEFAULT NULL,
  p_message_ar   TEXT DEFAULT NULL,
  p_message_en   TEXT DEFAULT NULL
)
RETURNS void AS $$
DECLARE
  v_engineer_name TEXT;
  v_company_id    UUID;
  v_message       TEXT;
BEGIN
  SELECT full_name, company_id
  INTO v_engineer_name, v_company_id
  FROM public.users
  WHERE id = auth.uid();

  v_message := COALESCE(p_message_ar, CASE p_type
    WHEN 'new_assignment'   THEN 'تم إنشاء مشروع جديد: '                          || p_project_name
    WHEN 'update_log'       THEN 'تم تعديل بند '   || COALESCE(p_entry_name, '') || ' في مشروع ' || p_project_name
    WHEN 'structural_alert' THEN 'تم حذف بند '     || COALESCE(p_entry_name, '') || ' من مشروع ' || p_project_name
    WHEN 'archived'         THEN 'تم حذف مشروع '                                  || p_project_name
    ELSE p_project_name
  END);

  INSERT INTO public.notifications (
    company_id, triggered_by, type, message,
    project_name, entry_name, engineer_name, project_id
  ) VALUES (
    v_company_id, auth.uid(), p_type, v_message,
    p_project_name, p_entry_name, v_engineer_name, p_project_id
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ─────────────────────────────────────────────
-- 0009: pg_cron jobs
-- NOTE: Enable pg_cron extension first in Dashboard → Database → Extensions
-- NOTE: Enable pg_net extension for the HTTP job
-- ─────────────────────────────────────────────

CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Job 1: Nullify expired receipt URLs daily at 02:00 UTC
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
    receipt_expired  = FALSE
    AND receipt_expires_at <= now()
    AND receipt_url IS NOT NULL;
  $$
);

-- Job 2: Trigger Edge Function to delete files from Storage at 02:15 UTC
-- Requires the 'expire-receipts-storage' Edge Function to be deployed first.
SELECT cron.schedule(
  'expire-receipts-storage',
  '15 2 * * *',
  $$
  SELECT net.http_post(
    url     := 'https://fvlkfbqqppkjzhrxtjbg.supabase.co/functions/v1/expire-receipts-storage',
    headers := jsonb_build_object(
      'Authorization', 'Bearer ' || (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'service_role_key')
    )
  );
  $$
);


-- ─────────────────────────────────────────────
-- Post-migration: set the Owner account's role
-- Replace the email below with the actual owner email before running.
-- ─────────────────────────────────────────────

-- UPDATE public.users
-- SET role = 'owner', company_id = NULL
-- WHERE email = 'YOUR_OWNER_EMAIL_HERE';
