// lib/features/auth/presentation/widgets/auth_logo_header.dart
import 'package:flutter/material.dart';
import 'package:cashes/core/constants/app_assets.dart';
import 'package:cashes/core/constants/app_spacing.dart';

class AuthLogoHeader extends StatelessWidget {
  const AuthLogoHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Image.asset(
          AppAssets.logo,
          width: 80,
          height: 80,
          errorBuilder: (_, _, _) => const Icon(Icons.account_balance_wallet, size: 80),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
