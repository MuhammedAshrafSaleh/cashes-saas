// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashes/app.dart';
import 'package:cashes/core/di/injection.dart';
import 'package:cashes/core/env/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Env.validate();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
    debug: false,
  );

  await initDI();

  runApp(const CashesApp());
}
