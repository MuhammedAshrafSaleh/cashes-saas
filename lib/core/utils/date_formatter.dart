// lib/core/utils/date_formatter.dart
import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String format(DateTime date, {String locale = 'ar'}) {
    return DateFormat('dd/MM/yyyy', locale).format(date);
  }

  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return '${diff.inMinutes} دقيقة مضت';
    if (diff.inDays < 1) return '${diff.inHours} ساعة مضت';
    return format(dateTime);
  }

  static DateTime? parseDate(String value) {
    try {
      final parts = value.split('/');
      if (parts.length != 3) return null;
      return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    } catch (_) {
      return null;
    }
  }
}
