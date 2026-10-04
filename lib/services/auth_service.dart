import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import 'supabase_config.dart';

/// Thrown for anything AuthService rejects before it reaches Supabase, or
/// wraps a Supabase AuthException in, so screens can show one message type.
class AuthServiceException implements Exception {
  AuthServiceException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Wraps Supabase Auth. The mockup only collects a *username*, not an
/// email — but Supabase's email/password auth needs an email-shaped
/// string. Rather than add an email field the design never asked for,
/// this derives a deterministic, never-shown "synthetic" email from the
/// username (lowercased, so "John" and "john" collide on purpose — that's
/// what gives us free username-uniqueness via Supabase's own email
/// uniqueness constraint). If you'd rather collect a real email later,
/// that's the "or a dedicated email field" TODO left on the Register form.
class AuthService {
  static String _syntheticEmail(String username) =>
      '${username.trim().toLowerCase()}@users.kalinga.app';

  static String? get currentUserId => supabase.auth.currentUser?.id;
  static bool get isSignedIn => supabase.auth.currentUser != null;

  static Future<void> signUp({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required double heightCm,
    required double weightKg,
  }) async {
    final AuthResponse res;
    try {
      res = await supabase.auth.signUp(
        email: _syntheticEmail(username),
        password: password,
      );
    } on AuthException catch (e) {
      // Supabase's own message for "email already registered" is what
      // actually enforces username uniqueness here — surface it plainly.
      throw AuthServiceException(e.message);
    }

    final userId = res.user?.id;
    if (userId == null) {
      throw AuthServiceException('Sign-up did not return a user. Try again.');
    }

    final profile = UserProfile(
      id: userId,
      username: username.trim(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      dateOfBirth: dateOfBirth,
      heightCm: heightCm,
      weightKg: weightKg,
    );

    try {
      await supabase.from('profiles').insert(profile.toInsertMap());
    } on PostgrestException catch (e) {
      // The auth user now exists but the profile insert failed (e.g. RLS
      // misconfigured, or `profiles` doesn't exist yet). Surface this
      // distinctly — a half-created account is a real, confusing state.
      throw AuthServiceException(
        'Account created, but saving your profile failed: ${e.message}',
      );
    }
  }

  static Future<void> signIn({
    required String username,
    required String password,
  }) async {
    try {
      await supabase.auth.signInWithPassword(
        email: _syntheticEmail(username),
        password: password,
      );
    } on AuthException catch (e) {
      throw AuthServiceException(e.message);
    }
  }

  static Future<void> signOut() => supabase.auth.signOut();
}
