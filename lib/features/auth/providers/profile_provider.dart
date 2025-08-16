import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import 'auth_provider.dart';

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref.read(authServiceProvider));
});

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