// lib/core/network/supabase_client_provider.dart
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient getSupabaseClient() => Supabase.instance.client;
