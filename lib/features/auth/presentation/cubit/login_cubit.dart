// lib/features/auth/presentation/cubit/login_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashes/core/utils/app_logger.dart';
import 'package:cashes/features/auth/domain/usecases/sign_in.dart';
import 'package:cashes/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cashes/features/auth/presentation/cubit/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._signIn, this._authCubit) : super(const LoginInitial());

  final SignInUseCase _signIn;
  final AuthCubit _authCubit;
  final _log = getLogger('LoginCubit');

  Future<void> login({required String email, required String password}) async {
    emit(const LoginLoading());
    final result = await _signIn(SignInParams(email: email, password: password));
    result.fold(
      (failure) {
        _log.e('Login failed: ${failure.message}');
        emit(LoginError(failure.message));
      },
      (user) {
        _authCubit.setAuthenticated(user);
        emit(LoginSuccess(user));
      },
    );
  }

  void reset() => emit(const LoginInitial());
}
