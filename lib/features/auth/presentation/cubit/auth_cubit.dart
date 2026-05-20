// lib/features/auth/presentation/cubit/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashes/core/errors/failures.dart';
import 'package:cashes/core/utils/app_logger.dart';
import 'package:cashes/features/auth/domain/entities/auth_user_entity.dart';
import 'package:cashes/features/auth/domain/usecases/sign_out.dart';
import 'package:cashes/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._signOutUseCase) : super(const AuthInitial());

  final SignOutUseCase _signOutUseCase;
  final _log = getLogger('AuthCubit');

  void setAuthenticated(AuthUserEntity user) {
    emit(AuthAuthenticated(user));
  }

  void setUnauthenticated() {
    emit(const AuthUnauthenticated());
  }

  void setDeleted() {
    emit(const AuthDeleted());
  }

  void setExpired() {
    emit(const AuthSessionExpired());
  }

  void clear() {
    emit(const AuthUnauthenticated());
  }

  AuthUserEntity? get currentUser {
    final s = state;
    return s is AuthAuthenticated ? s.user : null;
  }

  UserRole? get currentRole => currentUser?.role;

  Future<void> signOut() async {
    final result = await _signOutUseCase();
    result.fold(
      (failure) {
        if (failure is AuthFailure) {
          _log.e('signOut failed: ${failure.message}');
        }
        // Clear local state even if signOut fails to reach the server
        emit(const AuthUnauthenticated());
      },
      (_) => emit(const AuthUnauthenticated()),
    );
  }
}
