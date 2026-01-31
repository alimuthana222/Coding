import 'package:equatable/equatable.dart';
import 'user_model.dart';

// ═══════════════════════════════════════════════════════════════════
// CONVERSATION MODEL
// ═══════════════════════════════════════════════════════════════════

class ConversationModel extends Equatable {
  final String id;
  final String participant1;
  final String participant2;
  final String? lastMessageId;
  final DateTime lastMessageAt;
  final DateTime createdAt;

  // Relations
  final UserModel? otherUser;
  final MessageModel? lastMessage;
  final int unreadCount;

  const ConversationModel({
    required this.id,
    required this.participant1,
    required this.participant2,
    this.lastMessageId,
    required this.lastMessageAt,
    required this.createdAt,
    this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    final isParticipant1 = json['participant_1'] == currentUserId;

    return ConversationModel(
      id: json['id'] as String,
      participant1: json['participant_1'] as String,
      participant2: json['participant_2'] as String,
      lastMessageId: json['last_message_id'] as String?,
      lastMessageAt: DateTime.parse(json['last_message_at']),
      createdAt: DateTime.parse(json['created_at']),
      otherUser: json[isParticipant1 ? 'participant_2_profile' : 'participant_1_profile'] != null
          ? UserModel.fromJson(json[isParticipant1 ? 'participant_2_profile' : 'participant_1_profile'])
          : null,
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    id, participant1, participant2, lastMessageId, lastMessageAt, createdAt, unreadCount,
  ];
}

// ═══════════════════════════════════════════════════════════════════
// MESSAGE MODEL
// ════════════════════════════════════════════��══════════════════════

class MessageModel extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String messageType;
  final String? attachmentUrl;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  // Relations
  final UserModel? sender;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.messageType = 'text',
    this.attachmentUrl,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
    this.sender,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      messageType: json['message_type'] as String? ?? 'text',
      attachmentUrl: json['attachment_url'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      sender: json['profiles'] != null ? UserModel.fromJson(json['profiles']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType,
      'attachment_url': attachmentUrl,
    };
  }

  @override
  List<Object?> get props => [
    id, conversationId, senderId, content, messageType, attachmentUrl, isRead, readAt, createdAt,
  ];
}