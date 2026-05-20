// lib/features/auth/presentation/screens/email_sent_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cashes/core/constants/app_spacing.dart';
import 'package:cashes/core/localization/app_localizations.dart';
import 'package:cashes/core/router/app_routes.dart';
import 'package:cashes/core/theme/app_colors.dart';
import 'package:cashes/core/widgets/primary_button.dart';

class EmailSentScreen extends StatelessWidget {
  const EmailSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.authEmailSentTitle,
                style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.authEmailSentSubtitle,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: l10n.authBackToLogin,
                onPressed: () => context.go(AppRoutes.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
