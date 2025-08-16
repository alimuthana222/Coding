import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/deposit_request_model.dart';
import '../models/admin_stats_model.dart';
import '/core/models/user_model.dart';
import '/features/services/models/service_model.dart';
import '/features/bookings/models/booking_model.dart';

class AdminService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==== Deposit Requests Methods ====
  Future<List<DepositRequestModel>> getDepositRequests({
    String? status,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      // بناء الاستعلام الأساسي
      var query = _supabase
          .from('deposit_requests')
          .select('''
            *,
            profiles:user_id (
              full_name,
              email,
              avatar_url
            )
          ''');

      // إضافة فلتر الحالة إذا تم تحديدها
      if (status != null) {
        query = query.eq('status', status);
      }

      // تنفيذ الاستعلام
      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // تحويل البيانات إلى قائمة من DepositRequestModel
      return (response as List).map<DepositRequestModel>((json) {
        final profile = json['profiles'] as Map<String, dynamic>?;

        return DepositRequestModel.fromJson({
          ...json,
          'userName': profile?['full_name'],
          'userEmail': profile?['email'],
          'userAvatarUrl': profile?['avatar_url'],
        });
      }).toList();
    } catch (e) {
      throw Exception('فشل في تحميل طلبات الإيداع: ${e.toString()}');
    }
  }

  Future<void> approveDepositRequest(String requestId, {String? adminNotes}) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    try {
      await _supabase
          .from('deposit_requests')
          .update({
        'status': 'approved',
        'admin_notes': adminNotes,
        'processed_by': currentUser.id,
        'processed_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', requestId);
    } catch (e) {
      throw Exception('فشل في قبول طلب الإيداع: ${e.toString()}');
    }
  }

  Future<void> rejectDepositRequest(String requestId, {required String reason}) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    try {
      await _supabase
          .from('deposit_requests')
          .update({
        'status': 'rejected',
        'admin_notes': reason,
        'processed_by': currentUser.id,
        'processed_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', requestId);
    } catch (e) {
      throw Exception('فشل في رفض طلب الإيداع: ${e.toString()}');
    }
  }

  Future<void> updateDepositRequest(String requestId, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('deposit_requests')
          .update({
        ...updates,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', requestId);
    } catch (e) {
      throw Exception('فشل في تحديث طلب الإيداع: ${e.toString()}');
    }
  }

  // ==== Admin Stats Methods ====
  Future<AdminStatsModel> getAdminStats() async {
    try {
      // استعلام إحصائيات المستخدمين
      final usersResponse = await _supabase
          .from('profiles')
          .select('id, is_active, is_verified, created_at');

      final totalUsers = usersResponse.length;
      final activeUsers = usersResponse.where((u) => u['is_active'] == true).length;
      final verifiedUsers = usersResponse.where((u) => u['is_verified'] == true).length;

      // استعلام إحصائيات الخدمات
      final servicesResponse = await _supabase
          .from('services')
          .select('id, status, created_at');

      final totalServices = servicesResponse.length;
      final activeServices = servicesResponse.where((s) => s['status'] == 'active').length;
      final pendingServices = servicesResponse.where((s) => s['status'] == 'pending').length;

      // استعلام إحصائيات الحجوزات
      final bookingsResponse = await _supabase
          .from('bookings')
          .select('id, status, created_at');

      final totalBookings = bookingsResponse.length;
      final completedBookings = bookingsResponse.where((b) => b['status'] == 'completed').length;
      final pendingBookings = bookingsResponse.where((b) => b['status'] == 'pending').length;

      // استعلام إحصائيات طلبات الإيداع
      final depositRequestsResponse = await _supabase
          .from('deposit_requests')
          .select('id, status, amount');

      final totalDepositRequests = depositRequestsResponse.length;
      final pendingDepositRequests = depositRequestsResponse.where((d) => d['status'] == 'pending').length;
      final totalDepositAmount = depositRequestsResponse
          .where((d) => d['status'] == 'approved')
          .fold<double>(0.0, (sum, d) => sum + (d['amount'] as num).toDouble());

      return AdminStatsModel(
        totalUsers: totalUsers,
        activeUsers: activeUsers,
        verifiedUsers: verifiedUsers,
        totalServices: totalServices,
        activeServices: activeServices,
        pendingServices: pendingServices,
        totalBookings: totalBookings,
        completedBookings: completedBookings,
        pendingBookings: pendingBookings,
        totalDepositRequests: totalDepositRequests,
        pendingDepositRequests: pendingDepositRequests,
        totalDepositAmount: totalDepositAmount,
        totalRevenue: totalDepositAmount * 0.05, // 5% عمولة
      );
    } catch (e) {
      throw Exception('فشل في تحميل إحصائيات الإدارة: ${e.toString()}');
    }
  }

  // ==== User Management Methods ====
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('*')
          .order('created_at', ascending: false);

      return (response as List).map<UserModel>((json) {
        return UserModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('فشل في تحميل المستخدمين: ${e.toString()}');
    }
  }

  Future<void> banUser(String userId) async {
    try {
      await _supabase
          .from('profiles')
          .update({
        'is_active': false,
        'ban_reason': 'تم حظره من قبل الإدارة',
        'banned_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);
    } catch (e) {
      throw Exception('فشل في حظر المستخدم: ${e.toString()}');
    }
  }

  Future<void> unbanUser(String userId) async {
    try {
      await _supabase
          .from('profiles')
          .update({
        'is_active': true,
        'ban_reason': null,
        'banned_at': null,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);
    } catch (e) {
      throw Exception('فشل في إلغاء حظر المستخدم: ${e.toString()}');
    }
  }

  Future<void> verifyUser(String userId) async {
    try {
      await _supabase
          .from('profiles')
          .update({
        'is_verified': true,
        'verified_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);
    } catch (e) {
      throw Exception('فشل في توثيق المستخدم: ${e.toString()}');
    }
  }

  // ==== Service Management Methods ====
  Future<List<ServiceModel>> getAllServices() async {
    try {
      final response = await _supabase
          .from('services')
          .select('''
            *,
            profiles:provider_id (
              full_name,
              email,
              avatar_url
            )
          ''')
          .order('created_at', ascending: false);

      return (response as List).map<ServiceModel>((json) {
        return ServiceModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('فشل في تحميل الخدمات: ${e.toString()}');
    }
  }

  Future<void> approveService(String serviceId) async {
    try {
      await _supabase
          .from('services')
          .update({
        'status': 'active',
        'approved_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', serviceId);
    } catch (e) {
      throw Exception('فشل في قبول الخدمة: ${e.toString()}');
    }
  }

  Future<void> rejectService(String serviceId, String reason) async {
    try {
      await _supabase
          .from('services')
          .update({
        'status': 'rejected',
        'rejection_reason': reason,
        'rejected_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', serviceId);
    } catch (e) {
      throw Exception('فشل في رفض الخدمة: ${e.toString()}');
    }
  }

  // ==== Booking Management Methods ====
  Future<List<BookingModel>> getAllBookings() async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('''
            *,
            client:client_id (
              full_name,
              email,
              avatar_url
            ),
            provider:provider_id (
              full_name,
              email,
              avatar_url
            ),
            service:service_id (
              title,
              price
            )
          ''')
          .order('created_at', ascending: false);

      return (response as List).map<BookingModel>((json) {
        return BookingModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('فشل في تحميل الحجوزات: ${e.toString()}');
    }
  }

  // ==== Additional Helper Methods ====
  Future<Map<String, int>> getDepositRequestsStats() async {
    try {
      final requests = await getDepositRequests();
      return {
        'total': requests.length,
        'pending': requests.where((r) => r.isPending).length,
        'approved': requests.where((r) => r.isApproved).length,
        'rejected': requests.where((r) => r.isRejected).length,
      };
    } catch (e) {
      throw Exception('فشل في الحصول على إحصائيات طلبات الإيداع: ${e.toString()}');
    }
  }

  Future<List<DepositRequestModel>> searchDepositRequests(String query) async {
    try {
      final response = await _supabase
          .from('deposit_requests')
          .select('''
            *,
            profiles:user_id (
              full_name,
              email,
              avatar_url
            )
          ''')
          .or('transaction_reference.ilike.%$query%,notes.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List).map<DepositRequestModel>((json) {
        final profile = json['profiles'] as Map<String, dynamic>?;

        return DepositRequestModel.fromJson({
          ...json,
          'userName': profile?['full_name'],
          'userEmail': profile?['email'],
          'userAvatarUrl': profile?['avatar_url'],
        });
      }).toList();
    } catch (e) {
      throw Exception('فشل في البحث عن طلبات الإيداع: ${e.toString()}');
    }
  }

  Future<DepositRequestModel> getDepositRequestById(String requestId) async {
    try {
      final response = await _supabase
          .from('deposit_requests')
          .select('''
            *,
            profiles:user_id (
              full_name,
              email,
              avatar_url
            )
          ''')
          .eq('id', requestId)
          .single();

      final profile = response['profiles'] as Map<String, dynamic>?;

      return DepositRequestModel.fromJson({
        ...response,
        'userName': profile?['full_name'],
        'userEmail': profile?['email'],
        'userAvatarUrl': profile?['avatar_url'],
      });
    } catch (e) {
      throw Exception('فشل في تحميل طلب الإيداع: ${e.toString()}');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _supabase
          .from('profiles')
          .delete()
          .eq('id', userId);
    } catch (e) {
      throw Exception('فشل في حذف المستخدم: ${e.toString()}');
    }
  }

  Future<void> suspendService(String serviceId) async {
    try {
      await _supabase
          .from('services')
          .update({
        'status': 'suspended',
        'suspended_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', serviceId);
    } catch (e) {
      throw Exception('فشل في تعليق الخدمة: ${e.toString()}');
    }
  }

  Future<void> cancelBooking(String bookingId, String reason) async {
    try {
      await _supabase
          .from('bookings')
          .update({
        'status': 'cancelled',
        'cancellation_reason': reason,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', bookingId);
    } catch (e) {
      throw Exception('فشل في إلغاء الحجز: ${e.toString()}');
    }
  }
}