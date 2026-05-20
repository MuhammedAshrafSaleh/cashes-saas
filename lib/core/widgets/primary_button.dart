// lib/core/widgets/primary_button.dart
import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _tapped = false;

  @override
  void didUpdateWidget(PrimaryButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isLoading && oldWidget.isLoading) {
      _tapped = false;
    }
  }

  void _handlePress() {
    if (_tapped || !widget.isEnabled || widget.isLoading) return;
    setState(() => _tapped = true);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = _tapped || widget.isLoading || !widget.isEnabled;
    return ElevatedButton(
      onPressed: isDisabled ? null : _handlePress,
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
