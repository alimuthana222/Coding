import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/moderator_stats_model.dart';
import '../models/report_model.dart';
import '../models/moderator_action_model.dart';

class ModeratorService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ModeratorStatsModel> getModeratorStats() async {
    try {
      // حساب البلاغات المعلقة
      final pendingReportsResponse = await _supabase
          .from('reports')
          .select('id')
          .eq('status', 'pending');
      final pendingReports = pendingReportsResponse.length;

      // حساب المحتوى للمراجعة (يمكن تخصيصه حسب نوع المحتوى)
      final contentForReview = pendingReports; // مؤقتاً

      // حساب الإجراءات اليوم
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final todayActionsResponse = await _supabase
          .from('moderator_actions')
          .select('id')
          .gte('created_at', startOfDay.toIso8601String());
      final todayActions = todayActionsResponse.length;

      // حساب المستخدمين المحظورين
      final bannedUsersResponse = await _supabase
          .from('profiles')
          .select('id')
          .eq('is_active', false);
      final bannedUsers = bannedUsersResponse.length;

      // حساب إجمالي البلاغات
      final totalReportsResponse = await _supabase
          .from('reports')
          .select('id');
      final totalReports = totalReportsResponse.length;

      // حساب البلاغات المحلولة
      final resolvedReportsResponse = await _supabase
          .from('reports')
          .select('id')
          .eq('status', 'resolved');
      final resolvedReports = resolvedReportsResponse.length;

      return ModeratorStatsModel(
        pendingReports: pendingReports,
        contentForReview: contentForReview,
        todayActions: todayActions,
        bannedUsers: bannedUsers,
        totalReports: totalReports,
        resolvedReports: resolvedReports,
        rejectedContent: 0, // يمكن حسابه من جدول منفصل
        approvedContent: 0, // يمكن حسابه من جدول منفصل
        responseTime: 2.5, // متوسط وقت الاستجابة بالساعات
        activeWarnings: 0, // يمكن حسابه من جدول التحذيرات
      );
    } catch (e) {
      print('Error in getModeratorStats: $e');
      return const ModeratorStatsModel();
    }
  }

  Future<List<ReportModel>> getAllReports() async {
    try {
      final response = await _supabase
          .from('reports')
          .select('''
            *,
            reporter:reporter_id (
              full_name,
              avatar_url
            ),
            reported_user:reported_user_id (
              full_name,
              avatar_url
            ),
            moderator:moderator_id (
              full_name
            )
          ''')
          .order('created_at', ascending: false);

      return (response as List).map<ReportModel>((json) {
        return ReportModel.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error in getAllReports: $e');
      return <ReportModel>[];
    }
  }

  Future<List<ReportModel>> getPendingReports() async {
    try {
      final response = await _supabase
          .from('reports')
          .select('''
            *,
            reporter:reporter_id (
              full_name,
              avatar_url
            ),
            reported_user:reported_user_id (
              full_name,
              avatar_url
            )
          ''')
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return (response as List).map<ReportModel>((json) {
        return ReportModel.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error in getPendingReports: $e');
      return <ReportModel>[];
    }
  }

  Future<List<ModeratorActionModel>> getRecentActions({int limit = 20}) async {
    try {
      final response = await _supabase
          .from('moderator_actions')
          .select('''
            *,
            moderator:moderator_id (
              full_name
            )
          ''')
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map<ModeratorActionModel>((json) {
        return ModeratorActionModel.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error in getRecentActions: $e');
      return <ModeratorActionModel>[];
    }
  }

  Future<void> resolveReport(String reportId, String resolution, String actionTaken) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    try {
      await _supabase
          .from('reports')
          .update({
        'status': 'resolved',
        'resolution': resolution,
        'action_taken': actionTaken,
        'moderator_id': currentUser.id,
        'resolved_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', reportId);

      // تسجيل الإجراء
      await _logAction(
        actionType: 'resolve_report',
        targetType: 'report',
        targetId: reportId,
        reason: resolution,
        details: actionTaken,
      );
    } catch (e) {
      throw Exception('فشل في حل البلاغ: ${e.toString()}');
    }
  }

  Future<void> rejectReport(String reportId, String reason) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    try {
      await _supabase
          .from('reports')
          .update({
        'status': 'rejected',
        'resolution': reason,
        'moderator_id': currentUser.id,
        'resolved_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', reportId);

      // تسجيل الإجراء
      await _logAction(
        actionType: 'reject_report',
        targetType: 'report',
        targetId: reportId,
        reason: reason,
      );
    } catch (e) {
      throw Exception('فشل في رفض البلاغ: ${e.toString()}');
    }
  }

  Future<void> banUser(String userId, String reason, {Duration? duration}) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    try {
      final banData = {
        'is_active': false,
        'ban_reason': reason,
        'banned_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (duration != null) {
        banData['ban_expires_at'] = DateTime.now().add(duration).toIso8601String();
      }

      await _supabase
          .from('profiles')
          .update(banData)
          .eq('id', userId);

      // تسجيل الإجراء
      await _logAction(
        actionType: 'ban_user',
        targetType: 'user',
        targetId: userId,
        reason: reason,
        details: duration != null ? 'مدة الحظر: ${duration.inDays} أيام' : 'حظر دائم',
      );
    } catch (e) {
      throw Exception('فشل في حظر المستخدم: ${e.toString()}');
    }
  }

  Future<void> warnUser(String userId, String reason) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    try {
      // إضافة تحذير في جدول التحذيرات (إذا كان موجوداً)
      await _supabase
          .from('user_warnings')
          .insert({
        'user_id': userId,
        'moderator_id': currentUser.id,
        'reason': reason,
        'created_at': DateTime.now().toIso8601String(),
      });

      // تسجيل الإجراء
      await _logAction(
        actionType: 'warn_user',
        targetType: 'user',
        targetId: userId,
        reason: reason,
      );
    } catch (e) {
      throw Exception('فشل في تحذير المستخدم: ${e.toString()}');
    }
  }

  Future<void> deleteContent(String contentId, String contentType, String reason) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    try {
      String tableName;
      switch (contentType) {
        case 'post':
          tableName = 'posts';
          break;
        case 'comment':
          tableName = 'comments';
          break;
        case 'service':
          tableName = 'services';
          break;
        default:
          throw Exception('نوع محتوى غير مدعوم');
      }

      await _supabase
          .from(tableName)
          .delete()
          .eq('id', contentId);

      // تسجيل الإجراء
      await _logAction(
        actionType: 'delete_content',
        targetType: contentType,
        targetId: contentId,
        reason: reason,
      );
    } catch (e) {
      throw Exception('فشل في حذف المحتوى: ${e.toString()}');
    }
  }

  Future<void> _logAction({
    required String actionType,
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
    String? targetName,
  }) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    try {
      await _supabase
          .from('moderator_actions')
          .insert({
        'moderator_id': currentUser.id,
        'action_type': actionType,
        'target_type': targetType,
        'target_id': targetId,
        'target_name': targetName,
        'reason': reason,
        'details': details,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error logging moderator action: $e');
    }
  }
}