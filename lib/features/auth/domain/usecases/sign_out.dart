// lib/features/auth/domain/usecases/sign_out.dart
import 'package:dartz/dartz.dart';
import 'package:cashes/core/errors/failures.dart';
import 'package:cashes/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  SignOutUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, void>> call() async {
    return _repository.signOut();
  }
}
