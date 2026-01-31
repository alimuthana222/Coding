import '../config/supabase_config.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final _client = SupabaseConfig.client;

  // ═══════════════════════════════════════════════════════════════════
  // GET NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<NotificationModel>> getNotifications(
      String userId, {
        int page = 1,
        int limit = 20,
      }) async {
    final response = await _client
        .from(SupabaseConfig.notificationsTable)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range((page - 1) * limit, page * limit - 1);

    return (response as List).map((e) => NotificationModel.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET UNREAD COUNT
  // ═══════════════════════════════════════════════════════════════════

  Future<int> getUnreadCount(String userId) async {
    final response = await _client
        .from(SupabaseConfig.notificationsTable)
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);

    return (response as List).length;
  }

  // ═══════════════════════════════════════════════════════════════════
  // MARK AS READ
  // ═══════════════════════════════════════════════════════════════════

  Future<void> markAsRead(String notificationId) async {
    await _client.from(SupabaseConfig.notificationsTable).update({
      'is_read': true,
      'read_at': DateTime.now().toIso8601String(),
    }).eq('id', notificationId);
  }

  // ═══════════════════════════════════════════════════════════════════
  // MARK ALL AS READ
  // ═══════════════════════════════════════════════════════════════════

  Future<void> markAllAsRead(String userId) async {
    await _client.from(SupabaseConfig.notificationsTable).update({
      'is_read': true,
      'read_at': DateTime.now().toIso8601String(),
    }).eq('user_id', userId).eq('is_read', false);
  }

  // ═══════════════════════════════════════════════════════════════════
  // DELETE NOTIFICATION
  // ═══════════════════════════════════════════════════════════════════

  Future<void> deleteNotification(String notificationId) async {
    await _client
        .from(SupabaseConfig.notificationsTable)
        .delete()
        .eq('id', notificationId);
  }

  // ═══════════════════════════════════════════════════════════════════
  // DELETE ALL NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> deleteAllNotifications(String userId) async {
    await _client
        .from(SupabaseConfig.notificationsTable)
        .delete()
        .eq('user_id', userId);
  }
}