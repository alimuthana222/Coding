enum TransactionType {
  deposit,
  withdrawal,
  transferSent,
  transferReceived,
  payment,
  refund,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

enum PaymentMethod {
  zainCash,
  qiCard,
  wallet,
}

class TransactionModel {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final TransactionStatus status;
  final PaymentMethod? paymentMethod;
  final String? description;
  final String? reference;
  final String? toUserId;
  final String? fromUserId;
  final String? toUserName;
  final String? fromUserName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.description,
    this.reference,
    this.toUserId,
    this.fromUserId,
    this.toUserName,
    this.fromUserName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: _parseTransactionType(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      status: _parseTransactionStatus(json['status'] as String),
      paymentMethod: json['payment_method'] != null
          ? _parsePaymentMethod(json['payment_method'] as String)
          : null,
      description: json['description'] as String?,
      reference: json['reference'] as String?,
      toUserId: json['to_user_id'] as String?,
      fromUserId: json['from_user_id'] as String?,
      toUserName: json['to_user_name'] as String?,
      fromUserName: json['from_user_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static TransactionType _parseTransactionType(String value) {
    switch (value) {
      case 'deposit':
        return TransactionType.deposit;
      case 'withdrawal':
        return TransactionType.withdrawal;
      case 'transfer_sent':
        return TransactionType.transferSent;
      case 'transfer_received':
        return TransactionType.transferReceived;
      case 'payment':
        return TransactionType.payment;
      case 'refund':
        return TransactionType.refund;
      default:
        return TransactionType.deposit;
    }
  }

  static TransactionStatus _parseTransactionStatus(String value) {
    switch (value) {
      case 'pending':
        return TransactionStatus.pending;
      case 'completed':
        return TransactionStatus.completed;
      case 'failed':
        return TransactionStatus.failed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }

  static PaymentMethod _parsePaymentMethod(String value) {
    switch (value) {
      case 'zain_cash':
        return PaymentMethod.zainCash;
      case 'qi_card':
        return PaymentMethod.qiCard;
      case 'wallet':
        return PaymentMethod.wallet;
      default:
        return PaymentMethod.wallet;
    }
  }

  String get typeDisplayName {
    switch (type) {
      case TransactionType.deposit:
        return 'إيداع';
      case TransactionType.withdrawal:
        return 'سحب';
      case TransactionType.transferSent:
        return 'تحويل مرسل';
      case TransactionType.transferReceived:
        return 'تحويل مستلم';
      case TransactionType.payment:
        return 'دفع';
      case TransactionType.refund:
        return 'استرداد';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case TransactionStatus.pending:
        return 'معلق';
      case TransactionStatus.completed:
        return 'مكتمل';
      case TransactionStatus.failed:
        return 'فاشل';
      case TransactionStatus.cancelled:
        return 'ملغي';
    }
  }

  String? get paymentMethodDisplayName {
    if (paymentMethod == null) return null;

    switch (paymentMethod!) {
      case PaymentMethod.zainCash:
        return 'زين كاش';
      case PaymentMethod.qiCard:
        return 'كي كارد';
      case PaymentMethod.wallet:
        return 'المحفظة';
    }
  }
}