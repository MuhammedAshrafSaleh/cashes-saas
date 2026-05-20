// lib/features/auth/presentation/cubit/splash_state.dart
import 'package:equatable/equatable.dart';
import 'package:cashes/features/auth/domain/entities/auth_user_entity.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashLoading extends SplashState {
  const SplashLoading();
}

class SplashAuthenticated extends SplashState {
  const SplashAuthenticated(this.user);
  final AuthUserEntity user;

  @override
  List<Object?> get props => [user];
}

class SplashUnauthenticated extends SplashState {
  const SplashUnauthenticated();
}
