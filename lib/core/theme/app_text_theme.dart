// lib/core/theme/app_text_theme.dart
import 'package:flutter/material.dart';
import 'package:cashes/core/constants/app_assets.dart';

TextTheme buildTextTheme(Color textColor, {String fontFamily = AppAssets.fontCairo}) {
  return TextTheme(
    displayLarge: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.w700),
    displayMedium: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.w700),
    displaySmall: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.w600),
    headlineLarge: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(fontFamily: fontFamily, color: textColor, fontWeight: FontWeight.w400),
  );
}
