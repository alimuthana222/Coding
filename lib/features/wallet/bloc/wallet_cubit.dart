import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/repositories/wallet_repository.dart';
import '../../../core/models/wallet_model.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _walletRepository = sl<WalletRepository>();

  WalletCubit() : super(const WalletState()) {
    loadWalletData();
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAD WALLET DATA
  // ═══════════════════════════════════════════════════════════════════

  Future<void> loadWalletData() async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) return;

    emit(state.copyWith(status: WalletStatus.loading));

    try {
      final results = await Future.wait([
        _walletRepository.getWalletData(userId),
        _walletRepository.getWalletTransactions(userId),
        _walletRepository.getTimeBankTransactions(userId),
      ]);

      emit(state.copyWith(
        status: WalletStatus.loaded,
        walletData: results[0] as WalletData,
        walletTransactions: results[1] as List<WalletTransactionModel>,
        timeBankTransactions: results[2] as List<TimeBankTransactionModel>,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WalletStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // REQUEST DEPOSIT (إيداع يدوي)
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> requestDeposit({
    required double amount,
    required PaymentMethod method,
    required String paymentPhone,
    String? paymentReference,
    File? proofImage,
  }) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) return false;

    emit(state.copyWith(isProcessing: true, errorMessage: null, successMessage: null));

    try {
      await _walletRepository.requestDeposit(
        userId: userId,
        amount: amount,
        method: method,
        paymentPhone: paymentPhone,
        paymentReference: paymentReference,
        proofImage: proofImage,
      );

      await loadWalletData();

      emit(state.copyWith(
        isProcessing: false,
        successMessage: 'تم إرسال طلب الإيداع بنجاح!\nسيتم مراجعته وإضافة الرصيد خلال 24 ساعة',
      ));

      return true;
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // REQUEST WITHDRAWAL (سحب)
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> requestWithdrawal({
    required double amount,
    required PaymentMethod method,
    required String withdrawalPhone,
    String? withdrawalAccount,
  }) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) return false;

    if (state.walletData != null && amount > state.walletData!.balance) {
      emit(state.copyWith(errorMessage: 'الرصيد غير كافي'));
      return false;
    }

    emit(state.copyWith(isProcessing: true, errorMessage: null, successMessage: null));

    try {
      await _walletRepository.requestWithdrawal(
        userId: userId,
        amount: amount,
        method: method,
        withdrawalPhone: withdrawalPhone,
        withdrawalAccount: withdrawalAccount,
      );

      await loadWalletData();

      emit(state.copyWith(
        isProcessing: false,
        successMessage: 'تم إرسال طلب السحب بنجاح!\nسيتم تحويل المبلغ خلال 24-48 ساعة',
      ));

      return true;
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // BUY HOURS (شراء ساعات)
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> buyHours(double hours) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) return false;

    final cost = hours * WalletConstants.hourPrice;

    if (state.walletData != null && cost > state.walletData!.balance) {
      emit(state.copyWith(
        errorMessage: 'الرصيد غير كافي. تحتاج ${cost.toStringAsFixed(0)} د.ع',
      ));
      return false;
    }

    emit(state.copyWith(isProcessing: true, errorMessage: null, successMessage: null));

    try {
      await _walletRepository.buyHours(
        userId: userId,
        hours: hours,
      );

      await loadWalletData();

      emit(state.copyWith(
        isProcessing: false,
        successMessage: 'تم شراء ${hours.toStringAsFixed(0)} ساعة بنجاح! 🎉',
      ));

      return true;
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // REFRESH
  // ═══════════════════════════════════════════════════════════════════

  Future<void> refresh() async {
    await loadWalletData();
  }

  // ═══════════════════════════════════════════════════════════════════
  // CLEAR MESSAGES
  // ═══════════════════════════════════════════════════════════════════

  void clearMessages() {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }
}