// lib/features/auth/presentation/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cashes/core/constants/app_spacing.dart';
import 'package:cashes/core/di/injection.dart';
import 'package:cashes/core/localization/app_localizations.dart';
import 'package:cashes/core/router/app_routes.dart';
import 'package:cashes/core/utils/validators.dart';
import 'package:cashes/core/widgets/app_snackbar.dart';
import 'package:cashes/core/widgets/primary_button.dart';
import 'package:cashes/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:cashes/features/auth/presentation/cubit/forgot_password_state.dart';
import 'package:cashes/features/auth/presentation/widgets/auth_logo_header.dart';
import 'package:cashes/features/auth/presentation/widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ForgotPasswordCubit>(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<ForgotPasswordCubit>().sendReset(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordSuccess) {
          AppSnackbar.success(context, l10n.snackbarPasswordResetSent);
          context.go(AppRoutes.emailSent);
        } else if (state is ForgotPasswordError) {
          AppSnackbar.error(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  AuthLogoHeader(
                    title: l10n.authResetTitle,
                    subtitle: l10n.authResetSubtitle,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AuthTextField(
                    controller: _emailController,
                    label: l10n.authEmail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    validator: Validators.email,
                    onSubmitted: (_) => _submit(context),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                    builder: (context, state) {
                      final isLoading = state is ForgotPasswordLoading;
                      return PrimaryButton(
                        label: l10n.authResetCta,
                        isLoading: isLoading,
                        onPressed: () => _submit(context),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
