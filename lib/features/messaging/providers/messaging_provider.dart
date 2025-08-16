import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/messaging_service.dart';

final messagingServiceProvider = Provider<MessagingService>((ref) {
  return MessagingService();
});

final conversationsProvider = FutureProvider<List<ConversationModel>>((ref) async {
  final messagingService = ref.read(messagingServiceProvider);
  return messagingService.getConversations();
});

final messagesProvider = FutureProvider.family<List<MessageModel>, String>((ref, conversationId) async {
  final messagingService = ref.read(messagingServiceProvider);
  return messagingService.getMessages(conversationId);
});

final messagingNotifierProvider = StateNotifierProvider<MessagingNotifier, MessagingState>((ref) {
  return MessagingNotifier(ref.read(messagingServiceProvider));
});

class MessagingNotifier extends StateNotifier<MessagingState> {
  final MessagingService _messagingService;

  MessagingNotifier(this._messagingService) : super(const MessagingInitial());

  Future<void> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    state = const MessagingLoading();
    try {
      await _messagingService.sendMessage(
        conversationId: conversationId,
        content: content,
      );
      state = const MessagingSuccess('Message sent successfully');
    } catch (e) {
      state = MessagingError(e.toString());
    }
  }

  Future<String> createOrGetConversation(String otherUserId) async {
    state = const MessagingLoading();
    try {
      final conversationId = await _messagingService.createOrGetConversation(otherUserId);
      state = const MessagingSuccess('Conversation ready');
      return conversationId;
    } catch (e) {
      state = MessagingError(e.toString());
      rethrow;
    }
  }

  Future<void> markAsRead(String conversationId) async {
    try {
      await _messagingService.markAsRead(conversationId);
    } catch (e) {
      state = MessagingError(e.toString());
    }
  }
}

// Define the state classes
abstract class MessagingState {
  const MessagingState();
}

class MessagingInitial extends MessagingState {
  const MessagingInitial();
}

class MessagingLoading extends MessagingState {
  const MessagingLoading();
}

class MessagingSuccess extends MessagingState {
  final String message;
  const MessagingSuccess(this.message);
}

class MessagingError extends MessagingState {
  final String message;
  const MessagingError(this.message);
}