class ModeratorStatsModel {
  final int pendingReports;
  final int contentForReview;
  final int todayActions;
  final int bannedUsers;
  final int totalReports;
  final int resolvedReports;
  final int rejectedContent;
  final int approvedContent;
  final double responseTime;
  final int activeWarnings;

  const ModeratorStatsModel({
    this.pendingReports = 0,
    this.contentForReview = 0,
    this.todayActions = 0,
    this.bannedUsers = 0,
    this.totalReports = 0,
    this.resolvedReports = 0,
    this.rejectedContent = 0,
    this.approvedContent = 0,
    this.responseTime = 0.0,
    this.activeWarnings = 0,
  });

  factory ModeratorStatsModel.fromJson(Map<String, dynamic> json) {
    return ModeratorStatsModel(
      pendingReports: json['pending_reports'] as int? ?? 0,
      contentForReview: json['content_for_review'] as int? ?? 0,
      todayActions: json['today_actions'] as int? ?? 0,
      bannedUsers: json['banned_users'] as int? ?? 0,
      totalReports: json['total_reports'] as int? ?? 0,
      resolvedReports: json['resolved_reports'] as int? ?? 0,
      rejectedContent: json['rejected_content'] as int? ?? 0,
      approvedContent: json['approved_content'] as int? ?? 0,
      responseTime: (json['response_time'] as num?)?.toDouble() ?? 0.0,
      activeWarnings: json['active_warnings'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pending_reports': pendingReports,
      'content_for_review': contentForReview,
      'today_actions': todayActions,
      'banned_users': bannedUsers,
      'total_reports': totalReports,
      'resolved_reports': resolvedReports,
      'rejected_content': rejectedContent,
      'approved_content': approvedContent,
      'response_time': responseTime,
      'active_warnings': activeWarnings,
    };
  }

  ModeratorStatsModel copyWith({
    int? pendingReports,
    int? contentForReview,
    int? todayActions,
    int? bannedUsers,
    int? totalReports,
    int? resolvedReports,
    int? rejectedContent,
    int? approvedContent,
    double? responseTime,
    int? activeWarnings,
  }) {
    return ModeratorStatsModel(
      pendingReports: pendingReports ?? this.pendingReports,
      contentForReview: contentForReview ?? this.contentForReview,
      todayActions: todayActions ?? this.todayActions,
      bannedUsers: bannedUsers ?? this.bannedUsers,
      totalReports: totalReports ?? this.totalReports,
      resolvedReports: resolvedReports ?? this.resolvedReports,
      rejectedContent: rejectedContent ?? this.rejectedContent,
      approvedContent: approvedContent ?? this.approvedContent,
      responseTime: responseTime ?? this.responseTime,
      activeWarnings: activeWarnings ?? this.activeWarnings,
    );
  }

  // Helper getters
  double get resolutionRate {
    if (totalReports == 0) return 0.0;
    return (resolvedReports / totalReports) * 100;
  }

  double get contentApprovalRate {
    final totalContentReviewed = approvedContent + rejectedContent;
    if (totalContentReviewed == 0) return 0.0;
    return (approvedContent / totalContentReviewed) * 100;
  }

  String get responseTimeFormatted {
    if (responseTime < 1) {
      return '${(responseTime * 60).toInt()} دقيقة';
    } else if (responseTime < 24) {
      return '${responseTime.toStringAsFixed(1)} ساعة';
    } else {
      return '${(responseTime / 24).toStringAsFixed(1)} يوم';
    }
  }
}