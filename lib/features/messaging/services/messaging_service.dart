import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class MessagingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ConversationModel>> getConversations() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final response = await _supabase
          .from('conversations')
          .select('''
            *,
            participant1:participant1_id (
              full_name,
              avatar_url
            ),
            participant2:participant2_id (
              full_name,
              avatar_url
            )
          ''')
          .or('participant1_id.eq.${user.id},participant2_id.eq.${user.id}')
          .order('last_message_at', ascending: false);

      return response.map<ConversationModel>((json) {
        final participant1Data = json['participant1'] as Map<String, dynamic>?;
        final participant2Data = json['participant2'] as Map<String, dynamic>?;

        return ConversationModel.fromJson({
          ...json,
          'participant1_name': participant1Data?['full_name'],
          'participant1_avatar': participant1Data?['avatar_url'],
          'participant2_name': participant2Data?['full_name'],
          'participant2_avatar': participant2Data?['avatar_url'],
        });
      }).toList();
    } catch (e) {
      print('Error getting conversations: $e');
      return [];
    }
  }

  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select('''
            *,
            sender:sender_id (
              full_name,
              avatar_url
            )
          ''')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return response.map<MessageModel>((json) {
        final senderData = json['sender'] as Map<String, dynamic>?;

        return MessageModel.fromJson({
          ...json,
          'sender_name': senderData?['full_name'],
          'sender_avatar': senderData?['avatar_url'],
        });
      }).toList();
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  Future<void> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Insert message
      await _supabase.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': user.id,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update conversation last message
      await _supabase
          .from('conversations')
          .update({
        'last_message': content,
        'last_message_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', conversationId);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<String> createOrGetConversation(String otherUserId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Check if conversation already exists
      final existingConversation = await _supabase
          .from('conversations')
          .select('id')
          .or('and(participant1_id.eq.${user.id},participant2_id.eq.$otherUserId),and(participant1_id.eq.$otherUserId,participant2_id.eq.${user.id})')
          .maybeSingle();

      if (existingConversation != null) {
        return existingConversation['id'];
      }

      // Create new conversation
      final response = await _supabase
          .from('conversations')
          .insert({
        'participant1_id': user.id,
        'participant2_id': otherUserId,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      })
          .select('id')
          .single();

      return response['id'];
    } catch (e) {
      throw Exception('Failed to create conversation: $e');
    }
  }

  Future<void> markAsRead(String conversationId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .neq('sender_id', user.id);
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  Stream<List<MessageModel>> subscribeToMessages(String conversationId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .map((data) => data.map((json) => MessageModel.fromJson(json)).toList());
  }
}