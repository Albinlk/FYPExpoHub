import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

class SupabaseAuthService {
  final SupabaseClient _client;

  SupabaseAuthService(this._client);

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// Sign in with email and password
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );
      return res;
    } catch (e) {
      logDebug('Supabase signInWithPassword error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      logDebug('Supabase signOut error: $e');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim().toLowerCase(),
      );
    } catch (e) {
      logDebug('Supabase resetPasswordForEmail error: $e');
      rethrow;
    }
  }
}
