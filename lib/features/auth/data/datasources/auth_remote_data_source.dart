// lib/features/auth/data/datasources/auth_remote_data_source.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashes/core/errors/exceptions.dart';
import 'package:cashes/core/utils/app_logger.dart';
import 'package:cashes/features/auth/data/models/auth_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUserModel?> getCurrentUser();
  Future<AuthUserModel> signIn({required String email, required String password});
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
  Stream<AuthUserModel?> watchAuthChanges();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;
  final _log = getLogger('AuthRemoteDataSource');

  @override
  Future<AuthUserModel?> getCurrentUser() async {
    final session = _client.auth.currentSession;
    if (session == null) return null;
    return _fetchPublicUser(session.user.id);
  }

  @override
  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AppAuthException('فشل تسجيل الدخول');
      }
      return await _fetchPublicUser(user.id) ??
          (throw const AppAuthException('تم حذف حسابك', isDeleted: true));
    } on AuthApiException catch (e) {
      _log.e('signIn AuthApiException', error: e);
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthApiException catch (e) {
      _log.e('sendPasswordReset error', error: e);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthApiException catch (e) {
      _log.e('signOut error', error: e);
      rethrow;
    }
  }

  @override
  Stream<AuthUserModel?> watchAuthChanges() {
    return _client.auth.onAuthStateChange.asyncMap((data) async {
      final user = data.session?.user;
      if (user == null) return null;
      return _fetchPublicUser(user.id);
    });
  }

  Future<AuthUserModel?> _fetchPublicUser(String uid) async {
    try {
      final row = await _client
          .from('users')
          .select()
          .eq('id', uid)
          .maybeSingle();
      if (row == null) return null;
      return AuthUserModel.fromJson(row);
    } on PostgrestException catch (e) {
      _log.e('_fetchPublicUser error', error: e);
      throw ServerException(e.message, code: e.code);
    }
  }
}
