// lib/core/env/env.dart
class Env {
  Env._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static void validate() {
    if (supabaseUrl.isEmpty) {
      throw StateError('SUPABASE_URL is not set. Run with --dart-define=SUPABASE_URL=...');
    }
    if (supabaseAnonKey.isEmpty) {
      throw StateError('SUPABASE_ANON_KEY is not set. Run with --dart-define=SUPABASE_ANON_KEY=...');
    }
  }
}
