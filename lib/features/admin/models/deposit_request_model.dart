class DepositRequestModel {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String? userAvatarUrl;
  final double amount;
  final String paymentMethod;
  final String? transactionReference;
  final String? receiptImageUrl;
  final String? notes;
  final String? adminNotes;
  final String status; // pending, approved, rejected
  final String? processedBy; // Admin user ID who processed the request
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? processedAt;
  final String? platformWalletNumber;
  final Map<String, dynamic>? metadata;

  const DepositRequestModel({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    this.userAvatarUrl,
    required this.amount,
    required this.paymentMethod,
    this.transactionReference,
    this.receiptImageUrl,
    this.notes,
    this.adminNotes,
    this.status = 'pending',
    this.processedBy,
    required this.createdAt,
    this.updatedAt,
    this.processedAt,
    this.platformWalletNumber,
    this.metadata,
  });

  // Factory constructor from JSON
  factory DepositRequestModel.fromJson(Map<String, dynamic> json) {
    return DepositRequestModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      transactionReference: json['transaction_reference'] as String?,
      receiptImageUrl: json['receipt_image_url'] as String?,
      notes: json['notes'] as String?,
      adminNotes: json['admin_notes'] as String?,
      status: json['status'] as String? ?? 'pending',
      processedBy: json['processed_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
      platformWalletNumber: json['platform_wallet_number'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userAvatarUrl': userAvatarUrl,
      'amount': amount,
      'payment_method': paymentMethod,
      'transaction_reference': transactionReference,
      'receipt_image_url': receiptImageUrl,
      'notes': notes,
      'admin_notes': adminNotes,
      'status': status,
      'processed_by': processedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
      'platform_wallet_number': platformWalletNumber,
      'metadata': metadata,
    };
  }

  // Copy with method
  DepositRequestModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? userAvatarUrl,
    double? amount,
    String? paymentMethod,
    String? transactionReference,
    String? receiptImageUrl,
    String? notes,
    String? adminNotes,
    String? status,
    String? processedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? processedAt,
    String? platformWalletNumber,
    Map<String, dynamic>? metadata,
  }) {
    return DepositRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionReference: transactionReference ?? this.transactionReference,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      notes: notes ?? this.notes,
      adminNotes: adminNotes ?? this.adminNotes,
      status: status ?? this.status,
      processedBy: processedBy ?? this.processedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      processedAt: processedAt ?? this.processedAt,
      platformWalletNumber: platformWalletNumber ?? this.platformWalletNumber,
      metadata: metadata ?? this.metadata,
    );
  }

  // Equality and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DepositRequestModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DepositRequestModel(id: $id, userName: $userName, amount: $amount, status: $status)';
  }
}

// Extension for convenience methods
extension DepositRequestModelX on DepositRequestModel {
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isProcessed => status != 'pending';

  String get formattedAmount => '${amount.toStringAsFixed(0)} د.ع';

  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'معلق';
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  String get paymentMethodDisplayName {
    switch (paymentMethod) {
      case 'zain_cash':
        return 'زين كاش';
      case 'qi_card':
        return 'كي كارد';
      case 'bank_transfer':
        return 'تحويل بنكي';
      case 'mobile_payment':
        return 'دفع عبر الهاتف';
      case 'credit_card':
        return 'بطاقة ائتمان';
      default:
        return paymentMethod;
    }
  }

  Duration get timeSinceCreated => DateTime.now().difference(createdAt);

  String get timeAgo {
    final duration = timeSinceCreated;
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

  String get formattedCreatedAt {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  String get formattedProcessedAt {
    if (processedAt == null) return '-';
    return '${processedAt!.day}/${processedAt!.month}/${processedAt!.year} ${processedAt!.hour}:${processedAt!.minute.toString().padLeft(2, '0')}';
  }
}