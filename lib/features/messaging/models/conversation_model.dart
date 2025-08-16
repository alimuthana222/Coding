class ConversationModel {
  final String id;
  final String participant1Id;
  final String participant2Id;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Participant info (joined)
  final String? participant1Name;
  final String? participant1Avatar;
  final String? participant2Name;
  final String? participant2Avatar;

  const ConversationModel({
    required this.id,
    required this.participant1Id,
    required this.participant2Id,
    this.lastMessage,
    this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
    this.participant1Name,
    this.participant1Avatar,
    this.participant2Name,
    this.participant2Avatar,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      participant1Id: json['participant1_id'] as String,
      participant2Id: json['participant2_id'] as String,
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      participant1Name: json['participant1_name'] as String?,
      participant1Avatar: json['participant1_avatar'] as String?,
      participant2Name: json['participant2_name'] as String?,
      participant2Avatar: json['participant2_avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant1_id': participant1Id,
      'participant2_id': participant2Id,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'participant1_name': participant1Name,
      'participant1_avatar': participant1Avatar,
      'participant2_name': participant2Name,
      'participant2_avatar': participant2Avatar,
    };
  }
}