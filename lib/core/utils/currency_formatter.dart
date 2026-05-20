// lib/core/utils/currency_formatter.dart
import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat('#,##0.00');

  static String format(double amount) => _formatter.format(amount);

  static String formatWithSymbol(double amount, {String symbol = 'ج.م'}) {
    return '${_formatter.format(amount)} $symbol';
  }

  static double? parse(String value) {
    final cleaned = value.replaceAll(',', '');
    return double.tryParse(cleaned);
  }
}
