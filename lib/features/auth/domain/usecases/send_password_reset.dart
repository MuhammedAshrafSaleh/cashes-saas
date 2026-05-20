// lib/features/auth/domain/usecases/send_password_reset.dart
import 'package:dartz/dartz.dart';
import 'package:cashes/core/errors/failures.dart';
import 'package:cashes/features/auth/domain/repositories/auth_repository.dart';

class SendPasswordResetUseCase {
  SendPasswordResetUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, void>> call(String email) async {
    return _repository.sendPasswordReset(email);
  }
}
