-- 0007_views.sql

-- Project totals — used for home screen portfolio value and invoices tab summary
CREATE OR REPLACE VIEW project_totals AS
SELECT
  p.id                          AS project_id,
  p.name                        AS project_name,
  p.user_id,
  p.company_id,
  p.created_at,
  COALESCE(SUM(ce.amount), 0)  AS total_amount,
  COUNT(ce.id)                  AS entry_count
FROM public.projects p
LEFT JOIN public.cash_entries ce ON ce.project_id = p.id
GROUP BY p.id, p.name, p.user_id, p.company_id, p.created_at;

-- User portfolio summary — aggregate across all of a user's projects
CREATE OR REPLACE VIEW user_portfolio AS
SELECT
  user_id,
  company_id,
  COUNT(project_id)                   AS total_projects,
  COALESCE(SUM(total_amount), 0)      AS portfolio_value
FROM project_totals
GROUP BY user_id, company_id;
