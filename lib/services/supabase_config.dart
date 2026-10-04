import 'package:supabase_flutter/supabase_flutter.dart';

/// Reads Supabase config from --dart-define (see .env.example and
/// .github/workflows/deploy-web.yml — this project never uses
/// flutter_dotenv, to stay consistent with how the deploy workflow injects
/// these values).
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

/// Call once, before runApp. Throws a clear error instead of a confusing
/// null-check failure later if the --dart-define values were never passed.
Future<void> initSupabase() async {
  if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
    throw StateError(
      'SUPABASE_URL / SUPABASE_PUBLISHABLE_KEY were not provided. Run with, '
      'e.g.:\n'
      '  flutter run -d chrome '
      '--dart-define=SUPABASE_URL=... '
      '--dart-define=SUPABASE_PUBLISHABLE_KEY=...\n'
      'See .env.example for what these are and where to get them.',
    );
  }
  await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
}

/// Shorthand used throughout lib/services/ instead of repeating
/// `Supabase.instance.client` everywhere.
SupabaseClient get supabase => Supabase.instance.client;
