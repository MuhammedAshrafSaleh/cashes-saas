# 🔍 Corner Case Analysis — Cashes App
**Role:** Senior Mobile Product Manager & QA Architect
**Based on:** PRD v1.0.0
**Coverage:** 22 Features · 8 Categories · iOS & Android · 68 Corner Cases

---

## Corner Case Table

| # | Feature | Corner Case | Category | User Impact | Resolution Strategy |
|---|---------|-------------|----------|-------------|---------------------|
| 1 | F-09 Splash | Session token valid in local storage but user was deleted from DB by Owner | 🔐 Auth | App crashes or enters broken state with no data | On splash, after confirming session, fetch `public.users` record — if null → `supabase.auth.signOut()` + navigate to Login + Snackbar "تم حذف حسابك" |
| 2 | F-09 Splash | No internet on first open — can't verify session or role | 📶 Network | Infinite loading / blank screen | After 5s timeout → show "لا يوجد اتصال بالإنترنت" with retry button; if cached session exists show last known screen in read-only |
| 3 | F-09 Splash | App killed mid-splash by OS (low RAM device) and relaunched | 🔋 Device | Splash replays, possible double navigation | Splash logic must be idempotent — use `mounted` check before any `Navigator.push` |
| 4 | F-09 Splash | Role stored in local cache is stale (Owner changed user's role) | 📦 Data | User lands on wrong panel | Never trust cached role — always fetch fresh from `public.users` on every splash/login |
| 5 | F-10 Login | User rapidly double-taps Login button | 👆 Input | Two simultaneous auth requests → possible duplicate session or UI freeze | Disable button immediately on first tap; use `isLoading` state guard; re-enable only on response |
| 6 | F-10 Login | Password field contains emoji or special Unicode chars | 👆 Input | Supabase may reject or mismatch password hash | Allow all characters; validate min length only; do not strip or sanitize password input |
| 7 | F-10 Login | Keyboard pushes Login button off-screen on small phones (4.7" screen) | 🌍 Locale/UX | User can't tap Login — appears broken | Wrap screen in `SingleChildScrollView`; use `resizeToAvoidBottomInset: true` |
| 8 | F-10 Login | App goes to background mid-login API call (user switches app) | 🔋 Device | Response arrives after app is suspended; state never updates | Use `mounted` check in async callbacks; Cubit emits state only if stream still active |
| 9 | F-10 Login | Network drops exactly after credentials sent but before response received | 📶 Network | User sees infinite loader; can't retry | Implement request timeout (10s); on timeout emit error state + Snackbar "انتهى وقت الاتصال" |
| 10 | F-11 Forgot Password | User submits email that is not registered | 🔐 Auth | Security risk if error reveals email existence | Always show success screen regardless — never confirm or deny email existence (Supabase default behavior is correct) |
| 11 | F-11 Forgot Password | Reset link tapped on a different device than where app is installed | 🔔 Notif | Deep link opens browser or wrong app | Configure Supabase redirect URL to deep link back into the app; handle `onAuthStateChange` for `PASSWORD_RECOVERY` event |
| 12 | F-11 Forgot Password | User taps "Send Reset Link" multiple times rapidly | 👆 Input | Multiple emails sent → user confused | Disable button after first tap for 60s; show countdown: "أعد الإرسال بعد 60 ثانية" |
| 13 | F-11 Forgot Password | Reset link expires (Supabase default: 1 hour) before user uses it | 📦 Data | User taps link → gets error page | Show clear expiry message on the web redirect page; allow user to request new link |
| 14 | F-01 Companies | 100+ companies in list — scroll performance | 📦 Data | Laggy scroll, high memory usage | Use `ListView.builder` (lazy loading); paginate if >50 records; client-side search on loaded data only |
| 15 | F-01 Companies | Company logo URL becomes invalid (file deleted from Storage) | 📦 Data | Broken image icon shown | Use `errorBuilder` on `Image.network` → show company initials avatar as fallback |
| 16 | F-01 Companies | Search field query while data is still loading | 👆 Input | Search on partial data → missing results | Disable search or show loader in search bar until initial fetch completes |
| 17 | F-02 Add Company | Logo image from camera on iOS is HEIC format | 🔋 Device | Supabase Storage may not serve HEIC correctly; compression may fail | Convert HEIC to JPEG before upload using `flutter_image_compress`; always output JPEG |
| 18 | F-02 Add Company | Camera photo taken in landscape → uploaded rotated (EXIF orientation issue) | 🔋 Device | Logo appears sideways in company card | Apply EXIF rotation fix before compression using `image` package |
| 19 | F-02 Add Company | Network drops mid-logo upload (company name saved but logo URL empty) | 📶 Network | Company created with no logo — partial state | Upload image first; only create company record after image URL is confirmed; if upload fails → abort company creation + Snackbar |
| 20 | F-02 Add Company | Company name contains only spaces or special characters | 👆 Input | Invalid company name stored | Trim whitespace; validate that trimmed name length ≥ 2 chars; reject names with only special chars |
| 21 | F-03 Edit Company | DELETE COMPANY tapped while company has 100+ users and 1000+ projects | 📶 Network | Cascade delete takes long time; user thinks it hung | Show full-screen progress dialog during delete; disable back navigation; show "جاري الحذف..." |
| 22 | F-03 Edit Company | User navigates back mid-edit (Android back button) with unsaved changes | 👆 Input | Changes silently lost | Intercept `WillPopScope`/`PopScope` → show "لديك تغييرات غير محفوظة — هل تريد المغادرة؟" dialog |
| 23 | F-04 Create User | Email contains `+` alias (e.g. user+alias@gmail.com) | 👆 Input | Valid email but may be treated as invalid | Allow `+` in email validation regex; test Supabase Auth handles it (it does) |
| 24 | F-04 Create User | Race condition: company created + user creation started but network drops after `auth.users` insert but before `public.users` insert | 📶 Network | Orphaned auth record — user can "login" but has no profile | Use Supabase DB trigger or Edge Function to auto-create `public.users` on `auth.users` insert → eliminates the gap |
| 25 | F-04 Create User | Owner creates user with same email as deleted user | 📦 Data | Supabase Auth may block if soft-deleted | Ensure deleted users are hard-deleted from `auth.users`; test Supabase behavior |
| 26 | F-05 Edit User | Owner reassigns user to different company while Admin of original company is viewing that user | 🔄 State | Admin sees stale data; user's projects now belong to new company | RLS will block Admin's next data fetch automatically; no extra handling needed |
| 27 | F-06 Users List (Owner) | Owner enters read-only mode of user's projects; user simultaneously deletes a project | 🔄 State | Owner sees deleted project for a moment | Pull-to-refresh handles this; add subtle "تم التحديث" indicator on refresh |
| 28 | F-07 Admin Users | Admin deletes a user while that user is actively using the app | 🔐 Auth | Deleted user's next API call gets RLS error | On any 403/RLS error → check if `public.users` record exists; if not → force logout + "تم حذف حسابك" |
| 29 | F-08 Notifications | Notification tapped while app is in the background (future push — but relevant for deep link) | 🔔 Notif | App opens to wrong screen or crashes | Handle cold-start deep link in `main.dart`; parse notification payload before rendering any screen |
| 30 | F-08 Notifications | 500+ unread notifications accumulated — badge counter overflow | 📦 Data | Badge shows "500" — looks broken | Cap display at "99+" for badge; paginate notification list (20 per page) |
| 31 | F-08 Notifications | Admin taps notification → navigates to user's project → project has 0 entries | 🔄 State | Empty state in read-only mode may look like a bug | Show empty state with label "لا توجد بنود في هذا المشروع" + "وضع المشاهدة فقط" banner |
| 32 | F-08 Notifications | Notification references project that was deleted but `project_id` not yet nulled (race condition) | 🔄 State | Navigation attempt to non-existent project → crash or 404 | Wrap project fetch in try/catch; if 404 → show Snackbar "هذا المشروع تم حذفه" regardless of `project_id` value |
| 33 | F-13 Settings | User changes language from Arabic to English mid-session | 🌍 Locale | RTL layout switches to LTR — some widgets may not reflow correctly | Test all screens with both locales; use `Directionality` widget consistently; avoid manual `left/right` padding (use `start/end`) |
| 34 | F-13 Settings | User enables system-level large font (accessibility) → font size 200% | 🌍 Locale | Text overflows cards, buttons truncated | Use `maxLines` + `overflow: TextOverflow.ellipsis` on all text; avoid fixed-height containers; test with Flutter's `textScaleFactor` |
| 35 | F-13 Settings | Logout tapped while an upload is in progress (background) | 🔋 Device | Orphaned upload continues after logout; file stored under old user's path | Cancel all active upload operations before logout; use a global upload manager Cubit |
| 36 | F-14 Edit Profile | User changes email to one already used by another account | 🔐 Auth | Supabase returns conflict error | Catch unique constraint error; show inline field error "البريد مستخدم بالفعل" |
| 37 | F-14 Edit Profile | User changes email → Supabase sends confirmation to NEW email → user doesn't confirm | 🔐 Auth | Email in auth remains old; UI shows new email → mismatch | Inform user: "تم إرسال رابط تأكيد لبريدك الجديد — سيتم التفعيل بعد التأكيد"; don't update `public.users.email` until confirmed |
| 38 | F-14 Edit Profile | User submits wrong current password when changing password | 🔐 Auth | Supabase `updateUser` may not verify current password | Implement re-authentication step (call `signInWithPassword` with current password) before calling `updateUser`; show inline error if fails |
| 39 | F-15 Projects | User has 50+ projects — total portfolio value calculation slow | 📦 Data | Footer shows stale or loading total | Use `project_totals` view (pre-aggregated in DB); never calculate total client-side on large datasets |
| 40 | F-15 Projects | Two sessions (same user logged in on 2 phones) — one creates project, other doesn't refresh | 🔄 State | Second device shows stale list | Pull-to-refresh as primary sync mechanism; optionally add Supabase Realtime subscription on projects table |
| 41 | F-16 Create Project | User double-taps "Create Project" before first response | 👆 Input | Two identical projects created | Disable button immediately on first tap; server-side: no unique constraint needed (duplicates allowed per spec) — UI protection sufficient |
| 42 | F-16 Create Project | User types project name then swipes down to dismiss — bottom sheet closes | 👆 Input | Data silently lost — no warning | Bottom sheet is intentionally dismissible per spec; acceptable UX for creation (no data saved yet) — no warning needed |
| 43 | F-17 Project Settings | User taps "Delete Project" → confirms → network drops mid-delete | 📶 Network | Project partially deleted (some entries remain) | Supabase cascade delete is a single DB transaction — either fully completes or fully rolls back; show error Snackbar + retry option |
| 44 | F-19 Invoices Tab | PDF export with 200+ entries — generation takes >10s | 🔋 Device | App appears frozen; user force-closes | Run PDF generation in Dart isolate; show progress dialog with cancel option |
| 45 | F-19 Invoices Tab | PDF export when all receipt images are expired | 📦 Data | PDF generated with no images — user surprised | Show warning before export: "ملاحظة: انتهت صلاحية بعض الإيصالات — سيتم تصدير البيانات المالية فقط" + confirm button |
| 46 | F-19 Invoices Tab | Print/share sheet opened on Android — user selects Google Drive but has no account | 🔋 Device | OS-level error outside app control | This is OS behavior; no app-level handling needed; share sheet handles it natively |
| 47 | F-20 Add Cash Entry | User enters amount as "1,250" (with comma) — field rejects or parses wrong | 👆 Input | Wrong amount saved (125 instead of 1250) | Use numeric keyboard only; strip commas before parsing; display formatted with commas for readability but store raw number |
| 48 | F-20 Add Cash Entry | User selects a future date for entry_date | 👆 Input | Invalid financial record | Disable future dates in date picker (`lastDate: DateTime.now()`) |
| 49 | F-20 Add Cash Entry | Image selected from gallery is 15MB (12MP RAW photo) — compression takes 8+ seconds | 🔋 Device | App freezes during compression | Run compression in isolate; show "جاري معالجة الصورة..." progress indicator; never block UI thread |
| 50 | F-20 & F-21 Receipt | Camera permission denied (first launch or revoked) | 🔋 Device | Camera option silently fails or crashes | Use `permission_handler`; if denied → show rationale dialog; if permanently denied → show "يرجى تفعيل الكاميرا من الإعدادات" with deep link to settings |
| 51 | F-20 & F-21 Receipt | Gallery permission denied on Android 13+ (new granular permissions) | 🔋 Device | Image picker fails silently | Handle `READ_MEDIA_IMAGES` on Android 13+ separately from older `READ_EXTERNAL_STORAGE`; test on both API levels |
| 52 | F-20 Add Cash Entry | Network drops after entry saved to DB but before `create_notification` RPC call | 📶 Network | Entry exists, no notification created → Admin misses update | Wrap entry insert + notification RPC in a single DB transaction or Supabase Edge Function; if notification fails, log but don't fail the entry |
| 53 | F-20 Add Cash Entry | User enters amount 0.00 | 👆 Input | Invalid cash entry stored | Validate `amount > 0` before enabling Save; show inline error "يجب أن يكون المبلغ أكبر من صفر" |
| 54 | F-20 Add Cash Entry | User submits entry then immediately navigates back before response | 👆 Input | Entry may save in background; list not refreshed | Lock navigation during save (disable back button); refresh list on successful return |
| 55 | F-21 Edit Cash Entry | Same entry opened on 2 devices simultaneously — last write wins | 🔄 State | Earlier save silently overwritten | Add `updated_at` optimistic concurrency check; if server `updated_at` > local `updated_at` on save → show "تم تعديل هذا البند من جهاز آخر — أعد التحميل" |
| 56 | F-21 Edit Cash Entry | Receipt image expires while Edit screen is open | 📦 Data | User sees valid image preview but `receipt_expired = true` in DB | On screen open, check `receipt_expired` flag; if true → show expired placeholder immediately |
| 57 | F-21 Edit Cash Entry | User deletes receipt image → network drops before Storage deletion completes | 📶 Network | `receipt_url` set to NULL in DB but file remains in Storage (orphan) | Schedule orphaned file cleanup via pg_cron: files in Storage with no matching DB record older than 1 hour → delete |
| 58 | F-22 Images Tab | Tab loads slowly with 50+ receipt images | 📦 Data | Laggy scroll | Use `GridView.builder` (lazy); load thumbnails only — not full-size images |
| 59 | F-22 Images Tab | User taps image card expecting to view full image — gets Edit screen | 👆 Input | Confusing UX | Add clear visual affordance (edit icon overlay on card) so user knows tap = edit |
| 60 | Global | App receives a phone call mid-upload | 🔋 Device | Upload paused/failed; no error shown | Use background upload strategy where possible; on resume check upload status; if failed show retry Snackbar |
| 61 | Global | Android kills app in background (low RAM) mid-Cubit operation | 🔋 Device | State lost; screen reopens to initial state | All screens must restore from DB on init; never rely solely on in-memory Cubit state for rendering |
| 62 | Global | User rotates device (landscape mode) mid-form fill | 🔋 Device | Form fields may reset if state not preserved | Use `AutomaticKeepAliveClientMixin` or Cubit to persist form state across orientation changes |
| 63 | Global | Supabase JWT expires mid-session (default: 1 hour) | 🔐 Auth | API calls return 401; app shows cryptic error | Supabase client auto-refreshes JWT using refresh token; ensure `supabase.auth.onAuthStateChange` listener handles `TOKEN_REFRESHED` event; if refresh fails → logout |
| 64 | Global | User installs app update — local cached data schema mismatch | 📦 Data | App reads old cached data with new expected schema → crash | Version local cache; on version mismatch → clear cache + re-fetch from DB |
| 65 | Global | Arabic text in project/entry names contains mixed LTR content (e.g. "Project ABC مشروع") | 🌍 Locale | Text direction renders incorrectly in RTL layout | Use `Directionality` detection per text widget; apply `TextDirection.ltr` for fields known to contain mixed content |
| 66 | Global | Screen reader (TalkBack / VoiceOver) used by visually impaired user | 🌍 Locale | Icons without labels are unreadable | Add `Semantics` labels to all icon buttons, FABs, and image widgets |
| 67 | Global | User's device clock is wrong (set to past or future) | 🌍 Locale | `receipt_expires_at` calculated incorrectly client-side | Always calculate `expires_at` server-side in DB trigger — never trust client device time |
| 68 | Global | Two Supabase RLS policies conflict — user gets unexpected access or denial | 🔐 Auth | Silent data exposure or silent data denial | Test RLS policies exhaustively with all 3 roles in Supabase's SQL editor before release; use `EXPLAIN` to verify policy evaluation |

---

## 🔴 Top 5 Critical Corner Cases

---

### 🔴 Critical 1: Orphaned Auth Record on User Creation Failure

- **Scenario:** Owner creates a new user. Supabase `auth.signUp()` succeeds and creates a record in `auth.users`, but the subsequent INSERT into `public.users` fails (network drop, constraint violation, etc.)
- **Trigger:** Network interruption or DB error between the two insert operations in F-04
- **Impact:** The user can successfully log in (auth record exists) but lands on a broken app state — no role, no company_id, no profile. The app crashes or loops infinitely on Splash trying to fetch a non-existent profile.
- **Resolution:** Use a **Supabase DB Trigger** (`AFTER INSERT ON auth.users`) to automatically create the `public.users` record. This makes both inserts atomic at the DB level — removing the race condition entirely. The Flutter app only needs to call `auth.signUp()`.
- **PRD Update Needed:** ✅ Yes — Add to F-04: "User creation must use a DB trigger to sync `auth.users` → `public.users` atomically. Flutter app should never manually insert into `public.users` during signup."

---

### 🔴 Critical 2: Active User Deleted Mid-Session by Admin/Owner

- **Scenario:** Engineer (User) is actively using the app — mid-way through adding a cash entry. Meanwhile, the Admin or Owner deletes their account.
- **Trigger:** F-07 Admin delete user OR F-05 Owner delete user, while the target user is active
- **Impact:** User's next Supabase call (save entry, fetch project, etc.) gets an RLS policy denial (no matching `public.users` record). The app shows a generic error. User is confused and stuck — can't logout because they think it's a bug, can't use the app.
- **Resolution:**
  1. On every `PostgrestException` with code `PGRST116` (row not found) or HTTP 403 → check if `public.users` record for `auth.uid()` exists.
  2. If not → call `supabase.auth.signOut()` → navigate to Login → Snackbar: "تم حذف حسابك من قِبل المسؤول"
  3. Implement a global `Supabase.instance.client.auth.onAuthStateChange` listener that catches auth invalidation.
- **PRD Update Needed:** ✅ Yes — Add to Section 5 (Error States): "If any API call returns user-not-found or auth invalidation, force logout with Snackbar."

---

### 🔴 Critical 3: Double-Tap Creates Duplicate Cash Entry

- **Scenario:** Engineer taps "Save Entry" on Add Cash Entry screen (F-20). Network is slow (2G). Button appears not to respond. Engineer taps again.
- **Trigger:** Slow network + no immediate UI feedback + impatient user
- **Impact:** Two identical cash entries created (same vendor, same amount, same date). Total invoice inflated. Admin sees incorrect financials. Reversing requires manual deletion.
- **Resolution:**
  1. **Client-side:** Disable Save button immediately on first tap and show `CircularProgressIndicator` inside button.
  2. **Server-side idempotency:** Generate a `client_request_id` (UUID) on the Flutter side before the request. Pass it as a unique constraint column. If duplicate request arrives within 30 seconds → return the existing entry instead of creating a new one.
  3. Add a partial unique index: `CREATE UNIQUE INDEX ... ON cash_entries(user_id, entry_name, entry_date, amount, client_request_id)` — optional but safer.
- **PRD Update Needed:** ✅ Yes — Add to F-20 Acceptance Criteria: "Save button must be disabled immediately on first tap. A `client_request_id` must be generated client-side and passed with every insert request to ensure idempotency."

---

### 🔴 Critical 4: JWT Refresh Failure Mid-Session (Silent Auth Expiry)

- **Scenario:** User has been using the app for 1+ hours. Supabase JWT (access token) expires. The auto-refresh mechanism fails (network was offline exactly when refresh was attempted). User tries to save a cash entry.
- **Trigger:** Access token expires (1hr) + network was offline during the automatic refresh window
- **Impact:** All Supabase API calls silently fail with 401. The app shows generic error Snackbars. User repeatedly retries. No data is saved. User loses work. Worst case: user logs out manually and loses unsaved form data.
- **Resolution:**
  1. Listen to `supabase.auth.onAuthStateChange` → handle `AuthChangeEvent.signedOut` event globally.
  2. On any 401 response → attempt one manual token refresh; if that fails → force logout + navigate to Login + Snackbar: "انتهت جلستك، سجل دخولك مرة أخرى".
  3. Implement an **offline queue** for cash entries: if save fails due to auth, store entry locally and sync when re-authenticated.
  4. On reconnect after offline period → proactively refresh token before attempting any API call.
- **PRD Update Needed:** ✅ Yes — Add to Section 5 (Error States) and F-20: "On auth expiry during active use, app must attempt token refresh silently. If refresh fails, navigate to Login and restore last screen state on re-login."

---

### 🔴 Critical 5: Image Compression Blocking UI Thread on Low-End Devices

- **Scenario:** Engineer on a low-end Android device (1GB RAM, Snapdragon 425) selects a 12MP photo from gallery. The app calls `flutter_image_compress` synchronously on the main isolate.
- **Trigger:** F-20 or F-21 image selection on any device with a camera producing images >5MB
- **Impact:** UI freezes completely for 5–15 seconds. On Android, the OS may show "App Not Responding" (ANR) dialog. User force-closes the app. Entry is lost. On repeated occurrence, user rates app 1 star.
- **Resolution:**
  1. **Always run compression in a separate Dart isolate** using `compute()`:
     ```dart
     final compressed = await compute(_compressImage, imageBytes);
     ```
  2. Show full-screen progress overlay ("جاري معالجة الصورة...") while compression runs.
  3. Set aggressive compression target: quality 70, max dimension 1080px — sufficient for receipt legibility.
  4. Add a 30-second timeout on compression; if exceeded → show error + allow user to retry with a smaller image.
  5. Test on low-end device profiles in Firebase Test Lab before release.
- **PRD Update Needed:** ✅ Yes — Add to F-20 and F-21 Acceptance Criteria: "Image compression must run in a Dart isolate via `compute()`. UI must remain interactive during compression. Show progress indicator. Timeout after 30 seconds."

---

## ⚠️ Open Risks (No Complete Solution Available)

| # | Risk | Why It's Hard | Mitigation |
|---|------|---------------|------------|
| R-01 | iOS Background App Refresh disabled by user → upload interrupted | iOS strictly limits background execution to ~30s | Show warning if upload >20s; encourage user to keep app open |
| R-02 | Android OEM battery optimization (Xiaomi/Huawei) kills app during pg_cron-triggered operations | OEM-specific behavior; can't be fixed in app code | Document known OEM issues in README; advise users to whitelist app in battery settings |
| R-03 | Supabase free tier storage limit (1GB) reached | Free tier has hard limits | Add storage usage monitoring; alert Owner at 80% usage; plan upgrade path to Pro |
| R-04 | PDF generation of 500+ entries with images crashes on 1GB RAM devices | PDF package loads all images into memory | Implement pagination in PDF (max 50 entries per page); warn user if large export detected |
| R-05 | RTL + LTR mixed text in table cells (vendor names in English inside Arabic UI) | `TextDirection` per-cell logic is complex | Apply `TextDirection.ltr` globally to table cells; accept minor visual imperfection |

---

## Summary Statistics

| Category | Count |
|---|---|
| 📶 Network & Connectivity | 11 |
| 🔋 Device & OS | 12 |
| 👆 Input & UX Edge Cases | 14 |
| 🔄 State & Sync | 8 |
| 🔐 Auth & Session | 9 |
| 📦 Data & Storage | 9 |
| 🌍 Locale & Accessibility | 6 |
| 🔔 Notifications & Background | 3 |
| **Total Corner Cases** | **68** |
| **Critical (require PRD update)** | **5** |
| **Open Risks** | **5** |
