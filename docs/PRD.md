# 📱 Product Requirements Document (PRD)
**Project:** Cashes — Financial Ledger & Cash Management App
**Version:** 1.0.0
**Status:** Draft
**Based on:** BRD v1.4.0 · Supabase Schema v1.0.0
**Last Updated:** 2025

---

## 1. Product Vision

**Cashes** empowers construction and finishing companies to eliminate untracked cash disbursements by giving site engineers a simple, structured way to log expenses — while giving company admins real-time oversight of all financial activity across their teams.

**One-liner:** "كل عهدة في مكانها، كل مصروف موثق."

---

## 2. Global UX Standards

> These rules apply to **every screen** in the app without exception.

### 2.1 Snackbar Feedback

Every state-changing action must trigger a **Snackbar** at the bottom of the screen.

| Action | Snackbar Message (AR) | Type |
|---|---|---|
| Login success | تم تسجيل الدخول بنجاح ✓ | Success 🟢 |
| Login failed | البريد أو كلمة السر غير صحيحة | Error 🔴 |
| Logout | تم تسجيل الخروج | Info ⚪ |
| Password reset sent | تم إرسال رابط إعادة التعيين على بريدك | Success 🟢 |
| Company added | تم إضافة الشركة بنجاح ✓ | Success 🟢 |
| Company updated | تم تحديث بيانات الشركة ✓ | Success 🟢 |
| Company deleted | تم حذف الشركة وجميع بياناتها | Warning 🟡 |
| User created | تم إنشاء الحساب وإرسال البيانات بالبريد ✓ | Success 🟢 |
| User updated | تم تحديث بيانات المستخدم ✓ | Success 🟢 |
| User deleted | تم حذف المستخدم وجميع بياناتها | Warning 🟡 |
| Profile updated | تم حفظ التغييرات ✓ | Success 🟢 |
| Password changed | تم تغيير كلمة السر بنجاح ✓ | Success 🟢 |
| Project created | تم إنشاء المشروع بنجاح ✓ | Success 🟢 |
| Project updated | تم تحديث اسم المشروع ✓ | Success 🟢 |
| Project deleted | تم حذف المشروع وجميع بياناته | Warning 🟡 |
| Cash entry added | تم إضافة البند بنجاح ✓ | Success 🟢 |
| Cash entry updated | تم تحديث البند بنجاح ✓ | Success 🟢 |
| Cash entry deleted | تم حذف البند بنجاح | Warning 🟡 |
| Image uploaded | تم رفع الصورة بنجاح ✓ | Success 🟢 |
| Image deleted | تم حذف الصورة | Warning 🟡 |
| Notification deleted | تم حذف الإشعار | Info ⚪ |
| PDF exported | تم تصدير الملف بنجاح ✓ | Success 🟢 |
| No internet | لا يوجد اتصال بالإنترنت | Error 🔴 |
| Generic error | حدث خطأ، يرجى المحاولة مرة أخرى | Error 🔴 |

**Snackbar Specs:**
- Duration: 3 seconds
- Position: bottom of screen above nav bar
- Max 1 snackbar at a time (new one dismisses the previous)
- Action button optional (e.g., "تراجع" for non-destructive deletes if applicable)

---

### 2.2 Confirmation Dialogs

Every **destructive or irreversible action** must show a confirmation dialog before execution.

| Trigger | Dialog Title | Dialog Body | Confirm Button | Cancel Button |
|---|---|---|---|---|
| Delete company | حذف الشركة | سيتم حذف الشركة وجميع المستخدمين والمشاريع والبيانات المرتبطة بها نهائياً. هل أنت متأكد؟ | حذف نهائي 🔴 | إلغاء |
| Delete user | حذف المستخدم | سيتم حذف المستخدم وجميع مشاريعه وبنوده والصور المرتبطة به نهائياً. هل أنت متأكد؟ | حذف نهائي 🔴 | إلغاء |
| Delete project | حذف المشروع | سيتم حذف المشروع وجميع البنود والإيصالات المرتبطة به نهائياً. هل أنت متأكد؟ | حذف نهائي 🔴 | إلغاء |
| Delete cash entry | حذف البند | سيتم حذف هذا البند نهائياً ولا يمكن استرجاعه. هل أنت متأكد؟ | حذف 🔴 | إلغاء |
| Delete receipt image | حذف الإيصال | سيتم حذف صورة الإيصال نهائياً. بيانات البند ستبقى كما هي. هل أنت متأكد؟ | حذف 🔴 | إلغاء |
| Logout | تسجيل الخروج | هل تريد تسجيل الخروج من حسابك؟ | خروج | إلغاء |
| Delete notification | حذف الإشعار | هل تريد حذف هذا الإشعار؟ | حذف | إلغاء |

**Dialog Specs:**
- Confirm button always in **Red** for destructive actions
- Cancel button always on the **left** (RTL: right side visually)
- Dialog must be **dismissible** by tapping outside (= Cancel)
- Dialog must not be dismissible during loading state

---

### 2.3 Loading States

- Every async operation shows a **CircularProgressIndicator** inside the button (button disabled during load)
- Full-screen loader only for initial data fetch on screen open
- Skeleton shimmer for lists while loading

### 2.4 Empty States

Every list screen must have a dedicated empty state:

| Screen | Empty State Message (AR) |
|---|---|
| Companies list | لا توجد شركات مسجلة حتى الآن |
| Users list | لا يوجد مستخدمون في هذه الشركة |
| Projects list | لا توجد مشاريع بعد — ابدأ بإضافة مشروع جديد |
| Cash entries | لا توجد بنود مالية — أضف أول بند لهذا المشروع |
| Images Tab (receipts) | لا توجد إيصالات مرفقة — أضف إيصالاً عند تسجيل أي بند |
| Notifications | لا توجد إشعارات جديدة |

---

## 3. Feature Specifications by Phase

---

### 📌 Phase 1 — Owner Panel

---

#### F-01 · Companies List Screen

**Purpose:** Global overview of all tenants on the platform.

**Acceptance Criteria:**
- [ ] List loads all companies sorted by `created_at` descending
- [ ] Each card displays: logo (or placeholder icon), company name, user count
- [ ] Search filters companies by name in real-time (client-side)
- [ ] Filter icon opens filter bottom sheet (filter by active/inactive — future)
- [ ] Active count badge shows total companies
- [ ] Statistics section shows: Total Users (sum across all companies), Total Companies
- [ ] Sync status indicator shows "N Companies currently synced"
- [ ] `+ ADD COMPANY` navigates to Company Profile Setup screen
- [ ] `+ ADD USER` navigates to Create Account screen
- [ ] Tapping a company card navigates to Users List for that company
- [ ] Pull-to-refresh reloads data

**Edge Cases:**
- No companies yet → show empty state
- Logo fails to load → show company initials as placeholder avatar
- Search returns no results → show "لا توجد نتائج لبحثك"

---

#### F-02 · Add Company Screen

**Purpose:** Owner creates a new tenant company.

**Acceptance Criteria:**
- [ ] Company Name field: required, min 2 chars, max 100 chars
- [ ] Logo upload: optional, PNG/JPG only, compressed to max 500KB before upload
- [ ] Logo picker opens: Camera or Gallery chooser bottom sheet
- [ ] Logo preview shown immediately after selection
- [ ] `Add Company Profile` button disabled until name is filled
- [ ] On success: navigate back to Companies List + Snackbar ✅
- [ ] On failure: show error Snackbar 🔴

**Edge Cases:**
- Company name already exists → show inline field error: "اسم الشركة موجود بالفعل"
- Image too large after compression → show error Snackbar

---

#### F-03 · Edit Company Screen

**Purpose:** Owner edits or deletes an existing company.

**Acceptance Criteria:**
- [ ] Screen pre-filled with existing company data
- [ ] Company Name: editable, same validation as Add
- [ ] Logo: shows existing logo; tapping opens camera/gallery picker
- [ ] `Save Changes` disabled if no changes made
- [ ] On save success: navigate back + Snackbar ✅
- [ ] `DELETE COMPANY` button → Confirmation Dialog → on confirm: delete + navigate to Companies List + Snackbar 🟡
- [ ] Cascade delete: all users, projects, cash entries, images deleted

**Edge Cases:**
- Save with same name → allowed (no change)
- Delete while offline → show error Snackbar

---

#### F-04 · Create User Account Screen

**Purpose:** Owner creates a new user account and assigns it to a company.

**Acceptance Criteria:**
- [ ] Full Name: required, min 2 chars
- [ ] Company: required dropdown — populated from existing companies list
- [ ] Email: required, valid format, unique across platform
- [ ] Password: required, min 8 characters, show/hide toggle
- [ ] Confirm Password: must match password exactly
- [ ] `Create Account` disabled until all fields valid
- [ ] On success: user created in `auth.users` + `public.users` → system sends credentials email → Snackbar ✅
- [ ] Default role assigned: `user` (engineer)
- [ ] To create an Admin: Owner manually sets role in Supabase (v1 — no UI for role selection)

**Edge Cases:**
- Email already registered → inline error: "البريد الإلكتروني مستخدم بالفعل"
- Passwords don't match → inline error on Confirm field
- No companies exist → show warning: "أضف شركة أولاً قبل إنشاء مستخدم"

---

#### F-05 · Edit User Screen (CEO Panel)

**Purpose:** Owner updates user info or deletes a user.

**Acceptance Criteria:**
- [ ] Pre-filled: Full Name, Company (dropdown)
- [ ] Owner can reassign user to a different company
- [ ] `Save Changes` disabled if no changes made
- [ ] On save success: Snackbar ✅
- [ ] `Delete User` → Confirmation Dialog → on confirm: delete user + all their data + Snackbar 🟡
- [ ] Navigate back to Users List after delete

**Edge Cases:**
- Reassigning user to a different company: their existing projects stay (company_id on projects updates accordingly)

---

#### F-06 · Users List (Per Company) — Owner View

**Purpose:** Owner sees all users in a company and can drill into each one.

**Acceptance Criteria:**
- [ ] Header shows company name
- [ ] Search by name or email (real-time, client-side)
- [ ] Each card: Avatar, Full Name, Email
- [ ] Tapping a card: navigates to that user's Projects list (read-only mode)
- [ ] Read-only mode: no FAB, no edit/delete options on projects or entries
- [ ] Read-only banner shown at top: "وضع المشاهدة فقط"
- [ ] Pull-to-refresh

**Edge Cases:**
- No users in company → empty state
- Avatar fails → initials placeholder

---

### 📌 Phase 2 — Company Admin Panel

---

#### F-07 · Admin — All Users Screen

**Purpose:** Admin manages engineers in their company.

**Acceptance Criteria:**
- [ ] Shows only users with `company_id = auth_company_id()` and `role = 'user'`
- [ ] Search by name or email
- [ ] Each card: Avatar, Full Name, Email, Delete icon 🗑️
- [ ] Tapping delete icon → Confirmation Dialog → delete user + Snackbar 🟡
- [ ] Tapping user card → navigates to that user's Projects (read-only)
- [ ] Read-only banner shown: "وضع المشاهدة فقط"
- [ ] Unread notification badge on Notifications tab

**Edge Cases:**
- Admin cannot delete other admins (UI hides delete icon for admin-role users)
- Last user in company can still be deleted

---

#### F-08 · Admin — Notifications Screen

**Purpose:** Admin reviews activity log of engineers' actions.

**Acceptance Criteria:**
- [ ] Fetches notifications where `company_id = auth_company_id()`, sorted by `created_at DESC`
- [ ] Each card shows: type tag (color-coded), engineer name, message, date & time, delete icon
- [ ] **Type colors:**
  - `new_assignment` → Gold/Yellow border
  - `update_log` → Purple/Lilac border
  - `structural_alert` → Pink/Red border
  - `archived` → Gray border
- [ ] Unread notifications show subtle highlight background
- [ ] Tapping a card → marks as read (`is_read = true`) + navigates:
  - `project_id` not null → opens that user's project (read-only)
  - `project_id` is null → Snackbar: "هذا المشروع تم حذفه"
- [ ] Delete icon → Confirmation Dialog → delete notification + Snackbar ⚪
- [ ] Refresh button in header → re-fetches list + brief loading indicator
- [ ] Badge counter on tab = count of `is_read = false` notifications
- [ ] Pull-to-refresh

**Edge Cases:**
- No notifications → empty state
- Engineer name snapshot shown even if user is later deleted

---

### 📌 Phase 3 — Authentication

---

#### F-09 · Splash Screen

**Purpose:** App entry point — determines routing based on auth state.

**Acceptance Criteria:**
- [ ] Show app logo + name "Cashes" + loading bar
- [ ] "Powered by" footer visible
- [ ] Check Supabase session:
  - Session exists → fetch user role from `public.users`
    - `owner` → navigate to Companies List (CEO Panel)
    - `admin` → navigate to Admin Users Screen
    - `user` → navigate to Projects Overview
  - No session → navigate to Login Screen
- [ ] Minimum splash duration: 1.5 seconds (for branding)

**Edge Cases:**
- Session exists but user deleted from DB → clear session + navigate to Login
- No internet on first open → show offline message

---

#### F-10 · Login Screen

**Purpose:** All users authenticate with email + password.

**Acceptance Criteria:**
- [ ] Email field: required, keyboard type email
- [ ] Password field: required, masked, show/hide toggle
- [ ] `Forgot Password?` link → navigates to Forgot Password screen
- [ ] `Login` button disabled until both fields filled
- [ ] On success: navigate based on role (same as Splash logic) + Snackbar ✅
- [ ] On failure: Snackbar 🔴 "البريد أو كلمة السر غير صحيحة"
- [ ] No self-registration — no "Create Account" link visible

**Edge Cases:**
- User account deleted by Owner/Admin → show Snackbar: "هذا الحساب غير موجود"
- Too many failed attempts → Supabase handles rate limiting; show: "حاولت كثيراً، انتظر قليلاً"

---

#### F-11 · Forgot Password Screen

**Purpose:** User requests password reset via email.

**Acceptance Criteria:**
- [ ] Email field: required, valid format
- [ ] `Send Reset Link` button disabled until email filled
- [ ] On submit: call Supabase Auth `resetPasswordForEmail()`
- [ ] On success: navigate to Email Sent Confirmation screen + Snackbar ✅
- [ ] On failure: Snackbar 🔴

**Edge Cases:**
- Email not registered → still show success (security best practice — don't confirm email existence)

---

#### F-12 · Email Sent Confirmation Screen

**Purpose:** Inform user the reset email was sent.

**Acceptance Criteria:**
- [ ] Static confirmation message and email icon
- [ ] `← Back to Login` link
- [ ] No back navigation via device back button (force user to use the link)

---

### 📌 Phase 4 — Settings

---

#### F-13 · Settings Main Screen

**Purpose:** User manages preferences and account.

**Acceptance Criteria:**
- [ ] Profile card: avatar (with edit pencil icon), full name, email
- [ ] Tapping pencil on avatar → image picker (camera/gallery) → upload → update `avatar_url` + Snackbar ✅
- [ ] `Personal Information →` navigates to Edit Profile screen
- [ ] Language toggle: English / Arabic — changes app locale immediately (RTL ↔ LTR)
- [ ] Language preference persisted in local storage
- [ ] Appearance toggle: Dark / Light — changes theme immediately
- [ ] Theme preference persisted in local storage
- [ ] `Logout Account` → Confirmation Dialog → logout + navigate to Login + Snackbar ⚪
- [ ] App version shown at bottom

**Defaults:**
- Theme: Dark
- Language: Arabic (RTL)

**Edge Cases:**
- Avatar upload fails → Snackbar 🔴, keep old avatar

---

#### F-14 · Edit Profile / Personal Information Screen

**Purpose:** User updates name, email, and password.

**Acceptance Criteria:**
- [ ] Avatar with camera icon: tap to update photo
- [ ] Full Name: editable, required, min 2 chars
- [ ] Email Address: editable, required, valid format, unique check on save
- [ ] Password section (optional — only if user wants to change):
  - Current Password: required if new password is entered
  - New Password: min 8 chars
  - Confirm New Password: must match
- [ ] `Save Changes` disabled if no fields changed
- [ ] On name/email change: update `public.users` + Supabase Auth email + Snackbar ✅
- [ ] On password change: verify current password first → update + Snackbar ✅
- [ ] On wrong current password: inline error: "كلمة السر الحالية غير صحيحة"

**Edge Cases:**
- New email already used by another account → inline error
- Passwords don't match → inline error on confirm field

---

### 📌 Phase 5 — Projects Management

---

#### F-15 · Projects Overview / Home Screen

**Purpose:** Engineer's main screen — view and manage all their projects.

**Acceptance Criteria:**
- [ ] Header: "Welcome [First Name]", logout icon (top-left), settings icon (top-right)
- [ ] Section label: "CURATED OVERVIEW — Active Developments"
- [ ] Search: filters projects by name (real-time, client-side)
- [ ] Each project card shows: name, creation date, total amount (sum of entries)
- [ ] Three-dot `⋮` menu on each card → opens Project Settings bottom sheet
- [ ] Total Portfolio Value footer: sum of all project totals
- [ ] FAB `+` → opens Create Project bottom sheet
- [ ] Projects scoped to `user_id = auth.uid()` only
- [ ] Pull-to-refresh
- [ ] Tapping a project card → navigates to Project Details screen

**Edge Cases:**
- No projects → empty state with prompt to add first project
- Project with 0 entries → shows $0.00

---

#### F-16 · Create Project Bottom Sheet

**Purpose:** Engineer initiates a new project.

**Acceptance Criteria:**
- [ ] Modal bottom sheet — dismissible by swipe down or tapping Cancel
- [ ] Project Name field: required, min 2 chars, max 150 chars
- [ ] `Create Project` disabled until name filled
- [ ] On success: sheet closes, project appears at top of list, Snackbar ✅
- [ ] Notification auto-created: `new_assignment` → company admin sees it
- [ ] `Cancel` dismisses sheet with no action

**Edge Cases:**
- Duplicate project name: allowed (same user can have projects with same name)
- Sheet dismissed mid-typing → no project created, no snackbar

---

#### F-17 · Project Settings Bottom Sheet

**Purpose:** Engineer edits or deletes an existing project.

**Acceptance Criteria:**
- [ ] Pre-filled with current project name
- [ ] Project Name: editable, same validation
- [ ] `Save Changes` disabled if name unchanged
- [ ] On save: sheet closes, list updates, Snackbar ✅
- [ ] Notification auto-created: `update_log`
- [ ] `Delete Project` → Confirmation Dialog → on confirm: delete project + all entries + all receipts → sheet closes, project removed from list, Snackbar 🟡
- [ ] Notification auto-created: `archived`
- [ ] `Cancel` dismisses

**Edge Cases:**
- Delete project that has entries → cascade delete all entries + their receipt images from Storage

---

### 📌 Phase 6 — Invoices & Cash Entries

---

#### F-18 · Project Details Screen

**Purpose:** Container for Invoices and Images tabs.

**Acceptance Criteria:**
- [ ] Header: project name, Refresh icon, Print/Export icon
- [ ] Two tabs: 📋 INVOICES (default) | 🖼️ IMAGES
- [ ] Refresh icon: re-fetches current tab data + brief indicator
- [ ] Print icon: available on INVOICES tab only → generates PDF
- [ ] FAB `+`: visible on **INVOICES tab only** → Add Cash Entry
- [ ] **IMAGES tab has no FAB** — receipts added only through Add/Edit Cash Entry
- [ ] Back navigation returns to Projects list

---

#### F-19 · Invoices Tab — Financial Ledger

**Purpose:** View and manage all cash entries for a project.

**Acceptance Criteria:**
- [ ] Summary card: TOTAL INVOICED (sum of all entries), last updated timestamp
- [ ] Table: DATE | VENDOR/ENTITY | AMOUNT — sorted newest first
- [ ] Tapping a row → navigates to Edit Cash Entry screen
- [ ] **PDF Export (Print icon):**
  - Generates formatted PDF with: project name, company logo, all entries table, receipt image thumbnails (if not expired), grand total
  - Opens share sheet (save/print/share)
  - Snackbar ✅ on success
- [ ] **Image expiry warning:** if any entry has receipt expiring within 5 days → show banner: "⚠️ بعض الإيصالات ستنتهي صلاحيتها خلال 5 أيام — صدّر PDF الآن"
- [ ] Expired receipt: row shows 📷 icon with "انتهت صلاحية الإيصال" instead of image

**Edge Cases:**
- No entries → empty state with prompt
- All receipts expired → PDF generated without images (entries data preserved)

---

#### F-20 · Add Cash Entry Screen

**Purpose:** Engineer logs a new expense with documentation.

**Acceptance Criteria:**
- [ ] `LIVE PROJECT` badge visible in header
- [ ] Transaction Amount: large tap-to-edit numeric display, required, > 0
- [ ] Entry Name (vendor): required, min 2 chars
- [ ] Date: date picker, defaults to today, cannot be future date
- [ ] Receipt Image (**optional** — can save entry without image):
  - Tap image area → bottom sheet with 2 options:
    - 📷 **Camera** — take photo directly
    - 🖼️ **Gallery** — pick from device photos
  - Single image only per entry
  - Compressed to max 500KB before upload (runs in Dart isolate)
  - Preview shown inline after selection
  - Tap preview → remove image option (before saving)
- [ ] `Save Entry` disabled until amount and entry name are filled
- [ ] On save: entry added, navigate back to Invoices tab, total updates, Snackbar ✅
- [ ] Notification auto-created: `update_log` (بند جديد أُضيف للمشروع)

**Edge Cases:**
- Amount = 0 → inline error: "يجب أن يكون المبلغ أكبر من صفر"
- Image selection cancelled → no image attached (allowed)
- Upload fails → Snackbar 🔴, offer retry

---

#### F-21 · Edit Cash Entry Screen

**Purpose:** Engineer modifies or deletes an existing entry.

**Acceptance Criteria:**
- [ ] Pre-filled: amount, entry name, date, receipt image (if exists and not expired)
- [ ] All fields editable with same validation as Add
- [ ] Receipt section:
  - If receipt exists and not expired: show preview + delete icon (🗑️)
  - Tapping delete icon → Confirmation Dialog → removes image → Snackbar 🟡
  - If no receipt OR deleted OR expired: show "أرفق إيصال" area → tap → bottom sheet:
    - 📷 **Camera** — take photo directly
    - 🖼️ **Gallery** — pick from device photos
  - One receipt per entry — replacing = delete old + upload new
  - Receipt is **optional** — entry can be saved without image
- [ ] `Save Changes` disabled if nothing changed
- [ ] On save: navigate back, table updates, Snackbar ✅
- [ ] Notification auto-created: `update_log`
- [ ] `Delete Entry` link → Confirmation Dialog → delete entry + receipt image → navigate back, Snackbar 🟡
- [ ] Notification auto-created: `structural_alert`
- [ ] Expired receipt: shown as placeholder with label "انتهت صلاحية الإيصال — أرفق إيصال جديد"

**Edge Cases:**
- Entry date changed to past date → allowed
- Editing entry while offline → show error Snackbar, block save

---

#### F-22 · Images Tab — Receipt Gallery View

**Purpose:** Visual grid of all receipt images attached to cash entries in this project.

**Acceptance Criteria:**
- [ ] Queries `cash_entries` WHERE `project_id = current` AND `receipt_url IS NOT NULL` AND `receipt_expired = FALSE`
- [ ] Displays results as a grid/masonry layout — each card shows:
  - Receipt image thumbnail
  - Entry name (vendor)
  - Entry date
  - Amount
- [ ] Tapping an image card → opens Edit Cash Entry screen for that entry
- [ ] **No FAB** on Images tab — images are added only via Add/Edit Cash Entry
- [ ] If no entries have receipts → empty state: "لا توجد إيصالات مرفقة — أضف إيصالاً عند تسجيل أي بند"
- [ ] Entries with `receipt_expired = TRUE` → not shown in this tab (filtered out)
- [ ] Expiry warning banner if any receipt expires within 5 days

**Image Source Options (in Add/Edit Cash Entry):**
- [ ] Camera → take photo directly
- [ ] Gallery → pick from device photos
- [ ] Both options shown in a bottom sheet picker when tapping the image area

**Edge Cases:**
- All receipts expired → empty state (tab shows 0 images)
- Entry has no receipt → not shown in Images tab (filtered)

---

## 4. Navigation Flow

```
Splash Screen
├── [Owner]  → Companies List
│               ├── Company Card → Users List (per company)
│               │     └── User Card → Projects (read-only)
│               │                       └── Project → Invoices + Images (read-only)
│               ├── ADD COMPANY → Add Company
│               └── ADD USER   → Create Account
│
├── [Admin]  → Users List (company-scoped)
│               ├── User Card → Projects (read-only)
│               │               └── Project → Invoices + Images (read-only)
│               └── Tab: Notifications
│                     └── Notification tap → Project (read-only) OR "تم حذف المشروع"
│
└── [User]   → Projects Overview
                ├── Project Card → Project Details
                │     ├── Tab: Invoices
                │     │     ├── Row tap → Edit Cash Entry
                │     │     └── FAB (+) → Add Cash Entry
                │     └── Tab: Images
                │           └── (read-only grid of receipts — tap card → Edit Cash Entry)
                ├── FAB (+) → Create Project (bottom sheet)
                └── ⋮ menu → Project Settings (bottom sheet)

All roles:
Settings (⚙️ icon) → Settings Main → Personal Information → Edit Profile
```

---

## 5. Error States

| State | Behavior |
|---|---|
| **No Internet** | Show offline banner at top + disable all save/upload actions + Snackbar 🔴 |
| **Session Expired** | Auto-redirect to Login + Snackbar "انتهت جلستك، سجل دخولك مجدداً" |
| **Permission Denied (RLS)** | Snackbar 🔴 "ليس لديك صلاحية للوصول لهذه البيانات" |
| **Upload Failed** | Snackbar 🔴 with retry option |
| **PDF Generation Failed** | Snackbar 🔴 "فشل تصدير الملف، حاول مرة أخرى" |
| **Image Compression Failed** | Snackbar 🔴 "فشل معالجة الصورة، اختر صورة أخرى" |
| **Server Error (500)** | Snackbar 🔴 "حدث خطأ في الخادم، يرجى المحاولة لاحقاً" |

---

## 6. Feature Priority Matrix

### Must Have (P0 — v1.0 Launch)
- [ ] F-09 Splash + routing by role
- [ ] F-10 Login
- [ ] F-11 Forgot Password
- [ ] F-01 Companies List (Owner)
- [ ] F-02 Add Company
- [ ] F-04 Create User
- [ ] F-07 Admin Users List
- [ ] F-08 Notifications
- [ ] F-15 Projects Overview
- [ ] F-16 Create Project
- [ ] F-19 Invoices Tab
- [ ] F-20 Add Cash Entry
- [ ] F-21 Edit Cash Entry
- [ ] F-13 Settings (theme + language + logout)

### Should Have (P1 — v1.0)
- [ ] F-03 Edit Company
- [ ] F-05 Edit User
- [ ] F-06 Users List (Owner drill-down)
- [ ] F-12 Email Sent Confirmation
- [ ] F-14 Edit Profile
- [ ] F-17 Project Settings (edit + delete)
- [ ] F-22 Images Tab (receipt gallery)
- [ ] PDF Export (part of F-19)

### Nice to Have (P2 — v1.1)
- [ ] Image expiry warning banner
- [ ] Skeleton shimmer loading
- [ ] Pull-to-refresh on all screens
- [ ] Full-screen receipt image viewer

---

## 7. Platform & Technical Constraints

| Constraint | Detail |
|---|---|
| **Platforms** | iOS 13+ · Android 6.0+ |
| **Flutter Version** | Latest stable |
| **State Management** | Cubit (flutter_bloc) |
| **Architecture** | Clean Architecture (Data / Domain / Presentation) |
| **Backend** | Supabase (PostgreSQL + Auth + Storage + pg_cron) |
| **Image Compression** | `flutter_image_compress` package — target 500KB max |
| **PDF Generation** | `pdf` + `printing` packages |
| **Localization** | `flutter_localizations` + ARB files (AR + EN) |
| **Theming** | `ThemeData` with dark/light modes, persisted via `shared_preferences` |
| **Responsiveness** | `MediaQuery` + relative sizing — no hardcoded pixels |
| **Offline** | Supabase local cache for read operations |

---

## 8. Localization Requirements

- All UI strings in ARB files — no hardcoded strings in widgets
- Arabic is default locale (RTL layout)
- Language change triggers full app locale rebuild
- Date formats: Arabic locale uses `dd/MM/yyyy`
- Currency: displays as entered (no auto-formatting locale — single currency)
- Snackbar messages: follow current app locale

---

## 9. Image Lifecycle Summary

```
Upload receipt → compress to ≤500KB → store in Supabase Storage
              → record receipt_uploaded_at + receipt_expires_at (upload + 30 days)

Day 25 → in-app warning banner on affected cash entries
Day 30 → pg_cron runs:
       → receipt_url set to NULL
       → receipt_expired = TRUE
       → UI shows placeholder + "انتهت صلاحية الإيصال"

PDF export recommended BEFORE day 30 to preserve full record with receipt images.
Financial data (amount, vendor, date) NEVER deleted — only the image file expires.
```

---

## 10. Out of Scope (v1.0)

- In-app messaging between users
- Multi-currency support
- Project status workflows (active / completed / on-hold)
- Owner analytics dashboard
- Third-party accounting integrations
- Web admin panel
- User self-registration
- Role selection UI (admin role set manually in Supabase)
- Push notifications (background / when app closed)
