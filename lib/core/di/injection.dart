// lib/core/di/injection.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashes/core/localization/locale_cubit.dart';
import 'package:cashes/core/network/network_info.dart';
import 'package:cashes/core/theme/theme_cubit.dart';
import 'package:cashes/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:cashes/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cashes/features/auth/domain/repositories/auth_repository.dart';
import 'package:cashes/features/auth/domain/usecases/get_current_session.dart';
import 'package:cashes/features/auth/domain/usecases/send_password_reset.dart';
import 'package:cashes/features/auth/domain/usecases/sign_in.dart';
import 'package:cashes/features/auth/domain/usecases/sign_out.dart';
import 'package:cashes/features/auth/domain/usecases/watch_auth_changes.dart';
import 'package:cashes/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cashes/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:cashes/features/auth/presentation/cubit/login_cubit.dart';
import 'package:cashes/features/auth/presentation/cubit/splash_cubit.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Network
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl<Connectivity>()));

  // Theme + Locale
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(sl<SharedPreferences>()));
  sl.registerLazySingleton<LocaleCubit>(() => LocaleCubit(sl<SharedPreferences>()));

  // Auth — Data
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>(), sl<NetworkInfo>()),
  );

  // Auth — Use Cases
  sl.registerFactory(() => GetCurrentSessionUseCase(sl<AuthRepository>()));
  sl.registerFactory(() => SignInUseCase(sl<AuthRepository>()));
  sl.registerFactory(() => SendPasswordResetUseCase(sl<AuthRepository>()));
  sl.registerFactory(() => SignOutUseCase(sl<AuthRepository>()));
  sl.registerFactory(() => WatchAuthChangesUseCase(sl<AuthRepository>()));

  // Auth — Global Cubit (singleton — lives for app lifetime)
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(sl<SignOutUseCase>()));

  // Auth — Screen Cubits (factories — created per screen)
  sl.registerFactory<SplashCubit>(
    () => SplashCubit(
      sl<GetCurrentSessionUseCase>(),
      sl<AuthCubit>(),
    ),
  );
  sl.registerFactory<LoginCubit>(
    () => LoginCubit(sl<SignInUseCase>(), sl<AuthCubit>()),
  );
  sl.registerFactory<ForgotPasswordCubit>(
    () => ForgotPasswordCubit(sl<SendPasswordResetUseCase>()),
  );
}
