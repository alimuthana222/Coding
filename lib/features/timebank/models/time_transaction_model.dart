enum TimeTransactionType {
  earned,
  spent,
  transferred,
  received,
}

class TimeTransactionModel {
  final String id;
  final String userId;
  final TimeTransactionType type;
  final int hours;
  final String description;
  final String? serviceId;
  final String? fromUserId;
  final String? toUserId;
  final DateTime createdAt;

  const TimeTransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.hours,
    required this.description,
    this.serviceId,
    this.fromUserId,
    this.toUserId,
    required this.createdAt,
  });

  factory TimeTransactionModel.fromJson(Map<String, dynamic> json) {
    return TimeTransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: _parseTimeTransactionType(json['type'] as String),
      hours: json['hours'] as int,
      description: json['description'] as String,
      serviceId: json['service_id'] as String?,
      fromUserId: json['from_user_id'] as String?,
      toUserId: json['to_user_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': _timeTransactionTypeToString(type),
      'hours': hours,
      'description': description,
      'service_id': serviceId,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper methods for enum conversion
  static TimeTransactionType _parseTimeTransactionType(String value) {
    switch (value) {
      case 'earned':
        return TimeTransactionType.earned;
      case 'spent':
        return TimeTransactionType.spent;
      case 'transferred':
        return TimeTransactionType.transferred;
      case 'received':
        return TimeTransactionType.received;
      default:
        return TimeTransactionType.earned;
    }
  }

  static String _timeTransactionTypeToString(TimeTransactionType type) {
    switch (type) {
      case TimeTransactionType.earned:
        return 'earned';
      case TimeTransactionType.spent:
        return 'spent';
      case TimeTransactionType.transferred:
        return 'transferred';
      case TimeTransactionType.received:
        return 'received';
    }
  }
}