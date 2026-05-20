// lib/core/widgets/app_snackbar.dart
import 'package:flutter/material.dart';
import 'package:cashes/core/constants/app_durations.dart';
import 'package:cashes/core/theme/app_colors.dart';

enum SnackbarType { success, error, warning, info }

class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: AppDurations.snackbar,
          backgroundColor: _colorFor(type),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
  }

  static void success(BuildContext context, String message) =>
      show(context, message: message, type: SnackbarType.success);

  static void error(BuildContext context, String message) =>
      show(context, message: message, type: SnackbarType.error);

  static void warning(BuildContext context, String message) =>
      show(context, message: message, type: SnackbarType.warning);

  static void info(BuildContext context, String message) =>
      show(context, message: message, type: SnackbarType.info);

  static Color _colorFor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return AppColors.success;
      case SnackbarType.error:
        return AppColors.danger;
      case SnackbarType.warning:
        return AppColors.warning;
      case SnackbarType.info:
        return AppColors.info;
    }
  }
}
