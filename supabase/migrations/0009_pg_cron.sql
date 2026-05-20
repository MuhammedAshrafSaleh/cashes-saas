-- 0009_pg_cron.sql
-- Requires pg_cron extension enabled in the Supabase dashboard
-- (Database → Extensions → pg_cron).
-- Also requires pg_net for the HTTP-based storage cleanup job.

CREATE EXTENSION IF NOT EXISTS pg_cron;

-- ─────────────────────────────────────────────
-- Job 1: Nullify expired receipt URLs daily at 02:00 UTC
-- Sets receipt_url = NULL and flags receipt_expired = TRUE.
-- The actual file deletion is handled by the Edge Function below.
-- ─────────────────────────────────────────────
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

-- ─────────────────────────────────────────────
-- Job 2: Trigger the expire-receipts-storage Edge Function at 02:15 UTC
-- Runs after Job 1 so rows are already flagged before the function lists them.
-- Replace <project-url> and the vault secret reference before deploying.
-- The service key must be stored in Supabase Vault — never hard-coded.
-- ─────────────────────────────────────────────
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
