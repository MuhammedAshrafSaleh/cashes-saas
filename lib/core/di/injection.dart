// lib/core/di/injection.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashes/core/localization/locale_cubit.dart';
import 'package:cashes/core/network/network_info.dart';
import 'package:cashes/core/theme/theme_cubit.dart';

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

  // Features will register their dependencies here incrementally (Phase 2+)
}
