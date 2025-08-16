import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../models/auth_state.dart';
import '../../../core/models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

// إضافة ProfileNotifier
final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref.read(authServiceProvider));
});

final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authService = ref.read(authServiceProvider);

  // استخدام AuthChangeEvent من Supabase مع تحديد النوع بوضوح
  return Supabase.instance.client.auth.onAuthStateChange.asyncMap((authChangeEvent) async {
    // authChangeEvent هو من نوع AuthChangeEvent وليس AuthState
    final user = authChangeEvent.session?.user;
    if (user == null) {
      ref.read(authNotifierProvider.notifier).clearState();
      return null;
    }

    try {
      return await authService.getCurrentUser();
    } catch (e) {
      print('خطأ في تحميل بيانات المستخدم: $e');
      return null;
    }
  });
});

class AuthNotifier extends StateNotifier<AppAuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthInitial());

  Future<void> signIn(String email, String password) async {
    state = const AuthLoading();
    try {
      await _authService.signIn(email, password);
      state = const AuthSuccess('تم تسجيل الدخول بنجاح');
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signUp(String email, String password, String fullName) async {
    state = const AuthLoading();
    try {
      await _authService.signUp(email, password, fullName);
      state = const AuthSuccess('تم إنشاء الحساب بنجاح');
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signOut() async {
    state = const AuthLoading();
    try {
      await _authService.signOut();
      state = const AuthSuccess('تم تسجيل الخروج بنجاح');
      clearState();
    } catch (e) {
      state = AuthError('فشل في تسجيل الخروج: ${e.toString()}');
    }
  }

  void clearState() {
    state = const AuthInitial();
  }
}

// ProfileNotifier Class
class ProfileNotifier extends StateNotifier<ProfileState> {
  final AuthService _authService;

  ProfileNotifier(this._authService) : super(const ProfileInitial());

  Future<void> updateProfile({
    String? fullName,
    String? bio,
    String? university,
    String? major,
    String? avatarPath,
  }) async {
    state = const ProfileLoading();
    try {
      await _authService.updateProfile(
        fullName: fullName,
        bio: bio,
        university: university,
        major: major,
        avatarPath: avatarPath,
      );
      state = const ProfileSuccess('تم تحديث الملف الشخصي بنجاح');
    } catch (e) {
      state = ProfileError(e.toString());
    }
  }
}

// Profile States
abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileSuccess extends ProfileState {
  final String message;
  const ProfileSuccess(this.message);
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
}