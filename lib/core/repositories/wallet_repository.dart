import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  final _client = SupabaseConfig.client;

  // ═══════════════════════════════════════════════════════════════════
  // GET WALLET DATA
  // ═══════════════════════════════════════════════════════════════════

  Future<WalletData> getWalletData(String userId) async {
    final response = await _client
        .from(SupabaseConfig.profilesTable)
        .select('wallet_balance, time_bank_hours, total_earnings')
        .eq('id', userId)
        .single();

    return WalletData.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET WALLET TRANSACTIONS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<WalletTransactionModel>> getWalletTransactions(
      String userId, {
        int page = 1,
        int limit = 20,
      }) async {
    final response = await _client
        .from('wallet_transactions')
        .select('*, related_user:profiles!wallet_transactions_related_user_id_fkey(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range((page - 1) * limit, page * limit - 1);

    return (response as List)
        .map((e) => WalletTransactionModel.fromJson(e))
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET TIME BANK TRANSACTIONS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<TimeBankTransactionModel>> getTimeBankTransactions(
      String userId, {
        int page = 1,
        int limit = 20,
      }) async {
    final response = await _client
        .from('time_bank_transactions')
        .select('*, related_user:profiles!time_bank_transactions_related_user_id_fkey(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range((page - 1) * limit, page * limit - 1);

    return (response as List)
        .map((e) => TimeBankTransactionModel.fromJson(e))
        .toList();
  }

  // ════��══════════════════════════════════════════════════════════════
  // REQUEST DEPOSIT (تعبئة يدوية)
  // ═══════════════════════════════════════════════════════════════════

  Future<WalletTransactionModel> requestDeposit({
    required String userId,
    required double amount,
    required PaymentMethod method,
    required String paymentPhone,
    String? paymentReference,
    File? proofImage,
  }) async {
    final walletData = await getWalletData(userId);

    // Upload proof image
    String? proofUrl;
    if (proofImage != null) {
      final fileName = '$userId/deposit_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _client.storage.from('wallet-proofs').upload(
        fileName,
        proofImage,
        fileOptions: const FileOptions(upsert: true),
      );
      proofUrl = _client.storage.from('wallet-proofs').getPublicUrl(fileName);
    }

    final methodName = method == PaymentMethod.zainCash ? 'زين كاش' : 'كي كارد الرافدين';

    final transaction = {
      'user_id': userId,
      'type': 'deposit',
      'amount': amount,
      'balance_before': walletData.balance,
      'balance_after': walletData.balance, // سيتحدث عند الموافقة
      'status': 'pending',
      'payment_method': method == PaymentMethod.zainCash ? 'zain_cash' : 'qi_card',
      'payment_phone': paymentPhone,
      'payment_reference': paymentReference,
      'deposit_proof_url': proofUrl,
      'description_ar': 'طلب إيداع $amount د.ع عبر $methodName',
    };

    final response = await _client
        .from('wallet_transactions')
        .insert(transaction)
        .select()
        .single();

    return WalletTransactionModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // REQUEST WITHDRAWAL
  // ═══════════════════════════════════════════════════════════════════

  Future<WalletTransactionModel> requestWithdrawal({
    required String userId,
    required double amount,
    required PaymentMethod method,
    required String withdrawalPhone,
    String? withdrawalAccount,
  }) async {
    final walletData = await getWalletData(userId);

    if (amount > walletData.balance) {
      throw Exception('الرصيد غير كافي');
    }

    final methodName = method == PaymentMethod.zainCash ? 'زين كاش' : 'كي كارد الرافدين';

    final transaction = {
      'user_id': userId,
      'type': 'withdrawal',
      'amount': amount,
      'balance_before': walletData.balance,
      'balance_after': walletData.balance, // سيتحدث عند الموافقة
      'status': 'pending',
      'withdrawal_phone': withdrawalPhone,
      'withdrawal_account': withdrawalAccount,
      'description_ar': 'طلب سحب $amount د.ع إلى $methodName',
    };

    final response = await _client
        .from('wallet_transactions')
        .insert(transaction)
        .select()
        .single();

    return WalletTransactionModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // BUY HOURS (شراء ساعات من المحفظة)
  // ═══════════════════════════════════════════════════════════════════

  Future<void> buyHours({
    required String userId,
    required double hours,
  }) async {
    final walletData = await getWalletData(userId);
    final cost = hours * WalletConstants.hourPrice;

    if (cost > walletData.balance) {
      throw Exception('الرصيد غير كافي. تحتاج $cost د.ع');
    }

    // خصم من المحفظة
    await _client.from(SupabaseConfig.profilesTable).update({
      'wallet_balance': walletData.balance - cost,
      'time_bank_hours': walletData.timeBankHours + hours,
    }).eq('id', userId);

    // تسجيل معاملة المحفظة
    await _client.from('wallet_transactions').insert({
      'user_id': userId,
      'type': 'buy_hours',
      'amount': cost,
      'balance_before': walletData.balance,
      'balance_after': walletData.balance - cost,
      'status': 'completed',
      'hours_purchased': hours,
      'description_ar': 'شراء $hours ساعة مقابل $cost د.ع',
    });

    // تسجيل معاملة بنك الساعات
    await _client.from('time_bank_transactions').insert({
      'user_id': userId,
      'type': 'purchased',
      'hours': hours,
      'balance_before': walletData.timeBankHours,
      'balance_after': walletData.timeBankHours + hours,
      'amount_paid': cost,
      'description_ar': 'شراء $hours ساعة من المحفظة',
    });
  }

  // ═══════════════════════════════════════════════════════════════════
  // CHECK IF USER CAN AFFORD (للتحقق قبل الحجز)
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> canAffordService({
    required String userId,
    required bool isHours,
    required double amount,
  }) async {
    final walletData = await getWalletData(userId);

    if (isHours) {
      return walletData.timeBankHours >= amount;
    } else {
      return walletData.balance >= amount;
    }
  }
}