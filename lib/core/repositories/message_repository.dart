import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/message_model.dart';

class MessageRepository {
  final _client = SupabaseConfig.client;

  // ═══════════════════════════════════════════════════════════════════
  // GET CONVERSATIONS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<ConversationModel>> getConversations(String userId) async {
    final response = await _client
        .from(SupabaseConfig.conversationsTable)
        .select('''
          *,
          participant_1_profile:profiles!conversations_participant_1_fkey(*),
          participant_2_profile:profiles!conversations_participant_2_fkey(*)
        ''')
        .or('participant_1.eq.$userId,participant_2.eq.$userId')
        .order('last_message_at', ascending: false);

    return (response as List)
        .map((e) => ConversationModel.fromJson(e, userId))
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET OR CREATE CONVERSATION
  // ═══════════════════════════════════════════════════════════════════

  Future<ConversationModel> getOrCreateConversation(
      String currentUserId,
      String otherUserId,
      ) async {
    // Check existing conversation
    final existing = await _client
        .from(SupabaseConfig.conversationsTable)
        .select('''
          *,
          participant_1_profile:profiles!conversations_participant_1_fkey(*),
          participant_2_profile:profiles!conversations_participant_2_fkey(*)
        ''')
        .or('and(participant_1.eq.$currentUserId,participant_2.eq.$otherUserId),and(participant_1.eq.$otherUserId,participant_2.eq.$currentUserId)')
        .maybeSingle();

    if (existing != null) {
      return ConversationModel.fromJson(existing, currentUserId);
    }

    // Create new conversation
    final response = await _client
        .from(SupabaseConfig.conversationsTable)
        .insert({
      'participant_1': currentUserId,
      'participant_2': otherUserId,
    })
        .select('''
          *,
          participant_1_profile:profiles!conversations_participant_1_fkey(*),
          participant_2_profile:profiles!conversations_participant_2_fkey(*)
        ''')
        .single();

    return ConversationModel.fromJson(response, currentUserId);
  }

  // ═══════════════════════════════════════════���═══════════════════════
  // GET MESSAGES
  // ═══════════════════════════════════════════════════════════════════

  Future<List<MessageModel>> getMessages(
      String conversationId, {
        int page = 1,
        int limit = 50,
      }) async {
    final response = await _client
        .from(SupabaseConfig.messagesTable)
        .select('*, profiles(*)')
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: false)
        .range((page - 1) * limit, page * limit - 1);

    return (response as List).map((e) => MessageModel.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // SEND MESSAGE
  // ═══════════════════════════════════════════════════════════════════

  Future<MessageModel> sendMessage(MessageModel message) async {
    final response = await _client
        .from(SupabaseConfig.messagesTable)
        .insert(message.toJson())
        .select('*, profiles(*)')
        .single();

    // Update conversation last message
    await _client.from(SupabaseConfig.conversationsTable).update({
      'last_message_id': response['id'],
      'last_message_at': DateTime.now().toIso8601String(),
    }).eq('id', message.conversationId);

    return MessageModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // MARK AS READ
  // ═══════════════════════════════════════════════════════════════════

  Future<void> markAsRead(String conversationId, String userId) async {
    await _client
        .from(SupabaseConfig.messagesTable)
        .update({
      'is_read': true,
      'read_at': DateTime.now().toIso8601String(),
    })
        .eq('conversation_id', conversationId)
        .neq('sender_id', userId)
        .eq('is_read', false);
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET UNREAD COUNT
  // ═══════════════════════════════════════════════════════════════════

  Future<int> getUnreadCount(String userId) async {
    final response = await _client
        .from(SupabaseConfig.messagesTable)
        .select('id')
        .neq('sender_id', userId)
        .eq('is_read', false);

    return (response as List).length;
  }

  // ═══════════════════════════════════════════════════════════════════
  // SUBSCRIBE TO MESSAGES (REALTIME)
  // ═══════════════════════════════════════════════════════════════════

  RealtimeChannel subscribeToMessages(
      String conversationId,
      void Function(MessageModel) onMessage,
      ) {
    return _client
        .channel('messages:$conversationId')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: SupabaseConfig.messagesTable,
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'conversation_id',
        value: conversationId,
      ),
      callback: (payload) {
        final message = MessageModel.fromJson(payload.newRecord);
        onMessage(message);
      },
    )
        .subscribe();
  }

  // ═══════════════════════════════════════════════════════════════════
  // DELETE MESSAGE
  // ═══════════════════════════════════════════════════════════════════

  Future<void> deleteMessage(String messageId) async {
    await _client
        .from(SupabaseConfig.messagesTable)
        .delete()
        .eq('id', messageId);
  }
}