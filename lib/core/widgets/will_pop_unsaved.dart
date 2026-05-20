// lib/core/widgets/will_pop_unsaved.dart
import 'package:flutter/material.dart';
import 'package:cashes/core/widgets/confirm_dialog.dart';

class WillPopUnsaved extends StatelessWidget {
  const WillPopUnsaved({
    super.key,
    required this.hasUnsavedChanges,
    required this.child,
  });

  final bool hasUnsavedChanges;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final confirmed = await showConfirmDialog(
          context,
          title: 'تغييرات غير محفوظة',
          body: 'لديك تغييرات غير محفوظة. هل تريد المغادرة؟',
          confirmLabel: 'مغادرة',
          cancelLabel: 'إلغاء',
        );
        if (confirmed && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}
