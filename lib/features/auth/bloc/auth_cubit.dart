import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/di/injection.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/repositories/user_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AppAuthState> {
  final AuthRepository _authRepository = sl<AuthRepository>();
  final UserRepository _userRepository = sl<UserRepository>();

  AuthCubit() : super(const AppAuthState.initial()) {
    _init();
  }

  // ═══════════════════════════════════════════════════════════════════
  // INITIALIZE - Check current auth state
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _init() async {
    _authRepository.authStateChanges.listen((authState) async {
      if (authState.session != null) {
        await _loadUserProfile();
      } else {
        emit(const AppAuthState.unauthenticated());
      }
    });

    // Check initial state
    if (_authRepository.isAuthenticated) {
      await _loadUserProfile();
    } else {
      emit(const AppAuthState.unauthenticated());
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAD USER PROFILE
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _loadUserProfile() async {
    try {
      final user = await _authRepository.getCurrentUserProfile();
      if (user != null) {
        emit(AppAuthState.authenticated(user));
      } else {
        emit(const AppAuthState.unauthenticated());
      }
    } catch (e) {
      emit(AppAuthState.error(e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // SIGN UP
  // ═══════════════════════════════════════════════════════════════════

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    emit(const AppAuthState.loading());

    try {
      final response = await _authRepository.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (response.user != null) {
        await _loadUserProfile();
      } else {
        emit(const AppAuthState.error('فشل إنشاء الحساب'));
      }
    } on AuthException catch (e) {
      emit(AppAuthState.error(_getArabicErrorMessage(e.message)));
    } catch (e) {
      emit(AppAuthState.error(e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // SIGN IN
  // ═══════════════════════════════════════════════════════════════════

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(const AppAuthState.loading());

    try {
      final response = await _authRepository.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile();
      } else {
        emit(const AppAuthState.error('فشل تسجيل الدخول'));
      }
    } on AuthException catch (e) {
      emit(AppAuthState.error(_getArabicErrorMessage(e.message)));
    } catch (e) {
      emit(AppAuthState.error(e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // SIGN IN WITH GOOGLE
  // ═══════════════════════════════════════════════════════════════════

  Future<void> signInWithGoogle() async {
    emit(const AppAuthState.loading());

    try {
      await _authRepository.signInWithGoogle();
      // Auth state listener will handle the rest
    } catch (e) {
      emit(AppAuthState.error(e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // SIGN OUT
  // ═══════════════════════════════════════════════════════════════════

  Future<void> signOut() async {
    emit(const AppAuthState.loading());

    try {
      await _authRepository.signOut();
      emit(const AppAuthState.unauthenticated());
    } catch (e) {
      emit(AppAuthState.error(e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // FORGOT PASSWORD
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> forgotPassword(String email) async {
    try {
      await _authRepository.resetPassword(email);
      return true;
    } catch (e) {
      emit(AppAuthState.error(e.toString()));
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // UPDATE PROFILE
  // ═══════════════════════════════════════════════════════════════════

  Future<void> updateProfile({
    String? fullName,
    String? username,
    String? phone,
    String? bio,
    String? university,
  }) async {
    if (state.user == null) return;

    try {
      final updatedUser = state.user!.copyWith(
        fullName: fullName ?? state.user!.fullName,
        username: username ?? state.user!.username,
        phone: phone ?? state.user!.phone,
        bio: bio ?? state.user!.bio,
        university: university ?? state.user!.university,
      );

      final result = await _userRepository.updateProfile(updatedUser);
      emit(AppAuthState.authenticated(result));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // REFRESH USER
  // ═══════════════════════════════════��═══════════════════════════════

  Future<void> refreshUser() async {
    await _loadUserProfile();
  }

  // ═══════════════════════════════════════════════════════════════════
  // HELPER: Arabic error messages
  // ═══════════════════════════════════════════════════════════════════

  String _getArabicErrorMessage(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (message.contains('Email not confirmed')) {
      return 'يرجى تأكيد البريد الإلكتروني أولاً';
    }
    if (message.contains('User already registered')) {
      return 'البريد الإلكتروني مسجل مسبقاً';
    }
    if (message.contains('Password should be at least')) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    if (message.contains('Unable to validate email')) {
      return 'البريد الإلكتروني غير صحيح';
    }
    if (message.contains('Email rate limit exceeded')) {
      return 'تم تجاوز الحد المسموح، حاول لاحقاً';
    }
    return message;
  }
}