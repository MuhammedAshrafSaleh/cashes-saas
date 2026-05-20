# Supabase Setup Status

## ✅ Done Manually (Do NOT redo these)

- Supabase project created → `cashes-app`
- Region: `eu-west-1` (West EU - Ireland)
- Project URL: `https://fvlkfbqqppkjzhrxtjbg.supabase.co`
- Publishable key: stored in `.env` as `SUPABASE_ANON_KEY`
- Auth → Email provider enabled, email confirmation OFF
- Auth → Password reset email template customized (Arabic)
- Auth → Redirect URL configured for deep link
- Owner account created in Auth dashboard
- Storage buckets created:
  - `company-logos` → public
  - `user-avatars` → public
  - `receipt-images` → private

---

## ❌ Not Done Yet (Claude Code handles these)

### 1. SQL Setup (run via Supabase CLI or SQL Editor)
- [ ] Enums: `user_role`, `notification_type`
- [ ] Tables: `companies`, `users`, `projects`, `cash_entries`, `notifications`
- [ ] Indexes on all tables
- [ ] Triggers: `updated_at`, `receipt_expiry`, `handle_new_user` (auth sync)
- [ ] Helper functions: `auth_role()`, `auth_company_id()`
- [ ] RPC function: `create_notification()`
- [ ] View: `project_totals`
- [ ] RLS policies on all 5 tables
- [ ] pg_cron job: `expire-receipts-daily`

### 2. After SQL is done (one manual step)
- [ ] Run this query to set Owner role:
```sql
UPDATE public.users
SET role = 'owner', company_id = NULL
WHERE email = 'YOUR_OWNER_EMAIL_HERE';
```

### 3. Flutter Project
- [ ] Create Flutter project with Clean Architecture + Cubit
- [ ] Setup `.env` with Supabase keys
- [ ] Implement all features F-01 → F-22

---

## Project Keys (use from .env only)

```
SUPABASE_URL=https://fvlkfbqqppkjzhrxtjbg.supabase.co
SUPABASE_ANON_KEY=sb_publishable_SIf5qpvp8Dvo4psBNm_d_w_OqLYB3I0
```

> ⚠️ Never use the secret key in Flutter code
