import 'package:equatable/equatable.dart';
import 'user_model.dart';

// ═══════════════════════════════════════════════════════════════════
// CONSTANTS
// ═══════════════════════════════════════════════════════════════════

class WalletConstants {
  static const double hourPrice = 1000; // 1000 دينار = 1 ساعة
  static const double initialHours = 2; // ساعتين مجانية لكل حساب جديد
}

// ═══════════════════════════════════════════════════════════════════
// ENUMS
// ═══════════════════════════════════════════════════════════════════

enum WalletTransactionType {
  deposit,
  withdrawal,
  servicePayment,
  serviceEarning,
  buyHours,
  refund,
}

enum TransactionStatus {
  pending,
  completed,
  rejected,
  cancelled,
}

enum PaymentMethod {
  zainCash,
  qiCard,
}

enum TimeBankTransactionType {
  initial,
  purchased,
  earned,
  spent,
  refund,
}

// ═══════════════════════════════════════════════════════════════════
// WALLET DATA
// ═══════════════════════════════════════════════════════════════════

class WalletData extends Equatable {
  final double balance;
  final double timeBankHours;
  final double totalEarnings;

  const WalletData({
    this.balance = 0,
    this.timeBankHours = 2,
    this.totalEarnings = 0,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      balance: (json['wallet_balance'] as num?)?.toDouble() ?? 0,
      timeBankHours: (json['time_bank_hours'] as num?)?.toDouble() ?? 2,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0,
    );
  }

  // كم ساعة يمكن شراؤها بالرصيد الحالي
  double get maxHoursCanBuy => balance / WalletConstants.hourPrice;

  @override
  List<Object?> get props => [balance, timeBankHours, totalEarnings];
}

// ═══════════════════════════════════════════════════════════════════
// WALLET TRANSACTION
// ═══════════════════════════════════════════════════════════════════

class WalletTransactionModel extends Equatable {
  final String id;
  final String userId;
  final WalletTransactionType type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final TransactionStatus status;
  final PaymentMethod? paymentMethod;
  final String? paymentPhone;
  final String? paymentReference;
  final String? depositProofUrl;
  final String? withdrawalPhone;
  final String? withdrawalAccount;
  final String? relatedServiceId;
  final String? relatedBookingId;
  final String? relatedUserId;
  final double? hoursPurchased;
  final String? adminNote;
  final DateTime? processedAt;
  final String? descriptionAr;
  final DateTime createdAt;
  final UserModel? relatedUser;

  const WalletTransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.status = TransactionStatus.pending,
    this.paymentMethod,
    this.paymentPhone,
    this.paymentReference,
    this.depositProofUrl,
    this.withdrawalPhone,
    this.withdrawalAccount,
    this.relatedServiceId,
    this.relatedBookingId,
    this.relatedUserId,
    this.hoursPurchased,
    this.adminNote,
    this.processedAt,
    this.descriptionAr,
    required this.createdAt,
    this.relatedUser,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: _parseTransactionType(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      balanceBefore: (json['balance_before'] as num).toDouble(),
      balanceAfter: (json['balance_after'] as num).toDouble(),
      status: TransactionStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      paymentMethod: json['payment_method'] != null
          ? _parsePaymentMethod(json['payment_method'] as String)
          : null,
      paymentPhone: json['payment_phone'] as String?,
      paymentReference: json['payment_reference'] as String?,
      depositProofUrl: json['deposit_proof_url'] as String?,
      withdrawalPhone: json['withdrawal_phone'] as String?,
      withdrawalAccount: json['withdrawal_account'] as String?,
      relatedServiceId: json['related_service_id'] as String?,
      relatedBookingId: json['related_booking_id'] as String?,
      relatedUserId: json['related_user_id'] as String?,
      hoursPurchased: (json['hours_purchased'] as num?)?.toDouble(),
      adminNote: json['admin_note'] as String?,
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'])
          : null,
      descriptionAr: json['description_ar'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      relatedUser: json['related_user'] != null
          ? UserModel.fromJson(json['related_user'])
          : null,
    );
  }

  static WalletTransactionType _parseTransactionType(String type) {
    switch (type) {
      case 'deposit': return WalletTransactionType.deposit;
      case 'withdrawal': return WalletTransactionType.withdrawal;
      case 'service_payment': return WalletTransactionType.servicePayment;
      case 'service_earning': return WalletTransactionType.serviceEarning;
      case 'buy_hours': return WalletTransactionType.buyHours;
      case 'refund': return WalletTransactionType.refund;
      default: return WalletTransactionType.deposit;
    }
  }

  static PaymentMethod _parsePaymentMethod(String method) {
    switch (method) {
      case 'zain_cash': return PaymentMethod.zainCash;
      case 'qi_card': return PaymentMethod.qiCard;
      default: return PaymentMethod.zainCash;
    }
  }

  String get typeLabel {
    switch (type) {
      case WalletTransactionType.deposit: return 'إيداع';
      case WalletTransactionType.withdrawal: return 'سحب';
      case WalletTransactionType.servicePayment: return 'دفع مقابل خدمة';
      case WalletTransactionType.serviceEarning: return 'ربح من خدمة';
      case WalletTransactionType.buyHours: return 'شراء ساعات';
      case WalletTransactionType.refund: return 'استرداد';
    }
  }

  String get statusLabel {
    switch (status) {
      case TransactionStatus.pending: return 'قيد المراجعة';
      case TransactionStatus.completed: return 'مكتمل';
      case TransactionStatus.rejected: return 'مرفوض';
      case TransactionStatus.cancelled: return 'ملغي';
    }
  }

  bool get isIncoming =>
      type == WalletTransactionType.deposit ||
          type == WalletTransactionType.serviceEarning ||
          type == WalletTransactionType.refund;

  @override
  List<Object?> get props => [id, type, amount, status, createdAt];
}

// ═══════════════════════════════════════════════════════════════════
// TIME BANK TRANSACTION
// ═══════════════════════════════════════════════════════════════════

class TimeBankTransactionModel extends Equatable {
  final String id;
  final String userId;
  final TimeBankTransactionType type;
  final double hours;
  final double balanceBefore;
  final double balanceAfter;
  final double? amountPaid;
  final String? relatedServiceId;
  final String? relatedBookingId;
  final String? relatedUserId;
  final String? descriptionAr;
  final DateTime createdAt;
  final UserModel? relatedUser;

  const TimeBankTransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.hours,
    required this.balanceBefore,
    required this.balanceAfter,
    this.amountPaid,
    this.relatedServiceId,
    this.relatedBookingId,
    this.relatedUserId,
    this.descriptionAr,
    required this.createdAt,
    this.relatedUser,
  });

  factory TimeBankTransactionModel.fromJson(Map<String, dynamic> json) {
    return TimeBankTransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: _parseType(json['type'] as String),
      hours: (json['hours'] as num).toDouble(),
      balanceBefore: (json['balance_before'] as num).toDouble(),
      balanceAfter: (json['balance_after'] as num).toDouble(),
      amountPaid: (json['amount_paid'] as num?)?.toDouble(),
      relatedServiceId: json['related_service_id'] as String?,
      relatedBookingId: json['related_booking_id'] as String?,
      relatedUserId: json['related_user_id'] as String?,
      descriptionAr: json['description_ar'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      relatedUser: json['related_user'] != null
          ? UserModel.fromJson(json['related_user'])
          : null,
    );
  }

  static TimeBankTransactionType _parseType(String type) {
    switch (type) {
      case 'initial': return TimeBankTransactionType.initial;
      case 'purchased': return TimeBankTransactionType.purchased;
      case 'earned': return TimeBankTransactionType.earned;
      case 'spent': return TimeBankTransactionType.spent;
      case 'refund': return TimeBankTransactionType.refund;
      default: return TimeBankTransactionType.initial;
    }
  }

  String get typeLabel {
    switch (type) {
      case TimeBankTransactionType.initial: return 'رصيد أولي';
      case TimeBankTransactionType.purchased: return 'شراء';
      case TimeBankTransactionType.earned: return 'ربح';
      case TimeBankTransactionType.spent: return 'صرف';
      case TimeBankTransactionType.refund: return 'استرداد';
    }
  }

  bool get isIncoming =>
      type == TimeBankTransactionType.initial ||
          type == TimeBankTransactionType.purchased ||
          type == TimeBankTransactionType.earned ||
          type == TimeBankTransactionType.refund;

  @override
  List<Object?> get props => [id, type, hours, createdAt];
}