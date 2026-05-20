// lib/core/utils/input_formatters.dart
import 'package:flutter/services.dart';

class AmountInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = newValue.text.replaceAll(',', '');
    if (cleaned.isEmpty) return newValue;
    // Allow digits and a single decimal point
    if (!RegExp(r'^\d*\.?\d{0,2}$').hasMatch(cleaned)) return oldValue;
    return newValue.copyWith(text: cleaned);
  }
}
