// lib/features/auth/presentation/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cashes/core/constants/app_assets.dart';
import 'package:cashes/core/constants/app_spacing.dart';
import 'package:cashes/core/di/injection.dart';
import 'package:cashes/core/router/app_routes.dart';
import 'package:cashes/core/router/role_redirect.dart';
import 'package:cashes/features/auth/presentation/cubit/splash_cubit.dart';
import 'package:cashes/features/auth/presentation/cubit/splash_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SplashCubit>()..initialize(),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashAuthenticated) {
          final role = state.user.role;
          context.go(homeRouteForRole(role));
        } else if (state is SplashUnauthenticated) {
          context.go(AppRoutes.login);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppAssets.logo,
                  width: 120,
                  height: 120,
                  errorBuilder: (_, _, _) => const Icon(Icons.account_balance_wallet, size: 120),
                ),
                const SizedBox(height: AppSpacing.lg),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
