// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:cashes/core/errors/failures.dart';
import 'package:cashes/features/auth/domain/entities/auth_user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthUserEntity?>> getCurrentSession();
  Future<Either<Failure, AuthUserEntity>> signIn({
    required String email,
    required String password,
  });
  Future<Either<Failure, void>> sendPasswordReset(String email);
  Future<Either<Failure, void>> signOut();
  Stream<AuthUserEntity?> watchAuthChanges();
}
