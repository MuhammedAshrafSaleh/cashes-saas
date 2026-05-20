# Cashes App — Implementation Plan

> **Target output path:** `D:\Flutter\Projects\cashes saas\cashes\plan.md` (mirrored on ExitPlanMode approval)
> **Source of truth:** `docs/business_requirements.md`, `docs/PRD.md`, `docs/supabase_schema.md`, `docs/supabase_status.md`, `docs/corner_case_analysis.md`, `CLAUDE.md`

---

## 0. Context

Cashes is a multi-tenant SaaS Flutter app (iOS + Android) for construction/finishing companies. Three roles — **Owner** (CEO, super-admin), **Admin** (per-company accountant, read-only), **User** (site engineer, data producer). Stack: Flutter + Cubit + Clean Architecture + Supabase (Postgres + Auth + Storage + Edge Functions + pg_cron). Arabic RTL default, Dark theme default.

**Starting state:** Supabase project provisioned (`cashes-app`, eu-west-1) with Auth + 3 storage buckets created and Owner auth row in place; **no SQL ran yet**. Flutter project is bare boilerplate (default counter app). `pubspec.yaml` has only flutter_lints + cupertino_icons.

**Outcome:** A production-ready v1.0 covering 22 features (F-01→F-22) / 20 screens / 5 DB tables / 3 roles, with cascade deletes, RLS multi-tenant isolation, 30-day receipt-image lifecycle, PDF export with embedded Arabic font, and all 5 critical corner cases handled.

**Two architecture decisions confirmed by user before planning:**
1. User CRUD goes through **2 Supabase Edge Functions** (`admin-create-user`, `admin-delete-user`) — service_role lives only server-side.
2. PDF export bundles **Cairo** (Regular + Bold) font assets for Arabic glyph rendering.

---

## 1. Supabase Setup Plan

Already done (skip): project, auth provider, 3 storage buckets (`company-logos` public, `user-avatars` public, `receipt-images` private), Owner auth user. Everything below runs once via Supabase SQL Editor in this exact order.

### 1.1 Enums
```sql
CREATE TYPE user_role AS ENUM ('owner', 'admin', 'user');
CREATE TYPE notification_type AS ENUM (
  'new_assignment', 'update_log', 'structural_alert', 'archived'
);
```

### 1.2 Tables (in FK dependency order)
1. `companies` — id PK, name, logo_url, created_at, updated_at
2. `users` — id PK FK→auth.users ON DELETE CASCADE, full_name, email UNIQUE, role enum, company_id FK→companies ON DELETE CASCADE (nullable for owner), avatar_url, created_at, updated_at + CHECK constraint `(role='owner' AND company_id IS NULL) OR (role IN ('admin','user') AND company_id IS NOT NULL)`
3. `projects` — id PK, name, user_id FK→users CASCADE, company_id FK→companies CASCADE, created_at, updated_at
4. `cash_entries` — id PK, project_id FK CASCADE, user_id FK CASCADE, company_id FK CASCADE, entry_name, amount NUMERIC(12,2) CHECK (amount > 0), entry_date DATE, receipt_url nullable, receipt_uploaded_at, receipt_expires_at, receipt_expired BOOLEAN DEFAULT FALSE, **`client_request_id UUID NOT NULL`** (idempotency — CC-3), created_at, updated_at
5. `notifications` — id PK, company_id FK CASCADE, triggered_by FK→users CASCADE, type enum, message TEXT, project_name (snapshot), entry_name (snapshot, nullable), engineer_name (snapshot), project_id FK→projects ON DELETE SET NULL, is_read BOOLEAN DEFAULT FALSE, created_at

> **Schema additions over docs/supabase_schema.md:**
> - `cash_entries.client_request_id` column + partial unique index — required by CC-3 / CLAUDE.md, not yet in the schema doc.
> - `cash_entries.amount` adds `CHECK (amount > 0)` to enforce PRD F-20 server-side.

### 1.3 Indexes
- `idx_users_company_id`, `idx_users_role`
- `idx_projects_user_id`, `idx_projects_company_id`
- `idx_cash_entries_project_id`, `idx_cash_entries_company_id`
- `idx_cash_entries_expires_at` (partial WHERE receipt_expired=FALSE)
- **`uniq_cash_entries_idempotency` partial UNIQUE INDEX on `(user_id, client_request_id)`** (CC-3)
- `idx_notifications_company_id`, `idx_notifications_unread` (partial WHERE is_read=FALSE)

### 1.4 Auto-trigger functions
```sql
-- updated_at trigger function (apply to all 4 mutable tables)
CREATE OR REPLACE FUNCTION update_updated_at() RETURNS TRIGGER ...
CREATE TRIGGER trg_<table>_updated_at BEFORE UPDATE ON <table> ...

-- receipt expiry trigger (BEFORE INSERT OR UPDATE on cash_entries)
CREATE OR REPLACE FUNCTION set_receipt_expiry() RETURNS TRIGGER
  -- if receipt_url IS NOT NULL → receipt_expires_at = receipt_uploaded_at + INTERVAL '30 days'

-- handle_new_user trigger (AFTER INSERT ON auth.users) — CC-1 mitigation
CREATE OR REPLACE FUNCTION handle_new_user() RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, full_name, email, role, company_id)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    NEW.email,
    COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'user'),
    NULLIF(NEW.raw_user_meta_data->>'company_id','')::UUID
  );
  RETURN NEW;
END; $$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```

> Edge Function `admin-create-user` will call `auth.admin.createUser` with `user_metadata = {full_name, role, company_id}`. The trigger above reads those and atomically creates the matching `public.users` row — eliminates CC-1 race entirely.

### 1.5 Helper functions (SECURITY DEFINER, STABLE)
```sql
CREATE OR REPLACE FUNCTION auth_role() RETURNS user_role ...
CREATE OR REPLACE FUNCTION auth_company_id() RETURNS UUID ...
```

### 1.6 RPC: `create_notification`
As defined in supabase_schema.md §9 — SECURITY DEFINER, reads auth.uid() / company_id, inserts notification with snapshot fields and message template.

### 1.7 Views
- `project_totals` (project_id, project_name, user_id, company_id, created_at, total_amount, entry_count)
- `user_portfolio` (user_id, company_id, total_projects, portfolio_value)

### 1.8 Enable RLS + policies on all 5 tables
Verbatim from supabase_schema.md §6.1–§6.5. Recap:
- `companies`: owner ALL · admin/user SELECT own company
- `users`: owner ALL · admin SELECT+DELETE company (role='user' only) · user SELECT+UPDATE self
- `projects`: owner SELECT all · admin SELECT company · user ALL own
- `cash_entries`: owner SELECT all · admin SELECT company · user ALL own
- `notifications`: owner SELECT all · admin ALL company · user INSERT (via RPC anyway)

### 1.9 Storage bucket policies (must be added — not in schema doc as SQL)
```sql
-- receipt-images: own user write/delete; same-company admin read; owner read; user owns folder
CREATE POLICY "receipt_user_write" ON storage.objects FOR INSERT
  WITH CHECK (bucket_id='receipt-images' AND (storage.foldername(name))[2] = auth.uid()::text);
CREATE POLICY "receipt_user_read" ON storage.objects FOR SELECT
  USING (bucket_id='receipt-images' AND (
    (storage.foldername(name))[2] = auth.uid()::text
    OR auth_role()='owner'
    OR (auth_role()='admin' AND (storage.foldername(name))[1] = auth_company_id()::text)
  ));
CREATE POLICY "receipt_user_delete" ON storage.objects FOR DELETE
  USING (bucket_id='receipt-images' AND (storage.foldername(name))[2] = auth.uid()::text);

-- company-logos: owner write/delete; public read (bucket is public)
CREATE POLICY "logo_owner_write" ON storage.objects FOR INSERT
  WITH CHECK (bucket_id='company-logos' AND auth_role()='owner');
CREATE POLICY "logo_owner_modify" ON storage.objects FOR UPDATE
  USING (bucket_id='company-logos' AND auth_role()='owner');
CREATE POLICY "logo_owner_delete" ON storage.objects FOR DELETE
  USING (bucket_id='company-logos' AND auth_role()='owner');

-- user-avatars: own user write/delete
CREATE POLICY "avatar_self_write" ON storage.objects FOR INSERT
  WITH CHECK (bucket_id='user-avatars' AND (storage.filename(name)) LIKE auth.uid()::text || '.%');
CREATE POLICY "avatar_self_modify" ON storage.objects FOR UPDATE
  USING (bucket_id='user-avatars' AND (storage.filename(name)) LIKE auth.uid()::text || '.%');
CREATE POLICY "avatar_self_delete" ON storage.objects FOR DELETE
  USING (bucket_id='user-avatars' AND (storage.filename(name)) LIKE auth.uid()::text || '.%');
```

### 1.10 Edge Functions (TypeScript, deployed via `supabase functions deploy`)
- **`admin-create-user`** — verifies caller JWT role='owner', calls `auth.admin.createUser` with metadata, returns the new user row. Handles 409 duplicate-email.
- **`admin-delete-user`** — verifies caller is owner OR (admin AND target is `user` in caller's company), calls `auth.admin.deleteUser` → cascade fires through public.users → projects → cash_entries; also wipes target's receipt-images folder via storage API.
- **`expire-receipts-storage`** — invoked by pg_cron after the DB nullification: lists files whose entries have `receipt_expired=TRUE` AND row updated in the last 24h, deletes from storage. Idempotent.

### 1.11 pg_cron jobs
```sql
CREATE EXTENSION IF NOT EXISTS pg_cron;
-- Nullify expired receipt URLs daily 02:00 UTC
SELECT cron.schedule('expire-receipts-daily', '0 2 * * *',
  $$ UPDATE public.cash_entries
     SET receipt_url=NULL, receipt_expired=TRUE, updated_at=now()
     WHERE receipt_expired=FALSE AND receipt_expires_at<=now() AND receipt_url IS NOT NULL; $$);

-- Trigger storage cleanup Edge Function daily 02:15 UTC (requires pg_net + vault for service key)
SELECT cron.schedule('expire-receipts-storage', '15 2 * * *',
  $$ SELECT net.http_post(
       url := '<project-url>/functions/v1/expire-receipts-storage',
       headers := jsonb_build_object('Authorization', 'Bearer ' || <vault-stored-service-key>)
     ); $$);
```

### 1.12 Final manual step: promote the seeded Owner to `owner` role
```sql
UPDATE public.users
SET role='owner', company_id=NULL
WHERE email='<OWNER_EMAIL_FROM_DASHBOARD>';
```
*(The `handle_new_user` trigger will have created their row with default role='user' when the auth account was created in the dashboard — this one-time UPDATE flips it.)*

---

## 2. Flutter Project Structure

```
cashes/
├── lib/
│   ├── main.dart                                        # bootstrap: load env, initDI, Supabase.initialize, runApp
│   ├── app.dart                                         # MaterialApp.router + theme/locale Cubits + auth state listener
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_spacing.dart                         # xs=4, sm=8, md=16, lg=24, xl=32, xxl=48
│   │   │   ├── app_radius.dart                          # sm=8, md=12, lg=16, pill=999
│   │   │   ├── app_durations.dart                       # snackbar=3s, debounce=300ms, splashMin=1500ms
│   │   │   ├── app_storage_keys.dart                    # 'theme_mode', 'locale', 'cache_version'
│   │   │   ├── app_storage_buckets.dart                 # 'company-logos','user-avatars','receipt-images'
│   │   │   └── app_assets.dart                          # 'assets/fonts/Cairo-Regular.ttf', logo paths
│   │   ├── errors/
│   │   │   ├── exceptions.dart                          # ServerException, NetworkException, AuthException, ValidationException, PermissionException, NotFoundException
│   │   │   ├── failures.dart                            # Failure + 6 subclasses (Equatable)
│   │   │   └── error_mapper.dart                        # PostgrestException/AuthException → Failure (incl. user-deleted detection)
│   │   ├── network/
│   │   │   ├── supabase_client_provider.dart            # registers Supabase.instance.client in DI
│   │   │   ├── network_info.dart                        # NetworkInfo abstract + Impl over connectivity_plus
│   │   │   └── client_request_id.dart                   # ClientRequestIdGenerator (uuid v4)
│   │   ├── auth/
│   │   │   ├── session_guard.dart                       # listens to onAuthStateChange, force-logout on signedOut/userDeleted (CC-2,4)
│   │   │   └── auth_state_listener.dart                 # wires guard into app.dart
│   │   ├── router/
│   │   │   ├── app_router.dart                          # GoRouter config
│   │   │   ├── app_routes.dart                          # path constants
│   │   │   └── role_redirect.dart                       # redirect logic based on AuthCubit role
│   │   ├── theme/
│   │   │   ├── app_colors.dart                          # gold, danger, dark/light tokens
│   │   │   ├── app_text_theme.dart                      # TextTheme using Cairo font family
│   │   │   ├── app_theme.dart                           # dark (default) + light ThemeData
│   │   │   └── theme_cubit.dart + theme_state.dart      # toggles + persists via shared_preferences
│   │   ├── localization/
│   │   │   ├── l10n.yaml                                # arb-dir, template-arb-file
│   │   │   ├── app_ar.arb                               # all keys (primary)
│   │   │   ├── app_en.arb                               # all keys (mirror)
│   │   │   ├── locale_cubit.dart + locale_state.dart    # toggles + persists Locale
│   │   │   └── (generated) app_localizations.dart
│   │   ├── utils/
│   │   │   ├── image_compressor.dart                    # compute()-based; HEIC→JPEG; EXIF fix; quality=70 max=1080 ≤500KB (CC-5)
│   │   │   ├── image_picker_helper.dart                 # bottom sheet → permission_handler → image_picker
│   │   │   ├── pdf_generator.dart                       # compute()-based; uses Cairo font; expired-receipt fallback
│   │   │   ├── date_formatter.dart                      # intl dd/MM/yyyy AR + EN
│   │   │   ├── currency_formatter.dart                  # NumberFormat with comma separators
│   │   │   ├── input_formatters.dart                    # amount formatter (strips commas — CC-47)
│   │   │   ├── validators.dart                          # email, password (≥8), name (≥2 trimmed), amount > 0
│   │   │   └── app_logger.dart                          # wraps logger pkg
│   │   ├── widgets/
│   │   │   ├── app_snackbar.dart                        # success/error/warning/info — 3s, replaces previous
│   │   │   ├── confirm_dialog.dart                      # destructive (red) + non-destructive variants
│   │   │   ├── primary_button.dart                      # loading state baked in + double-tap guard
│   │   │   ├── secondary_button.dart
│   │   │   ├── danger_button.dart
│   │   │   ├── app_text_field.dart                      # supports prefix, suffix, validators, RTL
│   │   │   ├── empty_state.dart                         # icon + message
│   │   │   ├── error_state.dart                         # icon + message + retry
│   │   │   ├── loading_skeleton.dart                    # shimmer wrapper
│   │   │   ├── offline_banner.dart                      # listens to NetworkInfo stream
│   │   │   ├── read_only_banner.dart                    # "وضع المشاهدة فقط"
│   │   │   ├── expiry_warning_banner.dart               # 5-day warning for receipts
│   │   │   ├── app_avatar.dart                          # initials fallback on image error (CC-15)
│   │   │   ├── app_bottom_sheet.dart                    # standard sheet wrapper
│   │   │   ├── search_field.dart                        # debounced 300ms
│   │   │   └── will_pop_unsaved.dart                    # PopScope wrapper for dirty forms (CC-22)
│   │   ├── di/
│   │   │   └── injection.dart                           # GetIt manual registration of every service/repo/usecase/cubit
│   │   └── env/
│   │       └── env.dart                                 # reads SUPABASE_URL + SUPABASE_ANON_KEY from --dart-define
│   │
│   ├── features/
│   │   ├── auth/                                        # F-09..F-12
│   │   │   ├── data/
│   │   │   │   ├── datasources/auth_remote_data_source.dart
│   │   │   │   ├── models/auth_user_model.dart
│   │   │   │   └── repositories/auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/auth_user_entity.dart
│   │   │   │   ├── repositories/auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_current_session.dart
│   │   │   │       ├── sign_in.dart
│   │   │   │       ├── send_password_reset.dart
│   │   │   │       ├── sign_out.dart
│   │   │   │       └── watch_auth_changes.dart
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       │   ├── auth_cubit.dart                  # global — owns current user + role
│   │   │       │   ├── auth_state.dart
│   │   │       │   ├── login_cubit.dart + login_state.dart
│   │   │       │   ├── forgot_password_cubit.dart + state
│   │   │       │   └── splash_cubit.dart + splash_state.dart
│   │   │       ├── screens/
│   │   │       │   ├── splash_screen.dart               # F-09
│   │   │       │   ├── login_screen.dart                # F-10
│   │   │       │   ├── forgot_password_screen.dart      # F-11
│   │   │       │   └── email_sent_screen.dart           # F-12
│   │   │       └── widgets/
│   │   │           ├── auth_logo_header.dart
│   │   │           └── auth_text_field.dart
│   │   │
│   │   ├── owner/                                       # F-01..F-06
│   │   │   ├── companies/
│   │   │   │   ├── data/
│   │   │   │   │   ├── datasources/companies_remote_data_source.dart
│   │   │   │   │   ├── models/company_model.dart
│   │   │   │   │   └── repositories/companies_repository_impl.dart
│   │   │   │   ├── domain/
│   │   │   │   │   ├── entities/company_entity.dart
│   │   │   │   │   ├── entities/companies_overview_entity.dart  # totals
│   │   │   │   │   ├── repositories/companies_repository.dart
│   │   │   │   │   └── usecases/
│   │   │   │   │       ├── get_companies.dart
│   │   │   │   │       ├── get_companies_overview.dart
│   │   │   │   │       ├── create_company.dart
│   │   │   │   │       ├── update_company.dart
│   │   │   │   │       └── delete_company.dart
│   │   │   │   └── presentation/
│   │   │   │       ├── cubit/
│   │   │   │       │   ├── companies_cubit.dart + state         # F-01 list + overview
│   │   │   │       │   └── company_form_cubit.dart + state      # F-02/F-03
│   │   │   │       ├── screens/
│   │   │   │       │   ├── companies_list_screen.dart           # F-01
│   │   │   │       │   ├── add_company_screen.dart              # F-02
│   │   │   │       │   └── edit_company_screen.dart             # F-03
│   │   │   │       └── widgets/
│   │   │   │           ├── company_card.dart
│   │   │   │           ├── companies_overview_footer.dart       # Total Users / Total Companies cards
│   │   │   │           ├── company_logo_picker.dart
│   │   │   │           └── owner_action_buttons.dart            # +ADD COMPANY / +ADD USER row
│   │   │   └── users/
│   │   │       ├── data/
│   │   │       │   ├── datasources/owner_users_remote_data_source.dart  # invokes Edge Functions
│   │   │       │   ├── models/user_model.dart
│   │   │       │   └── repositories/owner_users_repository_impl.dart
│   │   │       ├── domain/
│   │   │       │   ├── entities/user_entity.dart
│   │   │       │   ├── repositories/owner_users_repository.dart
│   │   │       │   └── usecases/
│   │   │       │       ├── get_users_by_company.dart
│   │   │       │       ├── create_user.dart                     # → admin-create-user
│   │   │       │       ├── update_user.dart
│   │   │       │       └── delete_user.dart                     # → admin-delete-user
│   │   │       └── presentation/
│   │   │           ├── cubit/
│   │   │           │   ├── owner_users_list_cubit.dart + state  # F-06
│   │   │           │   └── user_form_cubit.dart + state         # F-04/F-05
│   │   │           ├── screens/
│   │   │           │   ├── owner_users_list_screen.dart         # F-06
│   │   │           │   ├── create_user_screen.dart              # F-04
│   │   │           │   └── edit_user_screen.dart                # F-05
│   │   │           └── widgets/
│   │   │               └── user_card.dart
│   │   │
│   │   ├── admin/                                       # F-07, F-08
│   │   │   ├── users/
│   │   │   │   ├── data/datasources/admin_users_remote_data_source.dart
│   │   │   │   ├── data/repositories/admin_users_repository_impl.dart
│   │   │   │   ├── domain/repositories/admin_users_repository.dart
│   │   │   │   ├── domain/usecases/
│   │   │   │   │   ├── get_company_engineers.dart
│   │   │   │   │   └── delete_company_user.dart           # → admin-delete-user
│   │   │   │   └── presentation/
│   │   │   │       ├── cubit/admin_users_cubit.dart + state
│   │   │   │       ├── screens/admin_users_screen.dart    # F-07
│   │   │   │       └── widgets/admin_user_card.dart
│   │   │   ├── notifications/
│   │   │   │   ├── data/datasources/notifications_remote_data_source.dart
│   │   │   │   ├── data/models/notification_model.dart
│   │   │   │   ├── data/repositories/notifications_repository_impl.dart
│   │   │   │   ├── domain/entities/notification_entity.dart
│   │   │   │   ├── domain/repositories/notifications_repository.dart
│   │   │   │   ├── domain/usecases/
│   │   │   │   │   ├── get_company_notifications.dart
│   │   │   │   │   ├── mark_notification_read.dart
│   │   │   │   │   ├── delete_notification.dart
│   │   │   │   │   └── get_unread_count.dart
│   │   │   │   └── presentation/
│   │   │   │       ├── cubit/notifications_cubit.dart + state
│   │   │   │       ├── cubit/notifications_badge_cubit.dart + state
│   │   │   │       ├── screens/admin_notifications_screen.dart   # F-08
│   │   │   │       └── widgets/
│   │   │   │           ├── notification_card.dart                # color-coded type tag
│   │   │   │           └── notification_type_chip.dart
│   │   │   └── shell/
│   │   │       └── presentation/screens/admin_shell_screen.dart  # bottom nav: Users | Notifications
│   │   │
│   │   ├── settings/                                    # F-13, F-14
│   │   │   ├── data/datasources/profile_remote_data_source.dart
│   │   │   ├── data/repositories/profile_repository_impl.dart
│   │   │   ├── domain/repositories/profile_repository.dart
│   │   │   ├── domain/usecases/
│   │   │   │   ├── update_profile.dart
│   │   │   │   ├── change_password.dart                   # reauthenticates then updates (CC-38)
│   │   │   │   └── upload_avatar.dart
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       │   ├── settings_cubit.dart + state
│   │   │       │   └── edit_profile_cubit.dart + state
│   │   │       ├── screens/
│   │   │       │   ├── settings_screen.dart               # F-13
│   │   │       │   └── edit_profile_screen.dart           # F-14
│   │   │       └── widgets/
│   │   │           ├── profile_card.dart
│   │   │           ├── language_toggle_tile.dart
│   │   │           └── theme_toggle_tile.dart
│   │   │
│   │   ├── projects/                                    # F-15, F-16, F-17
│   │   │   ├── data/datasources/projects_remote_data_source.dart
│   │   │   ├── data/models/project_model.dart
│   │   │   ├── data/models/project_total_model.dart       # from project_totals view
│   │   │   ├── data/repositories/projects_repository_impl.dart
│   │   │   ├── domain/entities/project_entity.dart
│   │   │   ├── domain/entities/project_total_entity.dart
│   │   │   ├── domain/repositories/projects_repository.dart
│   │   │   ├── domain/usecases/
│   │   │   │   ├── get_my_projects.dart
│   │   │   │   ├── get_user_projects_readonly.dart        # used by Owner/Admin drill-down
│   │   │   │   ├── get_portfolio_total.dart               # from user_portfolio view
│   │   │   │   ├── create_project.dart                    # + create_notification RPC
│   │   │   │   ├── update_project.dart                    # + create_notification RPC
│   │   │   │   └── delete_project.dart                    # + create_notification RPC
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       │   ├── projects_cubit.dart + state
│   │   │       │   └── project_form_cubit.dart + state
│   │   │       ├── screens/
│   │   │       │   └── projects_overview_screen.dart      # F-15
│   │   │       └── widgets/
│   │   │           ├── project_card.dart
│   │   │           ├── create_project_sheet.dart          # F-16
│   │   │           ├── project_settings_sheet.dart        # F-17
│   │   │           └── portfolio_value_footer.dart
│   │   │
│   │   └── invoices/                                    # F-18..F-22
│   │       ├── data/datasources/cash_entries_remote_data_source.dart
│   │       ├── data/datasources/receipt_storage_data_source.dart
│   │       ├── data/models/cash_entry_model.dart
│   │       ├── data/repositories/cash_entries_repository_impl.dart
│   │       ├── domain/entities/cash_entry_entity.dart
│   │       ├── domain/repositories/cash_entries_repository.dart
│   │       ├── domain/usecases/
│   │       │   ├── get_project_entries.dart
│   │       │   ├── get_project_receipt_entries.dart       # for Images tab — filters receipt_url not null & not expired
│   │       │   ├── create_cash_entry.dart                 # with client_request_id (CC-3) + notification
│   │       │   ├── update_cash_entry.dart                 # + notification
│   │       │   ├── delete_cash_entry.dart                 # + notification + storage delete
│   │       │   ├── upload_receipt_image.dart              # compress in isolate → upload
│   │       │   ├── delete_receipt_image.dart
│   │       │   └── export_project_pdf.dart                # compute() pdf build + share
│   │       └── presentation/
│   │           ├── cubit/
│   │           │   ├── project_details_cubit.dart + state # owns refresh + tab state
│   │           │   ├── invoices_cubit.dart + state         # F-19
│   │           │   ├── images_cubit.dart + state           # F-22
│   │           │   ├── cash_entry_form_cubit.dart + state  # F-20/F-21
│   │           │   └── pdf_export_cubit.dart + state
│   │           ├── screens/
│   │           │   ├── project_details_screen.dart        # F-18
│   │           │   ├── add_cash_entry_screen.dart         # F-20
│   │           │   └── edit_cash_entry_screen.dart        # F-21
│   │           └── widgets/
│   │           │   ├── invoices_tab.dart                   # F-19 ledger + summary card
│   │           │   ├── images_tab.dart                     # F-22 grid
│   │           │   ├── total_invoiced_card.dart
│   │           │   ├── invoice_row.dart
│   │           │   ├── receipt_image_card.dart
│   │           │   ├── amount_input.dart                   # big tap-to-edit numeric (CC-47)
│   │           │   ├── receipt_picker_sheet.dart           # Camera / Gallery
│   │           │   └── receipt_preview.dart
│   │           └── readonly/
│   │               └── readonly_project_details_screen.dart # used by Owner/Admin drill-down (hides FAB, edit, delete; banner)
│   │
│   └── shared/
│       └── models/paginated.dart                         # generic pagination helper (notifications)
│
├── assets/
│   ├── fonts/
│   │   ├── Cairo-Regular.ttf
│   │   └── Cairo-Bold.ttf
│   └── images/
│       └── logo.png                                      # splash + auth
│
├── supabase/
│   ├── migrations/
│   │   ├── 0001_enums.sql
│   │   ├── 0002_tables.sql
│   │   ├── 0003_indexes.sql
│   │   ├── 0004_functions_triggers.sql
│   │   ├── 0005_rls_policies.sql
│   │   ├── 0006_storage_policies.sql
│   │   ├── 0007_views.sql
│   │   ├── 0008_create_notification_rpc.sql
│   │   └── 0009_pg_cron.sql
│   └── functions/
│       ├── admin-create-user/index.ts
│       ├── admin-delete-user/index.ts
│       └── expire-receipts-storage/index.ts
│
├── test/
│   ├── core/utils/{image_compressor,validators,currency_formatter}_test.dart
│   ├── features/auth/domain/usecases/{sign_in,send_password_reset}_test.dart
│   ├── features/owner/companies/domain/usecases/{create,update,delete}_company_test.dart
│   ├── features/projects/domain/usecases/{create,update,delete}_project_test.dart
│   ├── features/invoices/domain/usecases/{create,update,delete}_cash_entry_test.dart
│   ├── features/invoices/domain/usecases/upload_receipt_image_test.dart
│   └── features/admin/notifications/domain/usecases/get_company_notifications_test.dart
│
├── android/app/src/main/AndroidManifest.xml             # camera, storage (READ_MEDIA_IMAGES on 33+), internet
├── ios/Runner/Info.plist                                # NSCameraUsageDescription, NSPhotoLibraryUsageDescription (AR strings)
├── pubspec.yaml                                         # see §6.3 for full deps + assets + l10n + fonts
├── analysis_options.yaml                                # extend flutter_lints + custom strict rules
├── l10n.yaml                                            # arb-dir: lib/core/localization
├── .env.example                                         # SUPABASE_URL, SUPABASE_ANON_KEY placeholders
└── plan.md                                              # this file mirrored after ExitPlanMode
```

---

## 3. Implementation Phases

Each phase is independently shippable and verifiable. ✅ marks acceptance criteria gates.

### Phase 0 — Foundation (no PRD features; enables everything)

**Goal:** Project scaffolding, DI, theme, locale, router skeleton, error layer, supabase client, network layer.

**Files (in order):**
1. `pubspec.yaml` — add all deps from §6.3 + assets/fonts/l10n config
2. `analysis_options.yaml` — strict lints (prefer_const, avoid_print as error)
3. `l10n.yaml` + `lib/core/localization/app_ar.arb` (full key list) + `app_en.arb`
4. `lib/core/env/env.dart`
5. `lib/core/constants/*` (spacing, radius, durations, storage_keys, storage_buckets, assets)
6. `lib/core/theme/{app_colors,app_text_theme,app_theme}.dart`
7. `lib/core/theme/theme_cubit.dart` + state (persist via shared_preferences)
8. `lib/core/localization/locale_cubit.dart` + state
9. `lib/core/errors/{exceptions,failures,error_mapper}.dart`
10. `lib/core/network/{supabase_client_provider,network_info,client_request_id}.dart`
11. `lib/core/utils/{app_logger,validators,date_formatter,currency_formatter,input_formatters}.dart`
12. `lib/core/widgets/{app_snackbar,confirm_dialog,primary_button,secondary_button,danger_button,app_text_field,empty_state,error_state,loading_skeleton,offline_banner,read_only_banner,app_avatar,app_bottom_sheet,search_field,will_pop_unsaved,expiry_warning_banner}.dart`
13. `lib/core/auth/{session_guard,auth_state_listener}.dart`
14. `lib/core/router/{app_routes,role_redirect,app_router}.dart`
15. `lib/core/di/injection.dart` (registers everything above; features added incrementally)
16. `lib/main.dart` rewrite (load env, init DI, init Supabase, runApp)
17. `lib/app.dart` (MaterialApp.router + MultiBlocProvider for ThemeCubit/LocaleCubit/AuthCubit + offline banner overlay)
18. Bundle Cairo fonts in `assets/fonts/`

**Verify (✅):**
- App boots into a placeholder home, dark theme, Arabic RTL by default.
- Toggle theme → persists across restart. Toggle locale → entire UI flips RTL/LTR.
- `flutter analyze` zero warnings. `dart format` clean.
- Disconnect Wi-Fi → offline banner shows; reconnect → banner hides.

**Supabase deps:** Just `SupabaseClient` available via DI.

---

### Phase 1 — Backend (DB + Edge Functions + cron)

**Goal:** Stand up the entire Supabase backend so Flutter has something to talk to.

**Steps (run in Supabase SQL Editor or via `supabase db push`):**
1. Apply migrations `0001…0009` from §1
2. Deploy 3 Edge Functions (`supabase functions deploy <name>`)
3. Set `expire-receipts-storage` cron + store service key in Supabase Vault
4. Manually run the Owner-promotion `UPDATE`

**Verify (✅):**
- All 5 tables visible in dashboard; insert a test row via SQL editor → trigger sets updated_at.
- `EXPLAIN` an Admin-role SELECT on cash_entries → policy `admin_read_company_entries` applied.
- Invoke `admin-create-user` Edge Function via curl with Owner JWT → row appears in both `auth.users` and `public.users`.
- Insert a fake `cash_entries` row with `receipt_expires_at = now() - interval '1 day'` and `receipt_expired=false` → call cron job manually → row flips to `receipt_expired=true`, `receipt_url=null`.
- RLS check matrix: log in as each role in 3 separate sessions and verify SELECT/INSERT/DELETE behavior matches PRD §4.

---

### Phase 2 — Authentication (F-09, F-10, F-11, F-12)

**Goal:** Splash routing + login + password reset round-trip + global AuthCubit handles role.

**Files (in order):**
1. `features/auth/domain/entities/auth_user_entity.dart`
2. `features/auth/domain/repositories/auth_repository.dart`
3. `features/auth/data/models/auth_user_model.dart`
4. `features/auth/data/datasources/auth_remote_data_source.dart`
5. `features/auth/data/repositories/auth_repository_impl.dart`
6. 5 usecases under `features/auth/domain/usecases/`
7. `features/auth/presentation/cubit/auth_cubit.dart` (global) + state — holds `AuthUserEntity?` and `Role?`
8. `features/auth/presentation/cubit/splash_cubit.dart` + state (1.5s minimum splash, then call GetCurrentSession → fetch `public.users` row → if null → signOut)
9. `features/auth/presentation/cubit/login_cubit.dart` + state
10. `features/auth/presentation/cubit/forgot_password_cubit.dart` + state
11. Screens: `splash_screen.dart`, `login_screen.dart`, `forgot_password_screen.dart`, `email_sent_screen.dart`
12. Widgets: `auth_logo_header.dart`, `auth_text_field.dart`
13. Wire routes into `app_router.dart` with role-based redirect
14. Wire `session_guard.dart` into app.dart → on `signedOut` or RLS user-not-found → router goes to /login
15. Register all in DI

**Verify (✅):**
- Splash > 1.5s, branding visible, then routes:
  - Owner → `/owner/companies` (placeholder OK for now)
  - Admin → `/admin/users` (placeholder)
  - User → `/projects` (placeholder)
  - No session → `/login`
- Login: wrong creds → AR Snackbar; correct creds → role-based navigation + success Snackbar.
- Double-tap login → button disabled after first tap (CC-5).
- Forgot password → success screen + email arrives (test with real address).
- Delete the Owner row in `public.users` while signed in → next interaction triggers force logout + "تم حذف حسابك" Snackbar (CC-1/CC-2).
- Toggle airplane mode mid-login → timeout 10s → error Snackbar (CC-9).

---

### Phase 3 — Settings (F-13, F-14)

**Goal:** Profile editing, password change, language/theme toggles, logout — shared across all 3 roles.

**Files:**
1. `features/settings/domain/repositories/profile_repository.dart`
2. `features/settings/data/{datasources,repositories}/...`
3. Usecases: `update_profile`, `change_password` (reauth then update — CC-38), `upload_avatar`
4. `settings_cubit.dart` + state, `edit_profile_cubit.dart` + state
5. Screens: `settings_screen.dart` (F-13), `edit_profile_screen.dart` (F-14)
6. Widgets: `profile_card.dart`, `language_toggle_tile.dart`, `theme_toggle_tile.dart`
7. Wire route + Settings icon in each role's home shell

**Verify (✅):**
- Edit name + email → Snackbar success + name updates in app bar instantly.
- Change password with wrong current password → inline error.
- Upload avatar → bottom sheet → camera/gallery → compresses in isolate → uploads → avatar updates.
- Toggle language → all visible strings flip; RTL applies. Persists across restart.
- Toggle theme → instant; persists.
- Logout → confirm dialog → returns to login.
- WillPopScope warns on unsaved profile changes (CC-22).

**Supabase deps:** `public.users` UPDATE, `user-avatars` storage write.

---

### Phase 4 — Owner Companies (F-01, F-02, F-03)

**Files:**
1. `owner/companies/domain/entities/{company_entity,companies_overview_entity}.dart`
2. `owner/companies/domain/repositories/companies_repository.dart`
3. `owner/companies/data/{models,datasources,repositories}/...`
4. Usecases: get/get_overview/create/update/delete
5. `companies_cubit.dart`, `company_form_cubit.dart` + states
6. Screens: list (F-01), add (F-02), edit (F-03)
7. Widgets: `company_card`, `companies_overview_footer`, `company_logo_picker`, `owner_action_buttons`
8. Route registration + role guard

**Verify (✅):**
- Owner sees Companies list sorted DESC by created_at, with logos and user counts (via `users` join or pre-aggregated query).
- Search debounces 300ms; empty result shows "لا توجد نتائج".
- Add Company: upload logo (camera/gallery → bottom sheet → compress → upload to `company-logos/{newId}.jpg`) → company appears at top of list + Snackbar.
- Logo upload sequence: insert company row first, get id, upload logo using id, UPDATE company with logo_url. If logo fails, company exists logo-less (warn) (CC-19 mitigation refined).
- Edit Company → save changes → snackbar.
- Delete Company → confirm dialog with cascade warning → full-screen "جاري الحذف..." → on success Snackbar + navigate back (CC-21).
- Bottom statistics: Total Users (sum of users.count grouped) + Total Companies (count(companies)).

---

### Phase 5 — Owner Users CRUD (F-04, F-05, F-06)

**Files:**
1. `owner/users/domain/entities/user_entity.dart`
2. `owner/users/domain/repositories/owner_users_repository.dart`
3. `owner/users/data/...` (datasource invokes Edge Functions for create/delete; UPDATE goes through direct table)
4. Usecases: get_users_by_company / create_user / update_user / delete_user
5. `owner_users_list_cubit.dart`, `user_form_cubit.dart`
6. Screens: list (F-06), create (F-04), edit (F-05)
7. `user_card.dart`
8. Routes

**Verify (✅):**
- Create User: full name + company dropdown + email + password (≥8) + confirm → Save → spinner → row appears in target company. Email validation accepts `+` aliases (CC-23). Duplicate email → inline "البريد مستخدم".
- Default role = user; to make Admin, run manual SQL UPDATE (per PRD F-04).
- Edit User: reassign company; delete user → confirm → cascade verified (their projects + entries + receipts gone).
- Users list per company has read-only banner when accessed by Owner (Owner cannot edit project data — see Phase 8).

---

### Phase 6 — Admin Panel (F-07, F-08) + Admin shell

**Files:**
1. `admin/users/...` (read engineers, delete via Edge Function)
2. `admin/notifications/...` (full CRUD on company-scoped notifications)
3. `admin/shell/admin_shell_screen.dart` (bottom nav: Users | Notifications)
4. Widgets: `notification_card`, `notification_type_chip` (color-coded), `admin_user_card`
5. `notifications_badge_cubit` (polls or refreshes on focus; never live)
6. Routes: `/admin` shell with sub-routes

**Verify (✅):**
- Admin logs in → lands on Users tab. Search/delete user → cascade.
- Notifications tab: type-color matches PRD (gold/purple/pink/gray). Unread badge appears on tab icon; cap at "99+" (CC-30). Pull-to-refresh + header refresh button work.
- Tap notification: marks read; project_id null → AR Snackbar "هذا المشروع تم حذفه"; project_id present → navigates to read-only project view (Phase 8).
- Delete notification → confirm dialog → Snackbar.

---

### Phase 7 — User Projects (F-15, F-16, F-17)

**Files:**
1. `projects/domain/entities/{project_entity,project_total_entity}.dart`
2. `projects/domain/repositories/projects_repository.dart`
3. `projects/data/{models,datasources,repositories}/...` (reads `project_totals` view for totals)
4. Usecases: get_my_projects / get_user_projects_readonly / get_portfolio_total / create / update / delete (each create_notification on mutate)
5. `projects_cubit`, `project_form_cubit`
6. Screens: `projects_overview_screen.dart` (F-15)
7. Widgets: `project_card`, `create_project_sheet` (F-16), `project_settings_sheet` (F-17), `portfolio_value_footer`
8. Routes

**Verify (✅):**
- User sees only own projects; pull-to-refresh works.
- Portfolio total matches sum from view; never client-side aggregate (CC-39).
- Create project sheet: name → save → appears at top → Snackbar → notification appears in Admin panel (Admin must refresh).
- Edit/Delete via three-dot menu → bottom sheet F-17.
- Delete project cascade-removes entries + receipts; Admin sees `archived` notification.

---

### Phase 8 — User Cash Entries + Invoices + Images + PDF (F-18 → F-22)

**Files:**
1. `invoices/domain/entities/cash_entry_entity.dart`
2. `invoices/domain/repositories/cash_entries_repository.dart`
3. `invoices/data/{models,datasources,repositories}/...` (cash_entries_remote + receipt_storage)
4. Usecases: get_project_entries / get_project_receipt_entries / create / update / delete / upload_receipt_image / delete_receipt_image / export_project_pdf
5. Cubits: `project_details_cubit`, `invoices_cubit`, `images_cubit`, `cash_entry_form_cubit`, `pdf_export_cubit`
6. Screens: `project_details_screen` (F-18 shell with tabs), `add_cash_entry_screen` (F-20), `edit_cash_entry_screen` (F-21)
7. Widgets: `invoices_tab` (F-19 incl. summary card + expiry warning banner), `images_tab` (F-22 grid), `total_invoiced_card`, `invoice_row`, `receipt_image_card`, `amount_input`, `receipt_picker_sheet`, `receipt_preview`
8. Read-only sibling: `readonly_project_details_screen.dart` (used by Owner & Admin drill-down)
9. Cairo-font PDF generator (`core/utils/pdf_generator.dart`) — runs in compute() isolate

**Verify (✅):**
- Add Cash Entry: amount > 0 enforced (DB CHECK + client validator); future date disabled; receipt optional; camera/gallery sheet works; compression runs in isolate (UI stays interactive — CC-5); save triggers `update_log` notification.
- Double-tap save → only one entry created (client_request_id idempotency — CC-3). Verify by SQL: duplicate INSERT with same `(user_id, client_request_id)` is blocked by partial unique index.
- Edit entry → replace receipt (delete old from storage, upload new), or remove receipt. Delete entry → `structural_alert` notification.
- Invoices tab: TOTAL INVOICED matches DB; "UPDATED N MINUTES AGO" relative format.
- Images tab: only entries with `receipt_url IS NOT NULL AND NOT receipt_expired`; tap → opens Edit.
- Expiry warning banner if any receipt expires within 5 days.
- PDF Export: header with company logo, table with all entries, embedded thumbnails (where present), grand total, Arabic-rendering with Cairo. If all receipts expired → confirm "البيانات المالية فقط" dialog (CC-45) then proceed.
- Offline + try to save → blocked with Snackbar.

---

### Phase 9 — Cross-Role Read-Only Drill-Down (extends F-06, F-07, F-08)

**Goal:** Owner enters a user → sees their projects (read-only). Admin same. Tapping a project → read-only project details.

**Files:**
1. New routes: `/owner/users/:id/projects`, `/admin/users/:id/projects`, `…/projects/:id`
2. Use `get_user_projects_readonly` use-case (RLS already grants Owner SELECT-all and Admin SELECT-company)
3. `readonly_project_details_screen.dart` — hides FAB, edit/delete actions, shows `read_only_banner`
4. For navigation from notifications: route param carries `engineerId` + `projectId`

**Verify (✅):**
- Owner drills Owner→Company→User→Project→Invoices/Images — all read-only, banner visible, no FAB.
- Admin drills Users→User→Project — same.
- Notification deep-link drops Admin onto correct read-only project.
- Notification whose project_id is null → Snackbar "هذا المشروع تم حذفه" (no navigation).
- RLS sanity: in SQL editor as admin, SELECT cash_entries from another company → 0 rows.

---

### Phase 10 — QA / Hardening / Release

1. Walk every PRD §2.1 Snackbar string + §2.2 Confirmation dialog + §2.4 Empty state → verify in app and check both AR and EN.
2. Run through all 68 corner cases (`docs/corner_case_analysis.md`) checking each is handled or accepted.
3. Test on small phones (4.7"), large phones (6.7"), tablets, dark & light, AR & EN.
4. `flutter test` — every UseCase has success + failure coverage.
5. Test all 3 roles end-to-end with real Supabase.
6. Storage usage check (open risk R-03): document monitoring.
7. Build release APK + iOS archive; smoke test.

---

## 4. Dependency Graph

```
Phase 0 (Foundation)
   │
   ├─► Phase 1 (Backend SQL + Edge Functions)
   │       │
   │       └─► Phase 2 (Auth)
   │               │
   │               ├─► Phase 3 (Settings)            [shared by all roles]
   │               ├─► Phase 4 (Owner Companies)
   │               │       └─► Phase 5 (Owner Users CRUD)
   │               ├─► Phase 7 (User Projects)
   │               │       └─► Phase 8 (Cash Entries + Invoices + Images + PDF)
   │               └─► Phase 6 (Admin Panel)        [needs notifications RPC + users delete EF]
   │                       │
   │                       └─► Phase 9 (Cross-Role Read-Only Drill-Down)
   │                                   ▲
   │                                   └ requires Phase 7 + Phase 8 to exist
   │
   └─► Phase 10 (QA / Release)                       [last]
```

Critical edges:
- **Phase 8 depends on Phase 7** (entries need a project).
- **Phase 9 depends on Phases 5, 7, 8** (drill-down needs the screens it's reusing).
- **Phase 6 depends on Phase 1** for `create_notification` RPC + `admin-delete-user` EF.
- **Cairo font asset** is needed in Phase 0 (declared) but only consumed in Phase 8 (PDF) — declare early to avoid hot-reload issues.

---

## 5. Critical Corner Case Implementation Details

### 🔴 CC-1: Orphaned auth user
- **DB trigger `handle_new_user`** (Phase 1, §1.4) atomically inserts `public.users` row when `auth.users` row is created — eliminates the race entirely.
- **`admin-create-user` Edge Function** passes `full_name`, `role`, `company_id` via `user_metadata`; trigger reads from `raw_user_meta_data`.
- **Splash defensive fetch** (Phase 2): even with the trigger, `splash_cubit` re-fetches `public.users` for `auth.uid()`. If null → `signOut` + Snackbar "تم حذف حسابك" + go to login.

### 🔴 CC-2: Active user deleted mid-session
- `core/auth/session_guard.dart` subscribes to `supabase.auth.onAuthStateChange`.
- `core/errors/error_mapper.dart` catches `PostgrestException(code:'PGRST116')` (no row) and HTTP 401/403 → maps to `AuthFailure(deletedAccount)`.
- Global `BlocListener<AuthCubit>` in `app.dart` listens for `AuthDeleted` state → calls `signOut` → router redirects → Snackbar `authDeletedSnackbar`.
- Wired into every repository's catch block via `error_mapper`.

### 🔴 CC-3: Double-tap duplicate cash entry
- `core/network/client_request_id.dart` exposes `ClientRequestIdGenerator.next()` returning a v4 UUID.
- `cash_entry_form_cubit.dart` generates one UUID **when the screen opens** (not on submit) and stores it in state. All retries of the same form share the same ID.
- `create_cash_entry` use case passes `client_request_id` in the INSERT payload.
- DB-level: partial UNIQUE INDEX `(user_id, client_request_id)` blocks duplicates → repository catches `23505 unique_violation` and returns the existing entry (re-fetched by `(user_id, client_request_id)`).
- UI-level: `primary_button.dart` disables itself the moment `onPressed` fires; only re-enables when the Cubit emits non-Loading state.

### 🔴 CC-4: JWT refresh failure
- Supabase client is initialized with `autoRefreshToken: true` (default).
- `session_guard.dart` listens for `AuthChangeEvent.tokenRefreshed` (no-op) and `AuthChangeEvent.signedOut` (force logout).
- `error_mapper` maps HTTP 401 from Postgrest → triggers a single retry via `supabase.auth.refreshSession()`; if that fails → `AuthFailure(sessionExpired)` → Snackbar "انتهت جلستك، سجل دخولك مرة أخرى" + redirect to login.
- Reconnection: `NetworkInfo` stream → on transition `offline→online`, AuthCubit calls `refreshSession` proactively.

### 🔴 CC-5: Image compression blocking UI
- `core/utils/image_compressor.dart` exposes `static Future<Uint8List> compressInIsolate(Uint8List bytes)` that calls `compute(_compressImageInIsolate, bytes)`.
- Inside isolate: `FlutterImageCompress.compressWithList(quality:70, minWidth:1080, minHeight:1080, format:CompressFormat.jpeg, autoCorrectionAngle:true)` — handles HEIC (CC-17) + EXIF (CC-18) + max-dim.
- 30-second timeout (`Future.timeout`); on timeout → throw `ValidationException('imageProcessFailed')` → Snackbar.
- `ImagePickerHelper` shows a full-screen blocking loading overlay ("جاري معالجة الصورة...") while compression runs but does NOT block the isolate — main thread stays responsive.
- Final file size check ≤ 500KB; if exceeded after compression, run a second pass at quality 50.

---

## 6. Supabase Integration Strategy

### 6.1 Initialization
```dart
// lib/main.dart
WidgetsFlutterBinding.ensureInitialized();
await Supabase.initialize(
  url: Env.supabaseUrl,
  anonKey: Env.supabaseAnonKey,
  authOptions: const FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce,
  ),
  debug: kDebugMode,
);
initDI();
runApp(const CashesApp());
```
- Run via `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`.
- `Env.supabaseUrl = String.fromEnvironment('SUPABASE_URL')` — throws at startup if missing.
- `.env.example` documents required keys; `.gitignore` excludes any real `.env`.

### 6.2 Global auth state listener (`app.dart`)
```dart
@override
void initState() {
  super.initState();
  _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    switch (event) {
      case AuthChangeEvent.signedOut:
      case AuthChangeEvent.userDeleted:
        context.read<AuthCubit>().clear();
        _router.go(AppRoutes.login);
      case AuthChangeEvent.passwordRecovery:
        _router.go(AppRoutes.resetPassword); // deep link
      case AuthChangeEvent.tokenRefreshed:
        // no-op — Supabase already updated headers
      default:
        break;
    }
  });
}
```

### 6.3 Packages (CLAUDE.md-approved set + Cairo font asset — NO new packages added)
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_bloc: ^9.0.0
  supabase_flutter: ^2.5.0
  go_router: ^14.0.0
  get_it: ^7.7.0
  equatable: ^2.0.5
  dartz: ^0.10.1
  flutter_image_compress: ^2.3.0
  image_picker: ^1.1.2
  permission_handler: ^11.3.0
  shared_preferences: ^2.3.0
  pdf: ^3.10.0
  printing: ^5.12.0
  intl: any
  uuid: ^4.4.0
  cached_network_image: ^3.4.0
  shimmer: ^3.0.0
  connectivity_plus: ^6.0.0
  logger: ^2.4.0
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  bloc_test: ^9.1.7        # ⚠️ Not in CLAUDE.md — flag for approval before adding
  mocktail: ^1.0.4         # ⚠️ Not in CLAUDE.md — flag for approval before adding

flutter:
  uses-material-design: true
  generate: true            # for ARB → AppLocalizations codegen
  assets:
    - assets/images/
  fonts:
    - family: Cairo
      fonts:
        - asset: assets/fonts/Cairo-Regular.ttf
        - asset: assets/fonts/Cairo-Bold.ttf
          weight: 700
```
> `bloc_test` + `mocktail` are conventional for "test every UseCase" requirement in CLAUDE.md but are not in the approved package list — will surface this in §8 Risks for your decision.

### 6.4 RLS verification pre-release (Phase 10)
- Create three test JWTs in SQL Editor: owner, admin-of-A, user-of-A.
- Run a matrix script: SELECT/INSERT/UPDATE/DELETE on each of the 5 tables for each role, recording allowed/denied.
- Cross-check against the matrix in `docs/supabase_schema.md §6`.
- Document any deltas in `supabase_status.md`.

### 6.5 Storage path convention
```
receipt-images/{company_id}/{user_id}/{cash_entry_id}.jpg
company-logos/{company_id}.jpg
user-avatars/{user_id}.jpg
```
- Naming via UUID guarantees no collisions.
- Always force `.jpg` extension (we always output JPEG after compression).
- On entry update with new receipt: same path → overwrite (`upsert: true`).
- On entry delete: explicit `storage.remove([path])` in repository before DB delete; if DB delete fails → file already gone but DB row stays — pg_cron orphan cleanup (R-01) handles drift.

---

## 7. Localization & Theming Setup

### 7.1 ARB file structure (illustrative key namespacing)
```
common*           ok, cancel, save, delete, retry, search, refresh, loading, offline
snackbar*         (every PRD §2.1 entry — keyed snackbarLoginSuccess, snackbarCompanyAdded, …)
dialog*           dialogDeleteCompanyTitle, dialogDeleteCompanyBody, dialogDeleteCompanyConfirm, …
empty*            emptyCompanies, emptyUsers, emptyProjects, emptyEntries, emptyImages, emptyNotifications
auth*             authWelcomeBack, authEmail, authPassword, authLogin, authForgotPassword, authResetCta, …
owner*            ownerCompaniesTitle, ownerAddCompany, ownerAddUser, ownerActiveCount, …
admin*            adminAllUsers, adminAlertsTitle, adminAlertsSubtitle, adminTypeNewAssignment, …
settings*         settingsPersonalInfo, settingsLanguage, settingsAppearance, settingsLogout, settingsAppVersion, …
projects*         projectsWelcome, projectsCuratedOverview, projectsActiveDevelopments, projectsTotalPortfolio, projectsCreateTitle, projectsCreateSubtitle, projectsSettingsTitle, …
invoices*         invoicesTotal, invoicesUpdatedAt, invoicesAddEntry, invoicesEditEntry, invoicesAmount, invoicesVendor, invoicesDate, invoicesReceipt, invoicesAttachReceipt, invoicesCamera, invoicesGallery, invoicesExpiryWarning, invoicesPdfExport, …
error*            errorGeneric, errorNetwork, errorPermission, errorValidation, errorImageProcess, errorPdfFailed, errorAccountDeleted, errorSessionExpired
validation*       validationRequired, validationEmail, validationPasswordMinLength, validationAmountPositive, validationNameMinLength, validationConfirmPasswordMismatch
```
- `app_ar.arb` first (default); every key has a `@key` description.
- `app_en.arb` mirrors exactly the same keys.
- `flutter gen-l10n` after every key add.
- Lint rule (custom): grep CI step rejects any string literal containing Arabic characters outside `*.arb` files.

### 7.2 ThemeData setup
- `app_colors.dart` exposes both palettes as `static const`.
- `app_text_theme.dart` builds a Cairo-based TextTheme; uses Material 3 type scale; no hardcoded font sizes elsewhere (`Theme.of(context).textTheme.bodyMedium` etc.).
- `app_theme.dart` exposes `ThemeData darkTheme` (default) and `ThemeData lightTheme`. Cards use `RoundedRectangleBorder(radius:12)`; primary `#F5A623` shared.
- `ThemeCubit` holds `ThemeMode` and persists key `'theme_mode'`. App reads on boot, defaults to `ThemeMode.dark`.

### 7.3 RTL ↔ LTR switching
- `MaterialApp` uses `locale` from `LocaleCubit` + `supportedLocales: [Locale('ar'), Locale('en')]` + `localizationsDelegates: [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate, GlobalWidgetsLocalizations.delegate]`.
- All paddings use `EdgeInsetsDirectional`; all alignments `AlignmentDirectional`; all icons that imply direction (back arrow, chevron) auto-mirror because they come from Material Icons (already RTL-aware).
- Mixed-direction text (e.g., Arabic + English vendor name) wrapped in `Directionality(textDirection: TextDirection.ltr, …)` only where the row is known to contain Latin content (CC-65 mitigation).
- Tested locale switch with the `LocaleSwitcher` widget in Settings: instant rebuild via `BlocBuilder<LocaleCubit, Locale>` at MaterialApp level.

### 7.4 Date / currency formatting
- `intl` `DateFormat('dd/MM/yyyy', Localizations.localeOf(context).languageCode)`.
- `intl` `NumberFormat.currency(symbol: '\$', decimalDigits: 2)` (single currency per CLAUDE.md scope).
- Amount input field uses `TextInputType.numberWithOptions(decimal:true)` + custom `AmountInputFormatter` that strips commas before parsing (CC-47).

---

## 8. Risk Flags

> Risks NOT (or only partially) addressed in `docs/`.

⚠️ **R-A · `bloc_test` + `mocktail` are not in CLAUDE.md's approved package list** → without them, "Write a unit test for every UseCase" (CLAUDE.md DO list) is impractical. **Mitigation:** request explicit approval to add both as dev_dependencies (they are de-facto standard, dev-only, and never shipped). I will not add them without confirmation.

⚠️ **R-B · The schema doc lacks `client_request_id` on `cash_entries`** → CC-3 mitigation is impossible without it. **Mitigation:** add as `UUID NOT NULL` column + partial UNIQUE INDEX `(user_id, client_request_id)` in migration `0002_tables.sql`. Plan reflects this addition.

⚠️ **R-C · The schema doc lacks `handle_new_user` trigger definition** (status.md mentions it, schema.md doesn't define it) → CC-1 mitigation needs it. **Mitigation:** plan defines it explicitly in §1.4; trigger reads `raw_user_meta_data` and the Edge Function writes there.

⚠️ **R-D · Storage cleanup of expired receipts is not actually wired up** in any doc — pg_cron only flips the DB flag; the file persists. **Mitigation:** add `expire-receipts-storage` Edge Function + cron-driven HTTP call (uses pg_net + Vault). Orphan files older than 1h cleaned the same way (CC-57).

⚠️ **R-E · Receipt-images bucket has no documented RLS policies** (the schema lists conceptual access, no SQL). Without explicit policies the bucket is wide open to authenticated users. **Mitigation:** §1.9 adds the three bucket policies.

⚠️ **R-F · Owner UI to create Admins is out of scope** but PRD F-04 strongly implies it. CLAUDE.md says manual SQL. **Mitigation:** keep manual SQL for v1.0; add a tiny owner-only "Promote to Admin" screen in v1.1 backlog. Document in `supabase_status.md`.

⚠️ **R-G · `connectivity_plus` reports interface state, not internet reachability** (e.g., captive portal, DNS failure). False positives = saving will still fail. **Mitigation:** treat NetworkInfo as a fast-path gate; the actual repository call's try/catch is the source of truth. Repository wrap returns `NetworkFailure` on `SocketException`/timeout.

⚠️ **R-H · PDF Arabic shaping** — `pdf` package's text rendering may not shape Arabic ligatures correctly even with Cairo font. **Mitigation:** test exports across full sentences early in Phase 8; if ligatures break, switch to `pdf` package's `pw.RichText` with `textDirection: pw.TextDirection.rtl` OR pre-shape via `flutter_text_shaper` package (would require approval).

⚠️ **R-I · iOS background upload** — iOS may suspend mid-upload (Open Risk R-01 in docs). **Mitigation:** show "اترك التطبيق مفتوحاً حتى يكتمل الرفع" overlay during upload; queue retry on resume.

⚠️ **R-J · `pdf` + `printing` on Arabic system locale** sometimes fails the share sheet on iOS 17. **Mitigation:** save to temp file first, then open via `Share.shareXFiles` from share_plus (would need approval) OR `printing.layoutPdf` with custom callback.

⚠️ **R-K · 30-day cron uses UTC** — a receipt uploaded at 23:30 Cairo time on day 0 expires at 02:00 UTC day 31 (≈ 04:00 Cairo) — slightly later than 30 calendar days locally. **Mitigation:** acceptable; document in user-facing copy as "30 days".

⚠️ **R-L · Real-time admin notifications** are explicitly out of scope (pull-to-refresh only per PRD §6). This is fine for v1 but expect Admin complaints. **Mitigation:** badge auto-refreshes on app foreground; document Supabase Realtime as v1.1 upgrade path.

⚠️ **R-M · Email change requires verification** (CC-37) — Supabase sends a confirmation link to new email; until clicked the auth email remains old. **Mitigation:** show banner "تم إرسال رابط تأكيد لبريدك الجديد"; do not update `public.users.email` until `onAuthStateChange` fires `userUpdated`.

---

## 9. Verification Strategy (end-to-end)

After each phase, run this checklist:
1. `flutter analyze` → 0 issues
2. `dart format lib/` → no diffs
3. `flutter test` → all green (UseCase coverage growing per phase)
4. `flutter run` on a real device (or 2 — small + large screen)
5. Toggle theme + locale — visual check
6. Toggle airplane mode mid-action — error UX check
7. SQL spot-check in Supabase dashboard — confirm rows + storage objects appear and cascade as expected
8. Three-role smoke test with three accounts (Owner / Admin / User) — every CRUD path

Release gate (Phase 10):
- All 22 PRD acceptance criteria checked
- All 5 critical CCs reproduced and confirmed handled
- All 68 corner cases reviewed (each row marked Handled / Accepted / Future)
- RLS matrix run in SQL editor
- Release APK + iOS archive build clean
- Test PDF export on a project with: 0 entries / 1 entry no receipt / 5 entries with receipts / 50 entries with mixed expired

---

## 10. Open Questions

None blocking. The two architecture-blocking questions (user CRUD path + Arabic PDF font) were resolved before this plan was written. All other unknowns are flagged in §8 Risks with concrete mitigation paths; they can be resolved during implementation without restructuring the plan.

If you want, I can also:
- Generate the SQL files (`supabase/migrations/0001…0009`) ready to apply, before any Flutter code is written.
- Generate the 3 Edge Function TypeScript stubs.
- Draft the full ARB key list (every snackbar/dialog/empty/error string from the docs) so localization is settled before Phase 0.

Otherwise, on approval I will start with Phase 0 + Phase 1 (foundation + backend) and ship incremental, verifiable phases through to release.
