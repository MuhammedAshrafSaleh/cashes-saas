// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cashes/core/constants/app_spacing.dart';
import 'package:cashes/core/di/injection.dart';
import 'package:cashes/core/localization/app_localizations.dart';
import 'package:cashes/core/router/app_routes.dart';
import 'package:cashes/core/router/role_redirect.dart';
import 'package:cashes/core/utils/validators.dart' show Validators;
import 'package:cashes/core/widgets/app_snackbar.dart';
import 'package:cashes/core/widgets/primary_button.dart';
import 'package:cashes/features/auth/presentation/cubit/login_cubit.dart';
import 'package:cashes/features/auth/presentation/cubit/login_state.dart';
import 'package:cashes/features/auth/presentation/widgets/auth_logo_header.dart';
import 'package:cashes/features/auth/presentation/widgets/auth_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoginCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<LoginCubit>().login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          AppSnackbar.success(context, l10n.snackbarLoginSuccess);
          context.go(homeRouteForRole(state.user.role));
        } else if (state is LoginError) {
          AppSnackbar.error(context, state.message);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  AuthLogoHeader(
                    title: l10n.authWelcomeBack,
                    subtitle: l10n.authSubtitle,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AuthTextField(
                    controller: _emailController,
                    label: l10n.authEmail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AuthTextField(
                    controller: _passwordController,
                    label: l10n.authPassword,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    validator: Validators.password,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    onSubmitted: (_) => _submit(context),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => context.push(AppRoutes.forgotPassword),
                      child: Text(l10n.authForgotPassword),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BlocBuilder<LoginCubit, LoginState>(
                    builder: (context, state) {
                      final isLoading = state is LoginLoading;
                      return PrimaryButton(
                        label: l10n.authLogin,
                        isLoading: isLoading,
                        onPressed: () => _submit(context),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
