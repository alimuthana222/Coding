import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('فشل في تسجيل الدخول');
      }
    } catch (e) {
      if (e is AuthException) {
        switch (e.message) {
          case 'Invalid login credentials':
            throw Exception('بيانات الدخول غير صحيحة');
          case 'Email not confirmed':
            throw Exception('يرجى تأكيد البريد الإلكتروني أولاً');
          case 'Too many requests':
            throw Exception('محاولات كثيرة، يرجى المحاولة لاحقاً');
          default:
            throw Exception('خطأ في تسجيل الدخول: ${e.message}');
        }
      }
      throw Exception('خطأ في الاتصال بالخادم');
    }
  }

  Future<void> signUp(String email, String password, String fullName) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      );

      if (response.user == null) {
        throw Exception('فشل في إنشاء الحساب');
      }
    } catch (e) {
      if (e is AuthException) {
        switch (e.message) {
          case 'User already registered':
            throw Exception('البريد الإلكتروني مستخدم مسبقاً');
          case 'Password should be at least 6 characters':
            throw Exception('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
          case 'Unable to validate email address: invalid format':
            throw Exception('صيغة البريد الإلكتروني غير صحيحة');
          default:
            throw Exception('خطأ في إنشاء الحساب: ${e.message}');
        }
      }
      throw Exception('خطأ في الاتصال بالخادم');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('خطأ في تسجيل الخروج');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      if (e is AuthException) {
        switch (e.message) {
          case 'Unable to validate email address: invalid format':
            throw Exception('صيغة البريد الإلكتروني غير صحيحة');
          case 'Email not found':
            throw Exception('البريد الإلكتروني غير مسجل');
          default:
            throw Exception('خطأ في إرسال رابط استعادة كلمة المرور: ${e.message}');
        }
      }
      throw Exception('خطأ في الاتصال بالخادم');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return null;

      // Get profile data from database
      final profileData = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', currentUser.id)
          .maybeSingle();

      if (profileData == null) {
        // Create profile if it doesn't exist
        final newProfile = {
          'id': currentUser.id,
          'email': currentUser.email!,
          'full_name': currentUser.userMetadata?['full_name'] ?? '',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        await _supabase.from('profiles').insert(newProfile);

        return UserModel.fromJson({
          ...newProfile,
          'role': 'user',
          'wallet_balance': 0.0,
          'reserved_balance': 0.0,
          'time_balance': 0,
          'rating': 0.0,
          'review_count': 0,
          'is_verified': false,
          'is_suspended': false,
        });
      }

      return UserModel.fromJson(profileData);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? bio,
    String? university,
    String? major,
    String? avatarPath,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('المستخدم غير مسجل الدخول');

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updates['full_name'] = fullName;
      if (bio != null) updates['bio'] = bio;
      if (university != null) updates['university'] = university;
      if (major != null) updates['major'] = major;
      if (avatarPath != null) updates['avatar_url'] = avatarPath;

      await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', currentUser.id);
    } catch (e) {
      throw Exception('فشل في تحديث الملف الشخصي');
    }
  }

  // Listen to auth state changes
  Stream<UserModel?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.asyncMap((data) async {
      final session = data.session;
      final user = session?.user;
      if (user == null) return null;

      return await getCurrentUser();
    });
  }

}