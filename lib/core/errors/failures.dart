// lib/core/errors/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'لا يوجد اتصال بالإنترنت']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {this.isDeleted = false, this.isExpired = false});
  final bool isDeleted;
  final bool isExpired;

  @override
  List<Object> get props => [message, isDeleted, isExpired];
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'لا تملك الصلاحية لإجراء هذه العملية']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'العنصر المطلوب غير موجود']);
}
