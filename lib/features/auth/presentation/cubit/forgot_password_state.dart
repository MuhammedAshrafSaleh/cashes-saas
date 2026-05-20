// lib/features/auth/presentation/cubit/forgot_password_state.dart
import 'package:equatable/equatable.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

class ForgotPasswordSuccess extends ForgotPasswordState {
  const ForgotPasswordSuccess(this.email);
  final String email;

  @override
  List<Object?> get props => [email];
}

class ForgotPasswordError extends ForgotPasswordState {
  const ForgotPasswordError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
