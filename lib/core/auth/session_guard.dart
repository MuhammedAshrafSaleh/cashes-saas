// lib/core/auth/session_guard.dart
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashes/core/utils/app_logger.dart';

typedef OnSignedOut = void Function();
typedef OnUserDeleted = void Function();
typedef OnSessionExpired = void Function();

class SessionGuard {
  SessionGuard(this._client);

  final SupabaseClient _client;
  final _log = getLogger('SessionGuard');
  StreamSubscription<AuthState>? _sub;

  void start({
    required OnSignedOut onSignedOut,
    required OnUserDeleted onUserDeleted,
    required OnSessionExpired onSessionExpired,
  }) {
    _sub = _client.auth.onAuthStateChange.listen((data) {
      _log.d('AuthChangeEvent: ${data.event}');
      switch (data.event) {
        case AuthChangeEvent.signedOut:
          onSignedOut();
        case AuthChangeEvent.tokenRefreshed:
          // no-op — Supabase already updated headers
          break;
        default:
          break;
      }
    }, onError: (Object e) {
      _log.e('Auth stream error', error: e);
      onSessionExpired();
    });
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
