// lib/core/localization/locale_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cashes/core/constants/app_storage_keys.dart';
import 'package:cashes/core/localization/locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit(this._prefs) : super(const LocaleState(Locale('ar'))) {
    _loadSavedLocale();
  }

  final SharedPreferences _prefs;

  void _loadSavedLocale() {
    final saved = _prefs.getString(AppStorageKeys.locale);
    final locale = saved == 'en' ? const Locale('en') : const Locale('ar');
    emit(LocaleState(locale));
  }

  Future<void> setArabic() async {
    await _prefs.setString(AppStorageKeys.locale, 'ar');
    emit(const LocaleState(Locale('ar')));
  }

  Future<void> setEnglish() async {
    await _prefs.setString(AppStorageKeys.locale, 'en');
    emit(const LocaleState(Locale('en')));
  }

  Future<void> toggle() async {
    if (state.locale.languageCode == 'ar') {
      await setEnglish();
    } else {
      await setArabic();
    }
  }
}
