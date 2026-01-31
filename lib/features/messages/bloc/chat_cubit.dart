import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/di/injection.dart';
import '../../../core/repositories/message_repository.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/models/message_model.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final MessageRepository _messageRepository = sl<MessageRepository>();
  final String otherUserId;
  RealtimeChannel? _subscription;

  ChatCubit({required this.otherUserId}) : super(const ChatState()) {
    _initChat();
  }

  // ═══════════════════════════════════════════════════════════════════
  // INITIALIZE CHAT
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _initChat() async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) return;

    emit(state.copyWith(status: ChatStatus.loading));

    try {
      // Get or create conversation
      final conversation = await _messageRepository.getOrCreateConversation(
        userId,
        otherUserId,
      );

      // Load messages
      final messages = await _messageRepository.getMessages(conversation.id);

      // Mark as read
      await _messageRepository.markAsRead(conversation.id, userId);

      emit(state.copyWith(
        status: ChatStatus.loaded,
        conversation: conversation,
        messages: messages,
        otherUser: conversation.otherUser,
      ));

      // Subscribe to new messages
      _subscribeToMessages(conversation.id);
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // SUBSCRIBE TO MESSAGES (REALTIME)
  // ═══════════════════════════════════════════════════════════════════

  void _subscribeToMessages(String conversationId) {
    _subscription = _messageRepository.subscribeToMessages(
      conversationId,
          (message) {
        // Add new message to list
        final updatedMessages = [message, ...state.messages];
        emit(state.copyWith(messages: updatedMessages));

        // Mark as read if not sent by current user
        final userId = SupabaseConfig.currentUserId;
        if (userId != null && message.senderId != userId) {
          _messageRepository.markAsRead(conversationId, userId);
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SEND MESSAGE
  // ═══════════════════════════════════════════════════════════════════

  Future<void> sendMessage(String content) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null || state.conversation == null || content.trim().isEmpty) return;

    emit(state.copyWith(isSending: true));

    try {
      final message = MessageModel(
        id: '',
        conversationId: state.conversation!.id,
        senderId: userId,
        content: content.trim(),
        createdAt: DateTime.now(),
      );

      await _messageRepository.sendMessage(message);

      emit(state.copyWith(isSending: false));
    } catch (e) {
      emit(state.copyWith(
        isSending: false,
        errorMessage: e.toString(),
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAD MORE MESSAGES
  // ═══════════════════════════════════════════════════════════════════

  Future<void> loadMoreMessages() async {
    if (state.conversation == null) return;

    try {
      final page = (state.messages.length ~/ 50) + 1;
      final moreMessages = await _messageRepository.getMessages(
        state.conversation!.id,
        page: page,
      );

      if (moreMessages.isNotEmpty) {
        emit(state.copyWith(messages: [...state.messages, ...moreMessages]));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // DISPOSE
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<void> close() {
    _subscription?.unsubscribe();
    return super.close();
  }
}