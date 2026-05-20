// lib/core/widgets/danger_button.dart
import 'package:flutter/material.dart';
import 'package:cashes/core/theme/app_colors.dart';

class DangerButton extends StatefulWidget {
  const DangerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  State<DangerButton> createState() => _DangerButtonState();
}

class _DangerButtonState extends State<DangerButton> {
  bool _tapped = false;

  @override
  void didUpdateWidget(DangerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isLoading && oldWidget.isLoading) _tapped = false;
  }

  void _handlePress() {
    if (_tapped || widget.isLoading) return;
    setState(() => _tapped = true);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (_tapped || widget.isLoading) ? null : _handlePress,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.danger,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: widget.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Text(widget.label),
    );
  }
}
