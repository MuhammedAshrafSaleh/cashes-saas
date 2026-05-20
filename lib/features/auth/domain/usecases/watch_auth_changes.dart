// lib/features/auth/domain/usecases/watch_auth_changes.dart
import 'package:cashes/features/auth/domain/entities/auth_user_entity.dart';
import 'package:cashes/features/auth/domain/repositories/auth_repository.dart';

class WatchAuthChangesUseCase {
  WatchAuthChangesUseCase(this._repository);
  final AuthRepository _repository;

  Stream<AuthUserEntity?> call() {
    return _repository.watchAuthChanges();
  }
}
