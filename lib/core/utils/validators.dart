// lib/core/utils/validators.dart
class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'هذا الحقل مطلوب';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'يرجى إدخال بريد إلكتروني صحيح';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
    if (value.length < 8) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
    if (value != original) return 'كلمتا المرور غير متطابقتين';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'هذا الحقل مطلوب';
    if (value.trim().length < 2) return 'الاسم يجب أن يكون حرفين على الأقل';
    return null;
  }

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'هذا الحقل مطلوب';
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) return 'هذا الحقل مطلوب';
    final cleaned = value.replaceAll(',', '');
    final parsed = double.tryParse(cleaned);
    if (parsed == null) return 'يرجى إدخال مبلغ صحيح';
    if (parsed <= 0) return 'المبلغ يجب أن يكون أكبر من صفر';
    return null;
  }
}
