import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/repositories/message_repository.dart';
import '../../../core/config/supabase_config.dart';
import 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  final MessageRepository _messageRepository = sl<MessageRepository>();

  MessagesCubit() : super(const MessagesState()) {
    loadConversations();
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAD CONVERSATIONS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> loadConversations() async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) {
      emit(state.copyWith(status: MessagesStatus.loaded));
      return;
    }

    emit(state.copyWith(status: MessagesStatus.loading));

    try {
      final conversations = await _messageRepository.getConversations(userId);
      final unreadCount = await _messageRepository.getUnreadCount(userId);

      emit(state.copyWith(
        status: MessagesStatus.loaded,
        conversations: conversations,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MessagesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET UNREAD COUNT
  // ═══════════════════════════════════════════════════════════════════

  Future<void> refreshUnreadCount() async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) return;

    try {
      final unreadCount = await _messageRepository.getUnreadCount(userId);
      emit(state.copyWith(unreadCount: unreadCount));
    } catch (e) {
      // Silent fail
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // REFRESH
  // ═══════════════════════════════════════════════════════════════════

  Future<void> refresh() async {
    await loadConversations();
  }
}