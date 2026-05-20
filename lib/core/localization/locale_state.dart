// lib/core/localization/locale_state.dart
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class LocaleState extends Equatable {
  const LocaleState(this.locale);

  final Locale locale;

  @override
  List<Object> get props => [locale];
}
