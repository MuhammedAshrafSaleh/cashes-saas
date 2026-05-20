// lib/core/router/role_redirect.dart
import 'package:cashes/core/router/app_routes.dart';

enum UserRole { owner, admin, user }

String homeRouteForRole(UserRole role) {
  switch (role) {
    case UserRole.owner:
      return AppRoutes.ownerCompanies;
    case UserRole.admin:
      return AppRoutes.adminUsers;
    case UserRole.user:
      return AppRoutes.projects;
  }
}

UserRole? roleFromString(String? value) {
  switch (value) {
    case 'owner':
      return UserRole.owner;
    case 'admin':
      return UserRole.admin;
    case 'user':
      return UserRole.user;
    default:
      return null;
  }
}
