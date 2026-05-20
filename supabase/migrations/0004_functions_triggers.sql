-- 0004_functions_triggers.sql

-- ─────────────────────────────────────────────
-- 1. updated_at auto-trigger (applied to all mutable tables)
-- ─────────────────────────────────────────────
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

-- ─────────────────────────────────────────────
-- 2. Receipt expiry auto-set trigger
-- ─────────────────────────────────────────────
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

-- ─────────────────────────────────────────────
-- 3. handle_new_user: atomically creates public.users row
--    when an auth.users row is inserted (CC-1 mitigation).
--    Edge Function admin-create-user writes full_name / role / company_id
--    into raw_user_meta_data; this trigger reads them.
-- ─────────────────────────────────────────────
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

-- ─────────────────────────────────────────────
-- 4. Helper functions (used by RLS policies)
-- ─────────────────────────────────────────────
CREATE OR REPLACE FUNCTION auth_role()
RETURNS user_role AS $$
  SELECT role FROM public.users WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION auth_company_id()
RETURNS UUID AS $$
  SELECT company_id FROM public.users WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;
