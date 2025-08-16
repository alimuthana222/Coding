class ModeratorActionModel {
  final String id;
  final String moderatorId;
  final String? moderatorName;
  final String actionType; // ban_user, approve_content, reject_content, resolve_report
  final String targetType; // user, post, comment, service, report
  final String targetId;
  final String? targetName;
  final String reason;
  final String? details;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const ModeratorActionModel({
    required this.id,
    required this.moderatorId,
    this.moderatorName,
    required this.actionType,
    required this.targetType,
    required this.targetId,
    this.targetName,
    required this.reason,
    this.details,
    this.metadata,
    required this.createdAt,
  });

  factory ModeratorActionModel.fromJson(Map<String, dynamic> json) {
    final moderator = json['moderator'] as Map<String, dynamic>?;

    return ModeratorActionModel(
      id: json['id'] as String,
      moderatorId: json['moderator_id'] as String,
      moderatorName: moderator?['full_name'] as String?,
      actionType: json['action_type'] as String,
      targetType: json['target_type'] as String,
      targetId: json['target_id'] as String,
      targetName: json['target_name'] as String?,
      reason: json['reason'] as String,
      details: json['details'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moderator_id': moderatorId,
      'action_type': actionType,
      'target_type': targetType,
      'target_id': targetId,
      'target_name': targetName,
      'reason': reason,
      'details': details,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get actionTypeDisplayName {
    switch (actionType) {
      case 'ban_user':
        return 'حظر مستخدم';
      case 'unban_user':
        return 'إلغاء حظر مستخدم';
      case 'approve_content':
        return 'موافقة على محتوى';
      case 'reject_content':
        return 'رفض محتوى';
      case 'resolve_report':
        return 'حل بلاغ';
      case 'reject_report':
        return 'رفض بلاغ';
      case 'warn_user':
        return 'تحذير مستخدم';
      case 'delete_content':
        return 'حذف محتوى';
      default:
        return actionType;
    }
  }

  String get targetTypeDisplayName {
    switch (targetType) {
      case 'user':
        return 'مستخدم';
      case 'post':
        return 'منشور';
      case 'comment':
        return 'تعليق';
      case 'service':
        return 'خدمة';
      case 'report':
        return 'بلاغ';
      case 'event':
        return 'فعالية';
      default:
        return targetType;
    }
  }

  String get timeAgo {
    final duration = DateTime.now().difference(createdAt);
    if (duration.inDays > 0) {
      return 'منذ ${duration.inDays} ${duration.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (duration.inHours > 0) {
      return 'منذ ${duration.inHours} ${duration.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (duration.inMinutes > 0) {
      return 'منذ ${duration.inMinutes} ${duration.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }
}