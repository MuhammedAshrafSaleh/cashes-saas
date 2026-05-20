// lib/features/auth/presentation/cubit/auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:cashes/features/auth/domain/entities/auth_user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final AuthUserEntity user;

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthDeleted extends AuthState {
  const AuthDeleted();
}

class AuthSessionExpired extends AuthState {
  const AuthSessionExpired();
}
