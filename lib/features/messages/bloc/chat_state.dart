import 'package:equatable/equatable.dart';
import '../../../core/models/message_model.dart';
import '../../../core/models/user_model.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final ConversationModel? conversation;
  final List<MessageModel> messages;
  final UserModel? otherUser;
  final String? errorMessage;
  final bool isSending;

  const ChatState({
    this.status = ChatStatus.initial,
    this.conversation,
    this.messages = const [],
    this.otherUser,
    this.errorMessage,
    this.isSending = false,
  });

  ChatState copyWith({
    ChatStatus? status,
    ConversationModel? conversation,
    List<MessageModel>? messages,
    UserModel? otherUser,
    String? errorMessage,
    bool? isSending,
  }) {
    return ChatState(
      status: status ?? this.status,
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      otherUser: otherUser ?? this.otherUser,
      errorMessage: errorMessage ?? this.errorMessage,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [status, conversation, messages, otherUser, errorMessage, isSending];
}