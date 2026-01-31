import 'package:equatable/equatable.dart';

enum NotificationType {
  bookingRequest,
  bookingConfirmed,
  bookingCancelled,
  bookingCompleted,
  newMessage,
  newFollower,
  postLike,
  postComment,
  eventReminder,
  walletUpdate,
  system,
}

class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final NotificationType type;
  final String titleAr;
  final String? titleEn;
  final String? bodyAr;
  final String? bodyEn;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.titleAr,
    this.titleEn,
    this.bodyAr,
    this.bodyEn,
    this.data = const {},
    this.isRead = false,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: NotificationType.values.firstWhere(
            (e) => e.name == _snakeToCamel(json['type'] as String),
        orElse: () => NotificationType.system,
      ),
      titleAr: json['title_ar'] as String,
      titleEn: json['title_en'] as String?,
      bodyAr: json['body_ar'] as String?,
      bodyEn: json['body_en'] as String?,
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String getTitle(bool isArabic) => isArabic ? titleAr : (titleEn ?? titleAr);
  String? getBody(bool isArabic) => isArabic ? bodyAr : (bodyEn ?? bodyAr);

  static String _snakeToCamel(String text) {
    return text.replaceAllMapped(
      RegExp(r'_([a-z])'),
          (match) => match.group(1)!.toUpperCase(),
    );
  }

  @override
  List<Object?> get props => [
    id, userId, type, titleAr, titleEn, bodyAr, bodyEn, data, isRead, readAt, createdAt,
  ];
}