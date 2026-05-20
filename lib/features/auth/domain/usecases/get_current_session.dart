// lib/features/auth/domain/usecases/get_current_session.dart
import 'package:dartz/dartz.dart';
import 'package:cashes/core/errors/failures.dart';
import 'package:cashes/features/auth/domain/entities/auth_user_entity.dart';
import 'package:cashes/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentSessionUseCase {
  GetCurrentSessionUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, AuthUserEntity?>> call() async {
    return _repository.getCurrentSession();
  }
}
