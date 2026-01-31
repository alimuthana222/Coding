import 'package:equatable/equatable.dart';
import '../../../core/models/message_model.dart';

enum MessagesStatus { initial, loading, loaded, error }

class MessagesState extends Equatable {
  final MessagesStatus status;
  final List<ConversationModel> conversations;
  final int unreadCount;
  final String? errorMessage;

  const MessagesState({
    this.status = MessagesStatus.initial,
    this.conversations = const [],
    this.unreadCount = 0,
    this.errorMessage,
  });

  MessagesState copyWith({
    MessagesStatus? status,
    List<ConversationModel>? conversations,
    int? unreadCount,
    String? errorMessage,
  }) {
    return MessagesState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, conversations, unreadCount, errorMessage];
}