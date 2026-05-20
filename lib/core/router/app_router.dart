// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cashes/core/router/app_routes.dart';
import 'package:cashes/features/auth/presentation/screens/email_sent_screen.dart';
import 'package:cashes/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:cashes/features/auth/presentation/screens/login_screen.dart';
import 'package:cashes/features/auth/presentation/screens/splash_screen.dart';

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}

GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.emailSent,
        builder: (_, _) => const EmailSentScreen(),
      ),

      // Owner
      GoRoute(
        path: AppRoutes.ownerCompanies,
        builder: (_, s) => const _PlaceholderScreen('Companies'),
      ),
      GoRoute(
        path: AppRoutes.addCompany,
        builder: (_, s) => const _PlaceholderScreen('Add Company'),
      ),
      GoRoute(
        path: AppRoutes.editCompany,
        builder: (_, s) => _PlaceholderScreen('Edit Company ${s.pathParameters['companyId']}'),
      ),
      GoRoute(
        path: AppRoutes.ownerUsers,
        builder: (_, s) => _PlaceholderScreen('Users ${s.pathParameters['companyId']}'),
      ),
      GoRoute(
        path: AppRoutes.createUser,
        builder: (_, s) => const _PlaceholderScreen('Create User'),
      ),
      GoRoute(
        path: AppRoutes.editUser,
        builder: (_, s) => const _PlaceholderScreen('Edit User'),
      ),
      GoRoute(
        path: AppRoutes.ownerUserProjects,
        builder: (_, s) => const _PlaceholderScreen('User Projects (Owner)'),
      ),

      // Admin
      GoRoute(
        path: AppRoutes.adminUsers,
        builder: (_, s) => const _PlaceholderScreen('Admin Users'),
      ),
      GoRoute(
        path: AppRoutes.adminNotifications,
        builder: (_, s) => const _PlaceholderScreen('Admin Notifications'),
      ),
      GoRoute(
        path: AppRoutes.adminUserProjects,
        builder: (_, s) => const _PlaceholderScreen('User Projects (Admin)'),
      ),

      // User
      GoRoute(
        path: AppRoutes.projects,
        builder: (_, s) => const _PlaceholderScreen('Projects'),
      ),
      GoRoute(
        path: AppRoutes.projectDetails,
        builder: (_, s) => const _PlaceholderScreen('Project Details'),
      ),
      GoRoute(
        path: AppRoutes.addCashEntry,
        builder: (_, s) => const _PlaceholderScreen('Add Cash Entry'),
      ),
      GoRoute(
        path: AppRoutes.editCashEntry,
        builder: (_, s) => const _PlaceholderScreen('Edit Cash Entry'),
      ),
      GoRoute(
        path: AppRoutes.readonlyProjectDetails,
        builder: (_, s) => const _PlaceholderScreen('Read-Only Project'),
      ),

      // Settings
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, s) => const _PlaceholderScreen('Settings'),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (_, s) => const _PlaceholderScreen('Edit Profile'),
      ),
    ],
  );
}
