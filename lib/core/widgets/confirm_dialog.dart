// lib/core/widgets/confirm_dialog.dart
import 'package:flutter/material.dart';
import 'package:cashes/core/theme/app_colors.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  String? confirmLabel,
  String? cancelLabel,
  bool isDestructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel ?? 'إلغاء'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: isDestructive
              ? TextButton.styleFrom(foregroundColor: AppColors.danger)
              : null,
          child: Text(confirmLabel ?? 'تأكيد'),
        ),
      ],
    ),
  );
  return result ?? false;
}
