class ReportModel {
  final String id;
  final String reporterId;
  final String? reporterName;
  final String? reporterAvatarUrl;
  final String reportedUserId;
  final String? reportedUserName;
  final String? reportedUserAvatarUrl;
  final String? contentId;
  final String contentType; // post, comment, service, user
  final String reason;
  final String? description;
  final String status; // pending, reviewing, resolved, rejected
  final String? moderatorId;
  final String? moderatorName;
  final String? resolution;
  final String? actionTaken;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final Map<String, dynamic>? metadata;

  const ReportModel({
    required this.id,
    required this.reporterId,
    this.reporterName,
    this.reporterAvatarUrl,
    required this.reportedUserId,
    this.reportedUserName,
    this.reportedUserAvatarUrl,
    this.contentId,
    required this.contentType,
    required this.reason,
    this.description,
    this.status = 'pending',
    this.moderatorId,
    this.moderatorName,
    this.resolution,
    this.actionTaken,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.metadata,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    final reporter = json['reporter'] as Map<String, dynamic>?;
    final reportedUser = json['reported_user'] as Map<String, dynamic>?;
    final moderator = json['moderator'] as Map<String, dynamic>?;

    return ReportModel(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String,
      reporterName: reporter?['full_name'] as String?,
      reporterAvatarUrl: reporter?['avatar_url'] as String?,
      reportedUserId: json['reported_user_id'] as String,
      reportedUserName: reportedUser?['full_name'] as String?,
      reportedUserAvatarUrl: reportedUser?['avatar_url'] as String?,
      contentId: json['content_id'] as String?,
      contentType: json['content_type'] as String,
      reason: json['reason'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'pending',
      moderatorId: json['moderator_id'] as String?,
      moderatorName: moderator?['full_name'] as String?,
      resolution: json['resolution'] as String?,
      actionTaken: json['action_taken'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'reported_user_id': reportedUserId,
      'content_id': contentId,
      'content_type': contentType,
      'reason': reason,
      'description': description,
      'status': status,
      'moderator_id': moderatorId,
      'resolution': resolution,
      'action_taken': actionTaken,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'معلق';
      case 'reviewing':
        return 'قيد المراجعة';
      case 'resolved':
        return 'تم الحل';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  String get reasonDisplayName {
    switch (reason) {
      case 'spam':
        return 'رسائل مزعجة';
      case 'harassment':
        return 'مضايقة';
      case 'inappropriate_content':
        return 'محتوى غير مناسب';
      case 'fake_profile':
        return 'حساب وهمي';
      case 'violence':
        return 'عنف';
      case 'hate_speech':
        return 'خطاب كراهية';
      case 'scam':
        return 'احتيال';
      case 'other':
        return 'أخرى';
      default:
        return reason;
    }
  }

  String get contentTypeDisplayName {
    switch (contentType) {
      case 'post':
        return 'منشور';
      case 'comment':
        return 'تعليق';
      case 'service':
        return 'خدمة';
      case 'user':
        return 'مستخدم';
      case 'event':
        return 'فعالية';
      default:
        return contentType;
    }
  }

  bool get isPending => status == 'pending';
  bool get isResolving => status == 'reviewing';
  bool get isResolved => status == 'resolved';
  bool get isRejected => status == 'rejected';

  Duration get timeElapsed => DateTime.now().difference(createdAt);

  String get timeAgo {
    final duration = timeElapsed;
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