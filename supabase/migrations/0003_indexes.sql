-- 0003_indexes.sql

-- users
CREATE INDEX idx_users_company_id ON public.users(company_id);
CREATE INDEX idx_users_role       ON public.users(role);

-- projects
CREATE INDEX idx_projects_user_id    ON public.projects(user_id);
CREATE INDEX idx_projects_company_id ON public.projects(company_id);

-- cash_entries
CREATE INDEX idx_cash_entries_project_id ON public.cash_entries(project_id);
CREATE INDEX idx_cash_entries_company_id ON public.cash_entries(company_id);

-- Partial index for pg_cron expiry queries (only non-expired rows)
CREATE INDEX idx_cash_entries_expires_at ON public.cash_entries(receipt_expires_at)
  WHERE receipt_expired = FALSE;

-- Idempotency: prevents duplicate cash entries from double-tap (CC-3)
CREATE UNIQUE INDEX uniq_cash_entries_idempotency
  ON public.cash_entries(user_id, client_request_id);

-- notifications
CREATE INDEX idx_notifications_company_id ON public.notifications(company_id);

-- Partial index — only unread rows (used for badge count queries)
CREATE INDEX idx_notifications_unread ON public.notifications(company_id, is_read)
  WHERE is_read = FALSE;
