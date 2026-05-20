// lib/features/auth/presentation/cubit/forgot_password_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashes/core/utils/app_logger.dart';
import 'package:cashes/features/auth/domain/usecases/send_password_reset.dart';
import 'package:cashes/features/auth/presentation/cubit/forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit(this._sendPasswordReset) : super(const ForgotPasswordInitial());

  final SendPasswordResetUseCase _sendPasswordReset;
  final _log = getLogger('ForgotPasswordCubit');

  Future<void> sendReset(String email) async {
    emit(const ForgotPasswordLoading());
    final result = await _sendPasswordReset(email);
    result.fold(
      (failure) {
        _log.e('Password reset failed: ${failure.message}');
        emit(ForgotPasswordError(failure.message));
      },
      (_) => emit(ForgotPasswordSuccess(email)),
    );
  }

  void reset() => emit(const ForgotPasswordInitial());
}
