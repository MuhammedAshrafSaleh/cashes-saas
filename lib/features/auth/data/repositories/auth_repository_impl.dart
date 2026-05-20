// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashes/core/errors/error_mapper.dart';
import 'package:cashes/core/errors/exceptions.dart';
import 'package:cashes/core/errors/failures.dart';
import 'package:cashes/core/network/network_info.dart';
import 'package:cashes/core/utils/app_logger.dart';
import 'package:cashes/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:cashes/features/auth/domain/entities/auth_user_entity.dart';
import 'package:cashes/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource, this._networkInfo);

  final AuthRemoteDataSource _dataSource;
  final NetworkInfo _networkInfo;
  final _log = getLogger('AuthRepository');

  Future<Either<Failure, T>?> _checkNetwork<T>() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    return null;
  }

  @override
  Future<Either<Failure, AuthUserEntity?>> getCurrentSession() async {
    final offline = await _checkNetwork<AuthUserEntity?>();
    if (offline != null) return offline;
    try {
      final user = await _dataSource.getCurrentUser();
      return Right(user);
    } on AppAuthException catch (e) {
      return Left(ErrorMapper.map(e));
    } on ServerException catch (e) {
      return Left(ErrorMapper.map(e));
    } catch (e) {
      _log.e('getCurrentSession unexpected', error: e);
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, AuthUserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    final offline = await _checkNetwork<AuthUserEntity>();
    if (offline != null) return offline;
    try {
      final user = await _dataSource.signIn(email: email, password: password);
      return Right(user);
    } on AppAuthException catch (e) {
      return Left(ErrorMapper.map(e));
    } on AuthApiException catch (e) {
      return Left(ErrorMapper.map(e));
    } catch (e) {
      _log.e('signIn unexpected', error: e);
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordReset(String email) async {
    final offline = await _checkNetwork<void>();
    if (offline != null) return offline;
    try {
      await _dataSource.sendPasswordReset(email);
      return const Right(null);
    } on AuthApiException catch (e) {
      return Left(ErrorMapper.map(e));
    } catch (e) {
      _log.e('sendPasswordReset unexpected', error: e);
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Right(null);
    } catch (e) {
      _log.e('signOut unexpected', error: e);
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Stream<AuthUserEntity?> watchAuthChanges() {
    return _dataSource.watchAuthChanges();
  }
}
