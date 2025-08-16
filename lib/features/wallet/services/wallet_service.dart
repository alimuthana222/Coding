import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';

class WalletService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // أرقام المحافظ الإلكترونية للمنصة
  static const String zainCashNumber = '07801234567';
  static const String qiCardNumber = '12345678901234';

  Future<double> getWalletBalance() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('المستخدم غير مسجل الدخول');

    try {
      final response = await _supabase
          .from('profiles')
          .select('wallet_balance')
          .eq('id', user.id)
          .single();

      return (response['wallet_balance'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw Exception('فشل في الحصول على الرصيد');
    }
  }

  Future<List<TransactionModel>> getTransactions({
    int limit = 50,
    int offset = 0,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('المستخدم غير مسجل الدخول');

    try {
      final response = await _supabase
          .from('transactions')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map<TransactionModel>((json) {
        return TransactionModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('فشل في الحصول على المعاملات');
    }
  }

  Future<void> requestDeposit({
    required double amount,
    required PaymentMethod paymentMethod,
    required String transactionReference,
    String? notes,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('المستخدم غير مسجل الدخول');

    try {
      final now = DateTime.now().toIso8601String();

      // إنشاء طلب إيداع معلق
      await _supabase.from('transactions').insert({
        'user_id': user.id,
        'type': 'deposit',
        'amount': amount,
        'status': 'pending', // معلق للموافقة الإدارية
        'payment_method': _paymentMethodToString(paymentMethod),
        'description': 'طلب إيداع أموال في المحفظة',
        'reference': transactionReference,
        'notes': notes,
        'platform_wallet_number': _getPlatformWalletNumber(paymentMethod),
        'created_at': now,
        'updated_at': now,
      });

      // إرسال إشعار للإدارة
      await _notifyAdminOfDepositRequest(user.id, amount, paymentMethod, transactionReference);

    } catch (e) {
      throw Exception('فشل في إرسال طلب الإيداع: ${e.toString()}');
    }
  }

  Future<void> _notifyAdminOfDepositRequest(
      String userId,
      double amount,
      PaymentMethod method,
      String reference
      ) async {
    try {
      // إضافة إشعار في جدول الإشعارات الإدارية
      await _supabase.from('admin_notifications').insert({
        'type': 'deposit_request',
        'title': 'طلب إيداع جديد',
        'message': 'طلب إيداع بمبلغ $amount د.ع عبر ${_getPaymentMethodName(method)}',
        'user_id': userId,
        'data': {
          'amount': amount,
          'method': _paymentMethodToString(method),
          'reference': reference,
        },
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('فشل في إرسال إشعار للإدارة: $e');
    }
  }

  String _getPlatformWalletNumber(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.zainCash:
        return zainCashNumber;
      case PaymentMethod.qiCard:
        return qiCardNumber;
      case PaymentMethod.wallet:
        return '';
    }
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.zainCash:
        return 'زين كاش';
      case PaymentMethod.qiCard:
        return 'كي كارد';
      case PaymentMethod.wallet:
        return 'المحفظة الإلكترونية';
    }
  }

  Future<void> withdrawFunds({
    required double amount,
    required PaymentMethod paymentMethod,
    required String walletNumber,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('المستخدم غير مسجل الدخول');

    try {
      final currentBalance = await getWalletBalance();
      if (currentBalance < amount) {
        throw Exception('الرصيد غير كافي');
      }

      await _supabase.from('transactions').insert({
        'user_id': user.id,
        'type': 'withdrawal',
        'amount': amount,
        'status': 'pending',
        'payment_method': _paymentMethodToString(paymentMethod),
        'description': 'طلب سحب أموال من المحفظة',
        'reference': walletNumber,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

    } catch (e) {
      throw Exception('فشل في سحب الأموال: ${e.toString()}');
    }
  }

  Future<void> transferFunds({
    required String toUserId,
    required double amount,
    String? description,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('المستخدم غير مسجل الدخول');

    try {
      final currentBalance = await getWalletBalance();
      if (currentBalance < amount) {
        throw Exception('الرصيد غير كافي');
      }

      final targetUser = await _supabase
          .from('profiles')
          .select('id, full_name, wallet_balance')
          .or('id.eq.$toUserId,email.eq.$toUserId')
          .maybeSingle();

      if (targetUser == null) {
        throw Exception('المستخدم المستلم غير موجود');
      }

      final actualToUserId = targetUser['id'] as String;
      final targetBalance = (targetUser['wallet_balance'] as num?)?.toDouble() ?? 0.0;

      if (actualToUserId == user.id) {
        throw Exception('لا يمكنك تحويل أموال لنفسك');
      }

      final now = DateTime.now().toIso8601String();

      await _supabase.from('transactions').insert([
        {
          'user_id': user.id,
          'from_user_id': user.id,
          'to_user_id': actualToUserId,
          'type': 'transfer_sent',
          'amount': amount,
          'status': 'completed',
          'description': description ?? 'تحويل أموال',
          'created_at': now,
          'updated_at': now,
        },
        {
          'user_id': actualToUserId,
          'from_user_id': user.id,
          'to_user_id': actualToUserId,
          'type': 'transfer_received',
          'amount': amount,
          'status': 'completed',
          'description': description ?? 'تحويل أموال',
          'created_at': now,
          'updated_at': now,
        },
      ]);

      await _supabase.from('profiles')
          .update({
        'wallet_balance': currentBalance - amount,
        'updated_at': now,
      })
          .eq('id', user.id);

      await _supabase.from('profiles')
          .update({
        'wallet_balance': targetBalance + amount,
        'updated_at': now,
      })
          .eq('id', actualToUserId);

    } catch (e) {
      if (e.toString().contains('المستخدم المستلم غير موجود') ||
          e.toString().contains('الرصيد غير كافي') ||
          e.toString().contains('لا يمكنك تحويل أموال لنفسك')) {
        rethrow;
      } else {
        throw Exception('فشل في تحويل الأموال: ${e.toString()}');
      }
    }
  }

  String _paymentMethodToString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.zainCash:
        return 'zain_cash';
      case PaymentMethod.qiCard:
        return 'qi_card';
      case PaymentMethod.wallet:
        return 'wallet';
    }
  }
}