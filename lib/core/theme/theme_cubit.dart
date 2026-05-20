// lib/core/theme/theme_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cashes/core/constants/app_storage_keys.dart';
import 'package:cashes/core/theme/theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this._prefs) : super(const ThemeState(ThemeMode.dark)) {
    _loadSavedTheme();
  }

  final SharedPreferences _prefs;

  void _loadSavedTheme() {
    final saved = _prefs.getString(AppStorageKeys.themeMode);
    final mode = saved == 'light' ? ThemeMode.light : ThemeMode.dark;
    emit(ThemeState(mode));
  }

  Future<void> toggle() async {
    final next = state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _prefs.setString(AppStorageKeys.themeMode, next == ThemeMode.light ? 'light' : 'dark');
    emit(ThemeState(next));
  }

  Future<void> setDark() async {
    await _prefs.setString(AppStorageKeys.themeMode, 'dark');
    emit(const ThemeState(ThemeMode.dark));
  }

  Future<void> setLight() async {
    await _prefs.setString(AppStorageKeys.themeMode, 'light');
    emit(const ThemeState(ThemeMode.light));
  }
}
