// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:cashes/core/auth/session_guard.dart';
import 'package:cashes/core/constants/app_assets.dart';
import 'package:cashes/core/di/injection.dart';
import 'package:cashes/core/localization/app_localizations.dart';
import 'package:cashes/core/localization/locale_cubit.dart';
import 'package:cashes/core/localization/locale_state.dart';
import 'package:cashes/core/network/network_info.dart';
import 'package:cashes/core/router/app_router.dart';
import 'package:cashes/core/router/app_routes.dart';
import 'package:cashes/core/theme/app_theme.dart';
import 'package:cashes/core/theme/theme_cubit.dart';
import 'package:cashes/core/theme/theme_state.dart';
import 'package:cashes/core/widgets/app_snackbar.dart';
import 'package:cashes/core/widgets/offline_banner.dart';
import 'package:cashes/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cashes/features/auth/presentation/cubit/auth_state.dart';

class CashesApp extends StatefulWidget {
  const CashesApp({super.key});

  @override
  State<CashesApp> createState() => _CashesAppState();
}

class _CashesAppState extends State<CashesApp> {
  late final GoRouter _router;
  late final SessionGuard _sessionGuard;

  @override
  void initState() {
    super.initState();
    _router = buildAppRouter();
    _sessionGuard = SessionGuard(sl());
    _sessionGuard.start(
      onSignedOut: () => _router.go(AppRoutes.login),
      onUserDeleted: () => _router.go(AppRoutes.login),
      onSessionExpired: () => _router.go(AppRoutes.login),
    );
  }

  @override
  void dispose() {
    _sessionGuard.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<ThemeCubit>()),
        BlocProvider.value(value: sl<LocaleCubit>()),
        BlocProvider.value(value: sl<AuthCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (_, themeState) {
          return BlocBuilder<LocaleCubit, LocaleState>(
            builder: (_, localeState) {
              final fontFamily = localeState.locale.languageCode == 'ar'
                  ? AppAssets.fontCairo
                  : AppAssets.fontInter;

              return MaterialApp.router(
                title: 'Cashes',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light(fontFamily: fontFamily),
                darkTheme: AppTheme.dark(fontFamily: fontFamily),
                themeMode: themeState.themeMode,
                locale: localeState.locale,
                supportedLocales: const [Locale('ar'), Locale('en')],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                routerConfig: _router,
                builder: (context, child) {
                  return BlocListener<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is AuthDeleted) {
                        AppSnackbar.error(
                          context,
                          AppLocalizations.of(context)!.snackbarAccountDeleted,
                        );
                        _router.go(AppRoutes.login);
                      } else if (state is AuthSessionExpired) {
                        AppSnackbar.warning(
                          context,
                          AppLocalizations.of(context)!.snackbarSessionExpired,
                        );
                        _router.go(AppRoutes.login);
                      }
                    },
                    child: OfflineBanner(
                      networkInfo: sl<NetworkInfo>(),
                      child: child ?? const SizedBox.shrink(),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
