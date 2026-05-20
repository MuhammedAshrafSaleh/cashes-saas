// lib/core/theme/theme_state.dart
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class ThemeState extends Equatable {
  const ThemeState(this.themeMode);

  final ThemeMode themeMode;

  @override
  List<Object> get props => [themeMode];
}
