// lib/features/auth/presentation/cubit/login_state.dart
import 'package:equatable/equatable.dart';
import 'package:cashes/features/auth/domain/entities/auth_user_entity.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  const LoginSuccess(this.user);
  final AuthUserEntity user;

  @override
  List<Object?> get props => [user];
}

class LoginError extends LoginState {
  const LoginError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
