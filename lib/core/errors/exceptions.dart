// lib/core/errors/exceptions.dart
class ServerException implements Exception {
  const ServerException(this.message, {this.code});
  final String message;
  final String? code;
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'لا يوجد اتصال بالإنترنت']);
  final String message;
}

class AppAuthException implements Exception {
  const AppAuthException(this.message, {this.isDeleted = false, this.isExpired = false});
  final String message;
  final bool isDeleted;
  final bool isExpired;
}

class ValidationException implements Exception {
  const ValidationException(this.message);
  final String message;
}

class PermissionException implements Exception {
  const PermissionException([this.message = 'لا تملك الصلاحية لإجراء هذه العملية']);
  final String message;
}

class NotFoundException implements Exception {
  const NotFoundException([this.message = 'العنصر المطلوب غير موجود']);
  final String message;
}
