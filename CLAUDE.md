# CLAUDE.md — Cashes App

## Project Overview

Cashes is a multi-tenant SaaS mobile app for construction/finishing companies. It manages cash disbursements, vendor invoicing, and receipt documentation for site engineers — with company-level admin oversight.

**Stack:** Flutter · Clean Architecture · Cubit · Supabase (PostgreSQL + Auth + Storage)

---

## Documentation (Read ALL before writing any code)

```
docs/
├── business_requirements.md   → Business context, roles, phases, permissions
├── supabase_schema.md         → Full DB schema, SQL, RLS, triggers, functions
├── supabase_status.md         → What's done vs what you need to create
├── PRD.md                     → Feature specs F-01→F-22, acceptance criteria, snackbars, dialogs
├── corner_case_analysis.md    → 68 edge cases with resolutions, 5 critical ones
└── screens/                   → UI screenshots organized by phase
```

**IMPORTANT:** Read `docs/supabase_status.md` FIRST — it tells you what's already set up in Supabase and what SQL you need to run.

---

## Common Commands

```bash
# Run app (debug)
flutter run

# Run with env variables
flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=xxx

# Build release APK
flutter build apk --release

# Analyze code
flutter analyze

# Format code
dart format lib/

# Run all tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Code generation (json_serializable for models)
dart run build_runner build --delete-conflicting-outputs

# Regenerate localization files
flutter gen-l10n
```

---

## Architecture — Clean Architecture with Cubit

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── errors/              → Failure classes, exceptions
│   ├── network/             → Supabase client wrapper, connectivity checker
│   ├── router/              → GoRouter config, role-based route guards
│   ├── theme/               → Dark theme (default), Light theme, colors, text styles
│   ├── localization/        → ARB files (ar.arb default, en.arb)
│   ├── utils/               → Image compression, PDF generator, date formatters
│   └── widgets/             → Shared widgets (snackbar, dialog, empty state, loading)
│
├── features/
│   ├── auth/                → F-09 Splash, F-10 Login, F-11 Forgot Password, F-12 Email Sent
│   ├── owner/               → F-01→F-06 (Companies, Users CRUD, drill-down)
│   ├── admin/               → F-07 Users List, F-08 Notifications
│   ├── settings/            → F-13 Settings, F-14 Edit Profile
│   ├── projects/            → F-15 Overview, F-16 Create, F-17 Settings
│   └── invoices/            → F-18 Details, F-19 Ledger, F-20 Add, F-21 Edit, F-22 Images Tab
│
│   Each feature folder MUST follow this structure:
│   ├── data/
│   │   ├── datasources/     → Supabase API calls (remote data source)
│   │   ├── models/          → JSON serialization models (fromJson/toJson)
│   │   └── repositories/    → Repository implementation
│   ├── domain/
│   │   ├── entities/        → Pure Dart classes (no dependencies)
│   │   ├── repositories/    → Abstract repository interfaces
│   │   └── usecases/        → Single-responsibility use cases
│   └── presentation/
│       ├── cubit/           → Cubit + State classes
│       ├── screens/         → Full screen widgets
│       └── widgets/         → Feature-specific reusable widgets
```

---

## Rules — Architecture

- Every feature MUST have data/domain/presentation layers — no shortcuts
- Domain layer MUST NOT import from data or presentation layers
- Use cases MUST have a single `call()` method
- Repository interfaces in domain/, implementations in data/
- Models extend entities: `UserModel extends UserEntity`
- Cubit MUST emit states: Initial, Loading, Success, Error — for every async operation
- NEVER put business logic in widgets — always in Cubit or UseCase
- Return `Either<Failure, T>` from every repository method
- Always use `const` constructors wherever possible
- Use `equatable` for all entities and state classes
- Keep all entity fields `final`
- Use named parameters for any constructor with more than two parameters
- Extract magic numbers and repeated string keys into named constants

---

## Dependency Injection (get_it — manual registration)

```dart
// core/di/injection.dart
final sl = GetIt.instance;

void initDI() {
  // Network
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Repositories
  sl.registerLazySingleton<ProjectRepository>(() => ProjectRepositoryImpl(sl()));

  // Use Cases
  sl.registerFactory(() => GetProjectsUseCase(sl()));
  sl.registerFactory(() => CreateProjectUseCase(sl()));

  // Cubits
  sl.registerFactory(() => ProjectsCubit(sl(), sl()));
}
```

- Manual registration only — no code generation for DI
- Register every dependency in `core/di/injection.dart`
- Use `sl<T>()` to resolve dependencies — never instantiate services or Cubits manually
- Repositories: `registerLazySingleton`
- Use Cases: `registerFactory`
- Cubits: `registerFactory`

---

## Key Patterns

### UseCase Template

```dart
class CreateProjectUseCase {
  final ProjectRepository _repository;
  CreateProjectUseCase(this._repository);

  Future<Either<Failure, ProjectEntity>> call(CreateProjectParams params) async {
    try {
      return await _repository.createProject(params);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }
}
```

### Cubit Calls UseCase — Never Repository or Supabase Directly

```dart
Future<void> createProject(String name) async {
  emit(ProjectsLoading());
  final result = await _createProjectUseCase(CreateProjectParams(name: name));
  result.fold(
    (failure) => emit(ProjectsError(failure.message)),
    (project) => emit(ProjectsSuccess(project)),
  );
}
```

### Network Check — Required in Every Repository Method

```dart
class ProjectRepositoryImpl implements ProjectRepository {
  final SupabaseClient _client;
  final NetworkInfo _networkInfo;

  Future<Either<Failure, T>?> _checkNetwork<T>() async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    return null;
  }

  @override
  Future<Either<Failure, List<ProjectEntity>>> getProjects() async {
    final offline = await _checkNetwork<List<ProjectEntity>>();
    if (offline != null) return offline;
    // ... Supabase call
  }
}
```

### Failure Subclasses

```dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure { ... }
class NetworkFailure extends Failure { ... }
class AuthFailure extends Failure { ... }
class PermissionFailure extends Failure { ... }
class ValidationFailure extends Failure { ... }
```

- Failure types must be specific — never catch a generic `Exception`
- User-facing errors must be mapped to localized Arabic strings
- Log all errors with `Logger('<FeatureName>')` — e.g. `Logger('ProjectsRepo')`

---

## Rules — Supabase

- Supabase client initialized ONCE in `core/network/supabase_client.dart`
- Access via dependency injection — NEVER call `Supabase.instance.client` directly in features
- RLS is the source of truth for permissions — NEVER trust client-side role checks alone
- Use `auth.uid()` for all user-scoped queries — never pass user_id from client
- All dates/times use server time (DB triggers) — never trust device clock
- Receipt images: upload to `receipt-images/{company_id}/{user_id}/{entry_id}.jpg`
- Always compress images BEFORE upload — max 500KB, run in Dart isolate via `compute()`
- After every CRUD on projects/entries → call `create_notification()` RPC
- `client_request_id` (UUID) must be sent with every cash_entry INSERT for idempotency
- **Auth State Listener** — register ONCE in `app.dart` on startup:

```dart
Supabase.instance.client.auth.onAuthStateChange.listen((data) {
  final event = data.event;
  if (event == AuthChangeEvent.signedOut) {
    // navigate to login
  }
  if (event == AuthChangeEvent.tokenRefreshed) {
    // token refreshed silently — no action needed
  }
});
```

- On any 401 response → attempt one manual token refresh → if fails → force logout + Snackbar "انتهت جلستك"
- On any 403/RLS error → check if `public.users` record exists for `auth.uid()` → if not → force logout + "تم حذف حسابك"

---

## Rules — State Management (Cubit)

```dart
// EVERY Cubit state must follow this pattern:
abstract class FeatureState {}
class FeatureInitial extends FeatureState {}
class FeatureLoading extends FeatureState {}
class FeatureSuccess extends FeatureState { final data; }
class FeatureError extends FeatureState { final String message; }
```

- One Cubit per feature screen (not per widget)
- Cubit NEVER imports Flutter — only domain layer
- Use `mounted` check in async callbacks to prevent state emission after dispose
- On auth errors (401/403) → check if user exists → force logout if deleted
- Use Bloc (not Cubit) for complex event processing: advanced filtering, real-time search with debouncing, or features with multiple interdependent events
---

## Rules — UI/UX (Mandatory on EVERY screen)

### Snackbar
- Every state change MUST trigger a Snackbar — see PRD Section 2.1 for full list
- Duration: 3 seconds
- Types: Success 🟢, Error 🔴, Warning 🟡, Info ⚪
- Max 1 snackbar at a time

### Confirmation Dialog
- Every destructive action MUST show dialog BEFORE execution — see PRD Section 2.2
- Delete buttons always RED
- Dialog dismissible by tapping outside (= Cancel)

### Loading
- Buttons show CircularProgressIndicator inside during loading (disabled state)
- Lists show skeleton shimmer while loading
- Full-screen loader ONLY for initial screen data fetch

### Empty States
- Every list screen MUST have an empty state widget with Arabic message
- See PRD Section 2.4 for exact messages

### Double-Tap Protection
- EVERY submit/save/delete button must be disabled immediately on first tap
- Re-enable only after response received

---

## Rules — Localization

- Default language: Arabic (RTL)
- Default theme: Dark
- ALL UI strings in ARB files — zero hardcoded strings in widgets
- File names: `app_ar.arb` (default), `app_en.arb`
- Use `start/end` padding — NEVER `left/right`
- Use `TextDirection` for mixed Arabic/English text
- Date format: `dd/MM/yyyy` for Arabic locale

---

## Rules — Theming

- Dark theme is DEFAULT
- Primary color: `#F5A623` (Gold/Amber) — same in both themes
- Dark background: `#0D0D0D`, cards: `#1A1A1A`, text: `#FFFFFF`
- Light background: `#F5F5F5`, cards: `#FFFFFF`, text: `#1A1A1A`
- Persist theme preference in `shared_preferences`
- Border radius: 12-16px on all cards

---

## Rules — Navigation

- Use `go_router` for all navigation
- Role-based route guards on splash:
  - `owner` → `/owner/companies`
  - `admin` → `/admin/users`
  - `user` → `/projects`
- Deep link from notification → project details (read-only)
- Read-only mode: hide FAB, hide edit/delete, show "وضع المشاهدة فقط" banner

---

## Rules — Responsiveness

### Layout
- No hardcoded pixel dimensions — use `MediaQuery.sizeOf(context)`, `LayoutBuilder`, or fractional sizing
- Use `Flexible` and `Expanded` inside `Row`/`Column` instead of fixed pixel widths
- Minimum tappable area: 48×48 dp — wrap small icons in `SizedBox` or use `IconButton`
- Use `SafeArea` on every top-level page widget

### Text & Fonts
- Never hardcode `fontSize` — use `Theme.of(context).textTheme` styles only
- All body and label text must respect system font scale
- Use `maxLines` + `TextOverflow.ellipsis` on all text widgets

### Keyboard & Scroll
- Wrap every form page in `SingleChildScrollView` + `resizeToAvoidBottomInset: true`
- Add `SizedBox(height: MediaQuery.viewInsetsOf(context).bottom)` at the bottom of scrollable forms

### Spacing
- Define all spacing in `core/constants/app_spacing.dart` (e.g. `AppSpacing.sm = 8`, `AppSpacing.md = 16`)
- Never write raw `EdgeInsets.all(16)` inline — always use `AppSpacing` constants

### RTL / LTR
- Never use `Alignment.centerLeft/Right` or `EdgeInsets.only(left/right)`
- Use `AlignmentDirectional` and `EdgeInsetsDirectional` instead
- All directional icons (arrows, chevrons) must flip for RTL — use `Directionality.of(context)`
- Test every new screen in both `ar` and `en` locales before marking done

---

## Rules — Image Handling

- Source: Camera OR Gallery — always show bottom sheet picker with both options
- Compress in Dart isolate: `compute(_compressImage, bytes)`
- Target: quality 70, max dimension 1080px, output JPEG always
- Max size after compression: 500KB
- Convert HEIC (iOS) to JPEG before upload
- Fix EXIF rotation before compression
- Receipt image is OPTIONAL per cash entry (nullable)
- One image per entry only
- Images expire after 30 days (handled by pg_cron — not client)
- Show warning banner 5 days before expiry

---

## Rules — Error Handling

- Every UseCase wraps its body in `try/catch` and returns `Left(Failure)` on error
- Wrap every Supabase call in try/catch in the repository layer
- On 401 → attempt token refresh → if fails → force logout
- On 403/RLS error → check if user still exists → if not → force logout + "تم حذف حسابك"
- On no internet → show offline banner + disable save/upload
- On timeout (10s) → emit error state + Snackbar
- NEVER show raw error messages to user — always use localized strings
- NEVER catch a generic `Exception` — catch specific types
- Log all errors with `Logger('<FeatureName>')` — e.g. `Logger('ProjectsRepo')`
- Don't use `print()` — use `Logger` everywhere

---

## Rules — PDF Export

- Use `pdf` + `printing` packages
- Run generation in Dart isolate for large datasets
- Include: project name, company logo, entries table, receipt thumbnails, grand total
- If receipts expired → generate PDF without images + show warning to user
- Open native share sheet after generation

---

## User Roles Reference

| Role | Panel | Can Create | Can Read | Can Delete |
|---|---|---|---|---|
| Owner | CEO Panel | Companies, Users | Everything (all companies) | Companies, Users |
| Admin | Admin Panel | Nothing | Own company users + notifications | Users in own company |
| User | Projects | Projects, Entries | Own projects/entries only | Own projects/entries |

---

## Naming Conventions

### Files

```
Feature files:     snake_case.dart
Classes:           PascalCase
Variables:         camelCase
Constants:         kCamelCase
ARB keys:          camelCase prefixed with feature (e.g. "projectsTitle", "authLoginButton")
Cubits:            feature_cubit.dart → FeatureCubit
States:            feature_state.dart → FeatureState
Models:            feature_model.dart → FeatureModel
Entities:          feature_entity.dart → FeatureEntity
Screens:           feature_screen.dart → FeatureScreen
Widgets:           feature_widget.dart → FeatureWidget
Data sources:      feature_remote_data_source.dart → FeatureRemoteDataSourceImpl
Repositories:      feature_repository_impl.dart → FeatureRepositoryImpl
Use cases:         create_feature.dart → CreateFeatureUseCase
UseCase params:    create_feature.dart → CreateFeatureParams
Test files:        feature_test.dart
```

### Variables & Methods

- `camelCase` for all local variables, parameters, and method names
- `_camelCase` (leading underscore) for private fields and methods
- Boolean variables/getters start with `is`, `has`, or `can`: `isLoading`, `hasError`, `canEdit`
- Named constructors: `FeatureEntity.fromModel(...)`

### Route Naming

- Route paths: `kebab-case` — `/project-details/:id`, `/add-cash-entry`

---

## Performance Rules

### Widget Rebuilds
- Use `BlocSelector` instead of `BlocBuilder` when only one field of state is needed
- Split large pages into smaller `StatelessWidget`s so Flutter skips unchanged subtrees
- Prefer `const` widgets at every level — a `const` subtree is never re-evaluated
- Use `RepaintBoundary` around widgets that animate or update frequently
- Don't wrap large widget trees in `BlocBuilder` — wrap only the widget that changes

### Lists & Scrolling
- Always use `ListView.builder` / `GridView.builder` with `itemCount`
- Use `const` item widgets wherever possible
- Implement cursor-based pagination for growing lists
- Never use `shrinkWrap: true` inside `SingleChildScrollView`
- Use `cached_network_image` for all network images — never load directly with Image.network

### Async & Compute
- Run image compression, PDF generation, JSON parsing, and sorting inside `compute()`
- Never use `await` inside `build()` — trigger async in Cubit and react to emitted states
- Debounce search input (300ms minimum) before firing Supabase query

### Memory
- Cancel `StreamSubscription`s in `Cubit.close()`
- Dispose `TextEditingController`, `ScrollController` in `State.dispose()`
- Don't hold a reference to `BuildContext` in a Cubit or long-lived object

---

## Packages (use these exact packages)

```yaml
dependencies:
  flutter_bloc: latest
  supabase_flutter: latest
  go_router: latest
  get_it: latest                  # DI container
  equatable: latest
  dartz: latest                   # Either type for error handling
  flutter_image_compress: latest
  image_picker: latest
  permission_handler: latest
  shared_preferences: latest
  pdf: latest
  printing: latest
  intl: latest
  uuid: latest
  cached_network_image: latest
  shimmer: latest
  connectivity_plus: latest       # Network check
  logger: latest                  # Logging
  json_annotation: latest         # Model serialization

dev_dependencies:
  flutter_lints: latest
  build_runner: latest
  json_serializable: latest       # Generates fromJson/toJson for models
```

> Do not add packages without asking first.

---

## DO

- ✅ Add a **file path comment** at the top of every code block: `// lib/features/projects/domain/usecases/create_project_use_case.dart`
- ✅ Use `const` constructors wherever possible
- ✅ Register every dependency in `core/di/injection.dart`
- ✅ Always go through a UseCase from a Cubit — never call repository or Supabase directly
- ✅ Return `Either<Failure, T>` from every repository method
- ✅ Always call `.fold()` on `Either` returns — never ignore them
- ✅ Use Arabic strings in `app_ar.arb` as the primary language
- ✅ Use `equatable` for all entities and state classes
- ✅ Use `ListView.builder` for all lists — never `Column` + `.map()` for variable-length data
- ✅ Always show loading indicator for async operations
- ✅ Always show SnackBar on success or failure of every operation
- ✅ Use `context.read<Cubit>()` to dispatch; `BlocBuilder`/`BlocSelector` only for rebuilding
- ✅ Check `mounted` before using `BuildContext` after any `await` in a widget
- ✅ Use `sl<T>()` to resolve dependencies — never instantiate manually
- ✅ Format currency with `intl` `NumberFormat` — never build currency strings manually
- ✅ Use named parameters for constructors with more than two parameters
- ✅ Boolean variables/getters start with `is`, `has`, or `can`: `isLoading`, `hasError`, `canEdit`
- ✅ Private fields use leading underscore: `_camelCase`
- ✅ Use `EdgeInsetsDirectional` and `AlignmentDirectional` — never left/right variants
- ✅ Wrap every form page in `SingleChildScrollView` with `resizeToAvoidBottomInset: true`
- ✅ Run `compute()` for heavy operations (image compression, PDF, JSON parsing)
- ✅ Write a unit test for every UseCase covering success path and every failure path

---

## DO NOT

- ❌ Use `print()` — use `Logger` instead
- ❌ Use `setState` anywhere — always Cubit
- ❌ Use `dynamic` — always specify types
- ❌ Catch a generic `Exception` — catch specific types (`ServerException`, `NetworkException`)
- ❌ Hardcode any string in widgets — use localization keys
- ❌ Hardcode colors — use `Theme.of(context)`
- ❌ Hardcode `fontSize` — use `textTheme` styles only
- ❌ Hardcode pixel widths or heights — use fractional sizing
- ❌ Use `left/right` padding — use `start/end`
- ❌ Use `Supabase.instance.client` directly in features
- ❌ Trust client device clock for expiry dates
- ❌ Store the secret key (`sb_secret_`) in code
- ❌ Put business logic in widgets or Cubits — keep it in UseCases
- ❌ Call repository or Supabase directly from Cubit — always go through UseCase
- ❌ Skip empty states on list screens
- ❌ Skip confirmation dialog on destructive actions
- ❌ Skip snackbar on state changes
- ❌ Compress images on main thread — use `compute()`
- ❌ Allow future dates in date picker
- ❌ Allow amount = 0 in cash entries
- ❌ Create `project_images` table — it does not exist (Images tab reads from `cash_entries.receipt_url`)
- ❌ Navigate or show dialogs inside a Cubit — emit state, react in UI layer
- ❌ Create `TextEditingController` or `ScrollController` inside `build()` — declare in state, dispose in `dispose()`
- ❌ Use `shrinkWrap: true` inside `SingleChildScrollView`
- ❌ Ignore `StreamSubscription` — cancel in `Cubit.close()`
- ❌ Hold a reference to `BuildContext` in a Cubit or long-lived object
- ❌ Use `as` casts blindly — prefer `is` checks or safe casting patterns
- ❌ Add packages without asking first
- ❌ Show raw error messages to user — always use localized strings
- ❌ Modify existing public APIs
- ❌ Expose Supabase config in public repos — use --dart-define or .env files
