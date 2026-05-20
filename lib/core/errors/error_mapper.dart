// lib/core/errors/error_mapper.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashes/core/errors/exceptions.dart';
import 'package:cashes/core/errors/failures.dart';

class ErrorMapper {
  ErrorMapper._();

  static Failure map(Object error) {
    if (error is AuthFailure) return error;
    if (error is NetworkFailure) return error;
    if (error is ValidationFailure) return error;
    if (error is PermissionFailure) return error;
    if (error is NotFoundFailure) return error;
    if (error is ServerFailure) return error;

    if (error is NetworkException) return NetworkFailure(error.message);
    if (error is ValidationException) return ValidationFailure(error.message);
    if (error is PermissionException) return PermissionFailure(error.message);
    if (error is NotFoundException) return NotFoundFailure(error.message);

    if (error is AppAuthException) {
      return AuthFailure(
        error.message,
        isDeleted: error.isDeleted,
        isExpired: error.isExpired,
      );
    }

    if (error is PostgrestException) {
      return _fromPostgrest(error);
    }

    if (error is AuthApiException) {
      return _fromAuthApi(error);
    }

    if (error is ServerException) return ServerFailure(error.message);

    return const ServerFailure('حدث خطأ غير متوقع');
  }

  static Failure _fromPostgrest(PostgrestException e) {
    // PGRST116: no rows returned — user deleted
    if (e.code == 'PGRST116') {
      return const AuthFailure('تم حذف حسابك', isDeleted: true);
    }
    // 42501: RLS / permission denied
    if (e.code == '42501') {
      return const PermissionFailure();
    }
    // 23505: unique violation
    if (e.code == '23505') {
      return ServerFailure(e.message);
    }
    // 23514: check constraint (e.g. amount > 0)
    if (e.code == '23514') {
      return const ValidationFailure('البيانات المدخلة لا تستوفي الشروط المطلوبة');
    }
    return ServerFailure(e.message);
  }

  static Failure _fromAuthApi(AuthApiException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials') || msg.contains('invalid credentials')) {
      return const AuthFailure('البريد الإلكتروني أو كلمة المرور غير صحيحة');
    }
    if (msg.contains('token') || msg.contains('expired')) {
      return const AuthFailure('انتهت جلستك، سجل دخولك مرة أخرى', isExpired: true);
    }
    if (msg.contains('email already')) {
      return const ValidationFailure('البريد الإلكتروني مستخدم بالفعل');
    }
    return AuthFailure(e.message);
  }

  static bool isHttpUnauthorized(Object error) {
    if (error is PostgrestException) {
      return error.code == 'PGRST301' || error.message.contains('401');
    }
    return false;
  }

  static bool isHttpForbidden(Object error) {
    if (error is PostgrestException) {
      return error.code == '42501' || error.message.contains('403');
    }
    return false;
  }
}
