// lib/features/auth/domain/usecases/sign_in.dart
import 'package:dartz/dartz.dart';
import 'package:cashes/core/errors/failures.dart';
import 'package:cashes/features/auth/domain/entities/auth_user_entity.dart';
import 'package:cashes/features/auth/domain/repositories/auth_repository.dart';

class SignInParams {
  const SignInParams({required this.email, required this.password});
  final String email;
  final String password;
}

class SignInUseCase {
  SignInUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, AuthUserEntity>> call(SignInParams params) async {
    return _repository.signIn(email: params.email, password: params.password);
  }
}
