import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/user_model.dart';

class AuthRepository {
  final _auth = SupabaseConfig.auth;
  final _client = SupabaseConfig.client;

  // ═══════════════════════════════════════════════════════════════════
  // AUTH STATE
  // ═══════════════════════════════════════════════════════════════════

  User? get currentUser => _auth.currentUser;
  String? get currentUserId => currentUser?.id;
  bool get isAuthenticated => currentUser != null;
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  // ═══════════════════════════════════════════════════════════════════
  // SIGN UP
  // ═══════════════════════════════════════════════════════════════════

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
    return response;
  }

  // ═══════════════════════════════════════════════════════════════════
  // SIGN IN
  // ═══════════════════════════════════════════════════════════════════

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );

    // Update online status
    if (response.user != null) {
      await _updateOnlineStatus(true);
    }

    return response;
  }

  // ═══════════════════════════════════════════════════════════════════
  // SIGN IN WITH GOOGLE
  // ══════════════════════════════════════════════════════���════════════

  Future<bool> signInWithGoogle() async {
    final response = await _auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.maharat://login-callback/',
    );
    return response;
  }

  // ═══════════════════════════════════════════════════════════════════
  // SIGN OUT
  // ═══════════════════════════════════════════════════════════════════

  Future<void> signOut() async {
    await _updateOnlineStatus(false);
    await _auth.signOut();
  }

  // ═══════════════════════════════════════════════════════════════════
  // FORGOT PASSWORD
  // ═══════════════════════════════════════════════════════════════════

  Future<void> resetPassword(String email) async {
    await _auth.resetPasswordForEmail(email);
  }

  // ═══════════════════════════════════════════════════════════════════
  // UPDATE PASSWORD
  // ═══════════════════════════════════════════════════════════════════

  Future<UserResponse> updatePassword(String newPassword) async {
    return await _auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET CURRENT USER PROFILE
  // ═══════════════════════════════════════════════════════════════════

  Future<UserModel?> getCurrentUserProfile() async {
    if (currentUserId == null) return null;

    final response = await _client
        .from(SupabaseConfig.profilesTable)
        .select()
        .eq('id', currentUserId!)
        .single();

    return UserModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // HELPER: Update online status
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _updateOnlineStatus(bool isOnline) async {
    if (currentUserId == null) return;

    await _client.from(SupabaseConfig.profilesTable).update({
      'is_online': isOnline,
      'last_seen': DateTime.now().toIso8601String(),
    }).eq('id', currentUserId!);
  }
}