import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/wallet_service.dart';
import '../models/transaction_model.dart';

final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService();
});

final walletBalanceProvider = FutureProvider<double>((ref) async {
  final walletService = ref.read(walletServiceProvider);
  return walletService.getWalletBalance();
});

final walletTransactionsProvider = FutureProvider<List<TransactionModel>>((ref) async {
  final walletService = ref.read(walletServiceProvider);
  return walletService.getTransactions(limit: 10);
});

final walletNotifierProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(ref.read(walletServiceProvider));
});

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletService _walletService;

  WalletNotifier(this._walletService) : super(const WalletInitial());

  Future<void> requestDeposit({
    required double amount,
    required PaymentMethod paymentMethod,
    required String transactionReference,
    String? notes,
  }) async {
    state = const WalletLoading();
    try {
      await _walletService.requestDeposit(
        amount: amount,
        paymentMethod: paymentMethod,
        transactionReference: transactionReference,
        notes: notes,
      );
      state = const WalletSuccess('تم إرسال طلب الإيداع بنجاح. سيتم مراجعته خلال 24-48 ساعة.');
    } catch (e) {
      state = WalletError(e.toString());
    }
  }

  Future<void> withdrawFunds({
    required double amount,
    required PaymentMethod paymentMethod,
    required String walletNumber, String? reference,
  }) async {
    state = const WalletLoading();
    try {
      await _walletService.withdrawFunds(
        amount: amount,
        paymentMethod: paymentMethod,
        walletNumber: walletNumber,
      );
      state = const WalletSuccess('تم إرسال طلب السحب بنجاح');
    } catch (e) {
      state = WalletError(e.toString());
    }
  }

  Future<void> transferFunds({
    required String toUserId,
    required double amount,
    String? description,
  }) async {
    state = const WalletLoading();
    try {
      await _walletService.transferFunds(
        toUserId: toUserId,
        amount: amount,
        description: description,
      );
      state = const WalletSuccess('تم تحويل الأموال بنجاح');
    } catch (e) {
      state = WalletError(e.toString());
    }
  }

  void depositFunds({required double amount, required PaymentMethod paymentMethod, required String reference}) {}
}

// Wallet States
abstract class WalletState {
  const WalletState();
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletSuccess extends WalletState {
  final String message;
  const WalletSuccess(this.message);
}

class WalletError extends WalletState {
  final String message;
  const WalletError(this.message);
}