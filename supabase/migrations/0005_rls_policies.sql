-- 0005_rls_policies.sql

-- Enable RLS on all tables
ALTER TABLE public.companies     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cash_entries  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- ─────────────────────────────────────────────
-- companies
-- ─────────────────────────────────────────────
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

-- ─────────────────────────────────────────────
-- users
-- ─────────────────────────────────────────────
CREATE POLICY "owner_all_users" ON public.users
  FOR ALL USING (auth_role() = 'owner');

CREATE POLICY "admin_read_company_users" ON public.users
  FOR SELECT USING (
    auth_role() = 'admin' AND company_id = auth_company_id()
  );

-- Admin can only delete engineers (role='user') within their own company
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

-- ─────────────────────────────────────────────
-- projects
-- ─────────────────────────────────────────────
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

-- ─────────────────────────────────────────────
-- cash_entries
-- ─────────────────────────────────────────────
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

-- ─────────────────────────────────────────────
-- notifications
-- ─────────────────────────────────────────────
CREATE POLICY "owner_read_all_notifications" ON public.notifications
  FOR SELECT USING (auth_role() = 'owner');

CREATE POLICY "admin_own_company_notifications" ON public.notifications
  FOR ALL USING (
    auth_role() = 'admin' AND company_id = auth_company_id()
  );

-- Users only INSERT (via create_notification RPC) — never SELECT or DELETE
CREATE POLICY "user_insert_notifications" ON public.notifications
  FOR INSERT WITH CHECK (
    auth_role() = 'user'
    AND triggered_by = auth.uid()
    AND company_id = auth_company_id()
  );
