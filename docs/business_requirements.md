# 📋 Business Requirements Document (BRD)
**Project:** Cashes — Financial Ledger & Cash Management App
**Version:** 1.4.0
**Status:** In Review
**Last Updated:** 2025

---

## 1. Executive Summary

**Cashes** is a multi-tenant SaaS mobile application built for construction and finishing companies to streamline cash management, vendor invoicing, and site-level expense tracking. The system enables a hierarchical control structure — from a global platform Owner, down to per-company Admins, and finally to field-level site engineers (Users) — each operating within isolated tenant boundaries.

The app solves three core problems:
- **Untracked cash disbursements** on construction sites
- **Lack of real-time financial visibility** for company accountants/admins
- **No centralized receipts/documentation** system for engineering teams

---

## 2. System Overview

| Property | Value |
|---|---|
| **App Name** | Cashes |
| **Platform** | Flutter (iOS + Android) |
| **Architecture** | Clean Architecture + Cubit State Management |
| **Backend Model** | Multi-Tenant SaaS |
| **Backend Provider** | Supabase (PostgreSQL + Auth + Storage) |
| **Future Migration Path** | Laravel (connects directly to same PostgreSQL DB) |
| **Languages** | Arabic 🇪🇬 + English 🇺🇸 |
| **Themes** | Dark Mode + Light Mode |
| **Auth Provider** | Email/Password with Reset Link |

---

## 3. Multi-Tenant Architecture

The system is structured as a **multi-tenant SaaS platform** where:

- Each **Company** is an isolated tenant with its own data boundary
- Users within a company **cannot access** data from other companies
- Only the **Owner (CEO)** has cross-tenant visibility
- Data isolation is enforced at the **database query level** using `company_id` scoping
- The Owner's panel is a **super-admin layer** above all tenants

```
OWNER (Platform Level)
    └── Company A (Tenant 1)
    │       ├── Admin A
    │       └── Users (Engineers) → Projects → Cash Entries
    └── Company B (Tenant 2)
            ├── Admin B
            └── Users (Engineers) → Projects → Cash Entries
```

---

## 4. User Roles & Permissions

### 4.1 Owner (CEO / Platform Super Admin)

> The platform owner. Has global visibility across all tenants. Only one Owner exists per platform instance.

| Permission | Allowed |
|---|---|
| View all companies | ✅ |
| Add / Edit / Delete company | ✅ |
| Upload company logo | ✅ |
| View all users across all companies | ✅ |
| Create user accounts | ✅ |
| Edit user info (name, company assignment) | ✅ |
| Delete users | ✅ |
| View overview statistics (total users, total companies) | ✅ |
| **Enter any company → view Admin panel** (users list + notifications) | ✅ |
| **Enter any user → view all their projects & cash entries** (read-only) | ✅ |
| Add / Edit cash entries on behalf of users | ❌ |

---

### 4.2 Admin (Company Admin / Accountant)

> One Admin per company. Acts as the accountant or office manager. Has visibility into their company only.

| Permission | Allowed |
|---|---|
| View all users within their company | ✅ |
| Delete users within their company | ✅ |
| View real-time notifications/alerts | ✅ |
| Delete notifications | ✅ |
| Access Settings (profile, language, theme) | ✅ |
| **Enter any user → view all their projects & cash entries** (read-only) | ✅ |
| Create new users | ❌ (Owner only) |
| Access other companies' data | ❌ |
| Add / Edit projects or cash entries | ❌ |

---

### 4.3 User (Site Engineer)

> Field-level engineer. Belongs to exactly one company. Core data producer in the system.

| Permission | Allowed |
|---|---|
| Login with credentials | ✅ |
| Reset forgotten password | ✅ |
| View their own projects only | ✅ |
| Create / Edit / Delete projects | ✅ |
| Add / Edit / Delete cash entries per project | ✅ |
| Attach receipt images to cash entries | ✅ |
| View project images gallery | ✅ |
| Export financial ledger as PDF | ✅ |
| Print financial ledger | ✅ |
| Update personal info & password | ✅ |
| Change language & theme | ✅ |
| Access other users' projects | ❌ |

---

## 5. Functional Requirements by Phase

---

### 📌 Phase 1 — Owner Panel (CEO Super Admin)

**Entry Point:** Dedicated CEO panel, accessible only to the platform owner.

#### 5.1.1 Companies Management Screen

- Display a **searchable list** of all registered companies
- Each company card shows:
  - Company Logo
  - Company Name
  - Total number of active users
- Show **filter** option (filter icon)
- Display **Overview Statistics** section at bottom:
  - Total Users (aggregated across all companies)
  - Total Companies
  - Live sync status indicator (e.g., "4 Companies currently synced")
- Show **active companies count** (e.g., "4 ACTIVE")
- Two primary action buttons:
  - `+ ADD COMPANY` → opens Company Profile Setup screen
  - `+ ADD USER` → opens Create Account screen

#### 5.1.2 Company Profile Setup (Add Company)

- Form fields:
  - **Company Name** (text input, required)
  - **Brand Identity / Logo** (image picker, PNG/JPG, max 10MB)
- Action: `Add Company Profile` button → saves and returns to list

#### 5.1.3 Edit Company

- Pre-filled form with existing company data
- Editable fields: Company Name, Logo
- Actions:
  - `Save Changes` — updates company record
  - `DELETE COMPANY` — permanently deletes company and cascades to associated users/data (with confirmation dialog)

#### 5.1.4 Create User Account (From CEO Panel)

- Form fields:
  - **Full Name** (text input, required)
  - **Company** (dropdown, select from existing companies, required)
  - **Email Address** (required, unique)
  - **Password** (required, min 8 characters)
  - **Confirm Password** (must match password)
- Action: `Create Account` button
- System auto-sends credentials to user's email
- User role is assigned as **User** by default unless marked as Admin

#### 5.1.5 Edit User (From CEO Panel)

- Pre-filled form with:
  - **Full Name**
  - **Company** (can reassign user to a different company)
- Actions:
  - `Save Changes` — updates user record
  - `Delete User` — permanently deletes user (with confirmation dialog)

#### 5.1.6 Users List View (Per Company)

- Accessed by tapping a company card
- Header shows company name
- Searchable list by name or email
- Each user card shows: Avatar, Full Name, Email
- **Tapping a user card** → Owner enters a read-only view of that user's profile showing:
  - All projects belonging to that user
  - Total portfolio value
  - Each project's cash entries (Financial Ledger) — read-only
  - Project images gallery — read-only
- Owner cannot add, edit, or delete projects/entries from this view

---

### 📌 Phase 2 — Company Admin Panel

**Entry Point:** Admin logs in → lands on Admin Home (Users list).
**Navigation:** Bottom navigation bar with 2 tabs: **Users** | **Notifications**

#### 5.2.1 All Users Screen (Tab 1)

- Shows all users **belonging to the admin's company only**
- Searchable by name or email
- Each user card shows:
  - User avatar/photo
  - Full Name
  - Email
  - Delete icon (🗑️)
- Tapping delete → confirmation dialog → removes user from company
- **Tapping a user card** → Admin enters a read-only view of that user's data showing:
  - All projects belonging to that user
  - Total portfolio value
  - Each project's cash entries (Financial Ledger) — read-only
  - Project images gallery — read-only
- Admin cannot add, edit, or delete projects/entries from this view

#### 5.2.2 Notifications / Alerts & Updates Screen (Tab 2)

- Title: **"Alerts & Updates"**
- Subtitle: "Real-time oversight of engineering milestones and project revisions across the network"
- Lists all activity-based notifications for the company, sorted by newest first
- Each notification card shows:
  - **Notification Type Tag** (color-coded label):
    - `NEW ASSIGNMENT` — Yellow
    - `UPDATE LOG` — Purple/Lilac
    - `STRUCTURAL ALERT` — Pink/Red
    - `ARCHIVED` — Muted/Gray
  - **Engineer Name** (snapshot)
  - **Message** — full descriptive text, e.g.:
    - "تم إنشاء مشروع جديد: The Obsidian Plaza"
    - "تم تعديل بند Weekly Site Fuel في مشروع The Obsidian Plaza"
    - "تم حذف بند Structural Steel من مشروع Azure Harbor"
    - "تم حذف مشروع Vanguard Heights II"
  - **Date & Time**
  - Delete icon (🗑️)
- **Tapping a notification card:**
  - If project still exists → navigates to that **user's project** in read-only mode (Admin sees the full project: financial ledger + images)
  - If project was deleted → shows inline message: "هذا المشروع تم حذفه" — no navigation
- Notification triggers (auto-generated when user performs actions):
  - User **creates** a project → `NEW ASSIGNMENT`
  - User **edits** a cash entry → `UPDATE LOG` + entry name snapshot
  - User **deletes** a cash entry → `STRUCTURAL ALERT` + entry name snapshot
  - User **deletes** a project → `ARCHIVED`
- **Badge counter** on tab icon shows unread notification count
- **Refresh button** in header — manually fetches latest notifications
- Admin can **delete** a notification card after reviewing it
- Notifications are **company-scoped** (admin only sees their company's notifications)

---

### 📌 Phase 3 — Authentication Flow

**Applies to:** All user roles (Owner, Admin, User)

#### 5.3.1 Splash Screen

- App logo (compass/architect icon)
- App name: **"Cashes"**
- Arabic/mirrored tagline (supports RTL)
- Loading progress bar
- "Powered by" branding footer
- **Logic after loading:**
  - Check if user is logged in → redirect to correct panel based on role:
    - `owner` → CEO Panel
    - `admin` → Admin Panel
    - `user` → Projects Home
  - If not logged in → Login Screen

#### 5.3.2 Login Screen

- App logo
- Title: "Welcome Back"
- Fields:
  - **Email Address** (required)
  - **Password** (required, masked)
- Link: `Forgot Password?` → navigates to Forgot Password screen
- Button: `Login →`
- Error handling: show inline error messages for wrong credentials
- **No self-registration** — accounts are created by Owner only

#### 5.3.3 Forgot Password Screen

- App logo
- Title: "Forgot Password"
- Subtitle instruction text
- Fields:
  - **Email Address** (required)
- Button: `Send Reset Link →`
- Link: `← Back to Login`
- On submit: sends password reset email to the provided address

#### 5.3.4 Email Sent Confirmation Screen *(optional/recommended)*

- Confirmation that reset email was dispatched
- Instruction to check inbox
- Link: `← Back to Login`

---

### 📌 Phase 4 — Settings

**Applies to:** All roles (Owner, Admin, User) — same UI, different access context.

#### 5.4.1 Settings Main Screen

- **Profile Card** at top:
  - User avatar with edit (pencil) icon
  - Full Name
  - Email Address
- **ACCOUNT** section:
  - `Personal Information →` — navigates to Edit Profile screen
- **SYSTEM PREFERENCES** section:
  - `Language` — dropdown toggle (English / Arabic), affects RTL layout
  - `Appearance` — toggle between `Dark` / `Light` mode
- **Footer:**
  - `Logout Account` button — logs out and redirects to Login
  - App version label (e.g., `APP VERSION 2.4.0 (GOLD CURATOR)`)

#### 5.4.2 Edit Profile / Personal Information Screen

- Avatar with camera icon (tap to update photo from gallery/camera)
- Editable fields:
  - **Full Name**
  - **Email Address**
  - **Current Password** (required to change password)
  - **New Password**
  - **Confirm New Password**
- Button: `Save Changes`
- Email changes must be validated for uniqueness
- Password change requires current password verification

---

### 📌 Phase 5 — Projects Management (CRUD)

**Applies to:** Users (Site Engineers) only
**Screen Count:** 1 main screen + 2 bottom sheets

#### 5.5.1 Projects Overview / Home Screen

- Header: `Welcome [User Name]`
- Icons: Logout (top-left), Settings ⚙️ (top-right)
- Section label: `CURATED OVERVIEW — Active Developments`
- **Search bar:** Search by project name, location, or status
- **Projects List:** Each project card shows:
  - Project Name
  - Creation Date (calendar icon)
  - Total Amount (sum of all cash entries) in currency
  - Three-dot menu `⋮` → opens Project Settings bottom sheet
- **Footer Summary:**
  - `TOTAL PORTFOLIO VALUE` — sum of all project totals
- **FAB Button `+`** (bottom-right) → opens Create Project bottom sheet
- Projects are **scoped to the logged-in user** (users cannot see each other's projects)

#### 5.5.2 Create Project Bottom Sheet

- Tag: `NEW VENTURE`
- Title: `Initiate Project.`
- Subtitle: "Begin your journey by naming your architectural vision."
- Field: **Project Name** (required, text input)
- Button: `Create Project →`
- Link: `Cancel`
- On creation: new project appears at top of list with zero total value

#### 5.5.3 Project Settings Bottom Sheet

- Tag: `NEW VENTURE`
- Title: `Project Settings`
- Subtitle: "Manage your project details and configuration."
- Field: **Project Name** (editable, pre-filled)
- Button: `Save Changes 💾`
- Button: `Delete Project 🗑️` (with confirmation dialog)
- Link: `Cancel`

---

### 📌 Phase 6 — Invoices & Cash Entries

**Applies to:** Users (Site Engineers)
**Entry:** Tap on a project card → Project Details screen

#### 5.6.1 Project Details Screen

- **Header:** Project Name, Refresh icon, Print icon
- Two bottom navigation tabs:
  - 📋 **INVOICES** — Financial Ledger view
  - 🖼️ **IMAGES** — Visual Catalog view
- **FAB Button `+`** → opens Add Cash Entry screen (when on Invoices tab) or image picker (when on Images tab)

#### 5.6.2 Invoices Tab — Financial Ledger

- **Summary Card:**
  - Label: `TOTAL INVOICED`
  - Total amount (sum of all entries for this project)
  - Wallet/copy icon
  - Last updated timestamp (e.g., "UPDATED 2 MINUTES AGO")
- **Financial Ledger Table:**
  - Columns: `DATE` | `VENDOR / ENTITY` | `AMOUNT`
  - Rows sorted by date (newest first)
  - Tap a row → opens Edit Cash Entry screen
- **Print / Export:**
  - Print icon in header → generates formatted PDF
  - PDF includes: project name, all entries (date, vendor, amount), attached receipt images, total

#### 5.6.3 Add Cash Entry Screen

- Tag: `LIVE PROJECT` badge
- Title: `Add Cash Entry`
- Fields:
  - **Transaction Amount** (large number display, tap to input)
  - **Entry Name / Vendor Entity** (text input, e.g., "Weekly Site Fuel")
  - **Date** (date picker, defaults to today)
  - **Documentation / Receipt:**
    - Attach **one receipt image** per entry (gallery or camera)
    - Preview of attached image shown inline
    - Option to remove selected image before saving
- Button: `Save Entry ✓`

#### 5.6.4 Edit Cash Entry Screen

- Pre-filled with existing entry data
- Editable fields:
  - **Amount** (large display)
  - **Entry Name**
  - **Date**
  - **Documentation:**
    - Shows existing receipt image with delete option (🗑️)
    - If deleted: option to `Attach New Receipt` becomes available
    - Only **one receipt image** allowed per entry
- Button: `Save Changes`
- Link: `Delete Entry` (with confirmation → removes entry and its receipt image)

#### 5.6.5 Images Tab — Receipt Gallery View

- Displays all **receipt images** from `cash_entries` for this project
- Query: `receipt_url IS NOT NULL` AND `receipt_expired = FALSE`
- Grid layout — each card shows: receipt thumbnail, entry name, date, amount
- Tapping a card → navigates to **Edit Cash Entry** for that entry
- **No separate upload** — images come exclusively from Add/Edit Cash Entry
- Receipt image is **optional** per entry (entry can exist without image)
- When adding/editing a receipt: bottom sheet offers **Camera** or **Gallery**
- Expired receipts filtered out — not shown in this tab
- Empty state if no entries have receipts

---

## 5.7 Data Cascade & Deletion Rules

The system enforces **hard cascade deletes** to maintain data integrity across all levels of the hierarchy. The following rules apply:

```
Company Deleted
    └── All Users in that company → DELETED
            └── All Projects per user → DELETED
                    └── All Cash Entries per project → DELETED
                            └── Receipt Images per entry → DELETED (from storage)

User Deleted
    └── All Projects belonging to that user → DELETED
            └── All Cash Entries per project → DELETED
                    └── Receipt Images per entry → DELETED (from storage)

Project Deleted
    └── All Cash Entries → DELETED
            └── Receipt Images → DELETED (from storage)

Cash Entry Deleted
    └── Receipt Image → DELETED (from storage)
```

**Rules:**
- All cascade deletes must be **confirmed** by the acting user via a confirmation dialog before execution
- Deletion is **permanent** — no soft delete or recycle bin in v1.0
- Image files must be deleted from **Supabase Storage** in the same transaction as the DB record deletion to avoid orphaned files

---

## 6. Non-Functional Requirements

| Category | Requirement |
|---|---|
| **Performance** | App must load within 3 seconds on standard 4G connection |
| **Responsiveness** | UI must adapt correctly to all screen sizes (small phones to large phones). Layouts, cards, and text must scale using relative sizing — no hardcoded pixel dimensions |
| **Offline Support** | Projects and entries should be viewable offline (cached); sync on reconnect |
| **Security** | Role-based access control enforced server-side; no client-side role bypass |
| **Scalability** | Multi-tenant design must support 100+ companies and 10,000+ users |
| **Data Isolation** | Each company's data strictly isolated; no cross-tenant data leakage |
| **Image Compression** | All images (receipts + gallery) must be compressed **aggressively** on the client side before upload. Target: reduce file size by 60–80% while maintaining readable quality. Max upload size after compression: 500KB per image |
| **Image Auto-Deletion** | Receipt images and project gallery images are **automatically deleted from storage 30 days after their upload date**. The cash entry record (amount, vendor, date) is **never deleted** — only the image file expires. A warning must be shown to users before and at expiry |
| **PDF Generation** | PDF export must include all ledger entries + receipt thumbnails (while images are still available) |
| **Localization** | Full RTL support for Arabic; all UI strings must be in localization files |
| **Theming** | Dark/Light theme persisted locally per user preference |
| **Notifications** | Implemented as a DB table with pull-to-refresh + badge counter. No real-time WebSocket — Admin manually refreshes to fetch latest activity logs |

---

## 6.1 Image Lifecycle Policy

```
Image Uploaded (Day 0)
    ├── Stored in Supabase Storage
    ├── upload_date recorded in DB
    └── expires_at = upload_date + 30 days

Day 25 → Warning shown to user:
    "⚠️ Receipt image will expire in 5 days. Export PDF to preserve it."

Day 30 → Supabase pg_cron job runs:
    └── Deletes image file from Storage
    └── Sets image_url = null in DB record
    └── Cash Entry record stays intact (amount, vendor, date preserved)
```

**Rules:**
- The **financial record is permanent** — only the image file expires
- Users are warned **5 days before** image expiry with an in-app banner on the relevant entry
- After expiry, the entry shows a placeholder icon instead of the receipt image
- PDF export should be done **before** images expire to capture the full record
- The 30-day clock starts from **upload date**, not project creation date

---

## 7. User Stories Summary

### Owner (CEO)
- As an Owner, I want to add new companies so they can use the platform
- As an Owner, I want to create user accounts and assign them to companies
- As an Owner, I want to edit or delete companies and users at any time
- As an Owner, I want to see a statistics overview of all companies and users
- As an Owner, I want to enter any company and see its Admin panel (users list + notifications) in read-only mode
- As an Owner, I want to enter any user profile and see all their projects and cash entries in read-only mode
- As an Owner, I want to know that deleting a company will permanently delete all its users, projects, entries, and images
- As an Owner, I want a confirmation dialog before any destructive delete action

### Admin
- As an Admin, I want to view all engineers in my company
- As an Admin, I want to delete a user account from my company
- As an Admin, I want to tap on any user and see all their projects and cash entries in read-only mode
- As an Admin, I want to see notifications with a descriptive message (e.g. "تم تعديل بند Weekly Site Fuel في مشروع The Obsidian Plaza")
- As an Admin, I want to tap a notification and be taken directly to that user's project to see what changed
- As an Admin, I want to see a clear message if the project in a notification has already been deleted
- As an Admin, I want to refresh my notifications list manually to see the latest updates
- As an Admin, I want to see a badge counter showing unread notifications
- As an Admin, I want to clear/delete a notification after reviewing it
- As an Admin, I want to know that deleting a user will permanently delete all their projects, entries, and images

### User (Engineer)
- As a User, I want to log in with my credentials provided by the Owner
- As a User, I want to reset my password if I forget it
- As a User, I want to create and manage my own projects independently
- As a User, I want to log cash entries with vendor name, amount, date, and one receipt image
- As a User, I want the app to automatically compress my images before uploading to save storage
- As a User, I want to replace or delete the receipt image on an existing entry
- As a User, I want to be warned 5 days before a receipt image expires so I can export the PDF in time
- As a User, I want to view a running total of costs per project
- As a User, I want to see my total portfolio value across all projects
- As a User, I want to export a formatted PDF of my project's financial ledger (with receipt images, before they expire)
- As a User, I want to manage a visual image gallery per project
- As a User, I want to know that deleting a project will permanently delete all its entries and images
- As a User, I want the app to look and work correctly on any phone screen size

---

## 8. Screens Inventory

| Phase | Screen | Role |
|---|---|---|
| 1 | Companies List | Owner |
| 1 | Add Company Profile | Owner |
| 1 | Edit Company | Owner |
| 1 | Create User Account | Owner |
| 1 | Edit User | Owner |
| 1 | Users List (per company) | Owner |
| 2 | Admin — All Users | Admin |
| 2 | Admin — Notifications | Admin |
| 3 | Splash Screen | All |
| 3 | Login | All |
| 3 | Forgot Password | All |
| 3 | Email Sent Confirmation | All |
| 4 | Settings Main | All |
| 4 | Edit Profile / Personal Info | All |
| 5 | Projects Overview / Home | User |
| 5 | Create Project (Bottom Sheet) | User |
| 5 | Project Settings (Bottom Sheet) | User |
| 6 | Project Details — Invoices Tab | User |
| 6 | Project Details — Images Tab (receipt gallery) | User |
| 6 | Add Cash Entry | User |
| 6 | Edit Cash Entry | User |

**Total Screens: 20**

---

## 9. Design Tokens

### 9.1 Defaults
| Setting | Default Value |
|---|---|
| **Default Theme** | Dark Mode |
| **Default Language** | Arabic (AR) — RTL Layout |

### 9.2 Color Palette — Dark Theme (Default)

| Token | Value |
|---|---|
| **Primary Color** | Gold / Amber `#F5A623` |
| **Background** | Near Black `#0D0D0D` |
| **Card Background** | `#1A1A1A` |
| **Text Primary** | White `#FFFFFF` |
| **Text Secondary** | Gray `#888888` |
| **Danger / Delete** | Red `#E53935` |
| **Border / Divider** | `#2A2A2A` |

### 9.3 Color Palette — Light Theme

| Token | Value |
|---|---|
| **Primary Color** | Gold / Amber `#F5A623` *(same as dark — unchanged)* |
| **Background** | Off-White `#F5F5F5` |
| **Card Background** | White `#FFFFFF` |
| **Text Primary** | Near Black `#1A1A1A` |
| **Text Secondary** | Medium Gray `#666666` |
| **Danger / Delete** | Red `#E53935` *(same)* |
| **Border / Divider** | Light Gray `#E0E0E0` |

### 9.4 Typography & Shape
| Token | Value |
|---|---|
| **Font Style** | Modern Sans-Serif |
| **Border Radius** | 12–16px (rounded cards) |
| **App Icon** | Architect compass on dark background |

---

## 10. Out of Scope (v1.0)

- In-app messaging between users
- Multi-currency support (single currency per company)
- Project status workflows (e.g., in-progress, completed, on-hold)
- Analytics/reporting dashboard for Owner
- Integration with third-party accounting software
- Web dashboard / admin panel (mobile-only for v1)
- User invitation flow (Owner creates accounts directly)
