// lib/features/auth/presentation/cubit/splash_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashes/core/constants/app_durations.dart';
import 'package:cashes/core/errors/failures.dart';
import 'package:cashes/core/utils/app_logger.dart';
import 'package:cashes/features/auth/domain/entities/auth_user_entity.dart';
import 'package:cashes/features/auth/domain/usecases/get_current_session.dart';
import 'package:cashes/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cashes/features/auth/presentation/cubit/splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit(
    this._getCurrentSession,
    this._authCubit,
  ) : super(const SplashInitial());

  final GetCurrentSessionUseCase _getCurrentSession;
  final AuthCubit _authCubit;
  final _log = getLogger('SplashCubit');

  Future<void> initialize() async {
    emit(const SplashLoading());

    final timerFuture = Future<void>.delayed(AppDurations.splashMin);
    final sessionFuture = _getCurrentSession();

    final results = await Future.wait([timerFuture, sessionFuture]);
    final sessionResult = results[1] as Either<Failure, AuthUserEntity?>;

    sessionResult.fold(
      (failure) {
        _log.e('Session check failed: ${failure.message}');
        _authCubit.setUnauthenticated();
        emit(const SplashUnauthenticated());
      },
      (user) {
        if (user == null) {
          _authCubit.setUnauthenticated();
          emit(const SplashUnauthenticated());
        } else {
          _authCubit.setAuthenticated(user);
          emit(SplashAuthenticated(user));
        }
      },
    );
  }
}
