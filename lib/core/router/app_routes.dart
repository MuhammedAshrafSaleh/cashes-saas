// lib/core/router/app_routes.dart
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String emailSent = '/email-sent';

  // Owner
  static const String ownerCompanies = '/owner/companies';
  static const String addCompany = '/owner/companies/add';
  static const String editCompany = '/owner/companies/:companyId/edit';
  static const String ownerUsers = '/owner/companies/:companyId/users';
  static const String createUser = '/owner/companies/:companyId/users/create';
  static const String editUser = '/owner/companies/:companyId/users/:userId/edit';
  static const String ownerUserProjects = '/owner/companies/:companyId/users/:userId/projects';

  // Admin
  static const String adminShell = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminNotifications = '/admin/notifications';
  static const String adminUserProjects = '/admin/users/:userId/projects';

  // Projects (user role)
  static const String projects = '/projects';

  // Project details (shared)
  static const String projectDetails = '/projects/:projectId';
  static const String addCashEntry = '/projects/:projectId/entries/add';
  static const String editCashEntry = '/projects/:projectId/entries/:entryId/edit';
  static const String readonlyProjectDetails = '/readonly/projects/:projectId';

  // Settings (shared)
  static const String settings = '/settings';
  static const String editProfile = '/settings/edit-profile';

  static String ownerUsersPath(String companyId) =>
      '/owner/companies/$companyId/users';

  static String editCompanyPath(String companyId) =>
      '/owner/companies/$companyId/edit';

  static String createUserPath(String companyId) =>
      '/owner/companies/$companyId/users/create';

  static String editUserPath(String companyId, String userId) =>
      '/owner/companies/$companyId/users/$userId/edit';

  static String ownerUserProjectsPath(String companyId, String userId) =>
      '/owner/companies/$companyId/users/$userId/projects';

  static String adminUserProjectsPath(String userId) =>
      '/admin/users/$userId/projects';

  static String projectDetailsPath(String projectId) =>
      '/projects/$projectId';

  static String addCashEntryPath(String projectId) =>
      '/projects/$projectId/entries/add';

  static String editCashEntryPath(String projectId, String entryId) =>
      '/projects/$projectId/entries/$entryId/edit';

  static String readonlyProjectDetailsPath(String projectId) =>
      '/readonly/projects/$projectId';
}
