import 'package:equatable/equatable.dart';
import '../../../core/models/wallet_model.dart';

enum WalletStatus { initial, loading, loaded, error }

class WalletState extends Equatable {
  final WalletStatus status;
  final WalletData? walletData;
  final List<WalletTransactionModel> walletTransactions;
  final List<TimeBankTransactionModel> timeBankTransactions;
  final bool isProcessing;
  final String? errorMessage;
  final String? successMessage;

  const WalletState({
    this.status = WalletStatus.initial,
    this.walletData,
    this.walletTransactions = const [],
    this.timeBankTransactions = const [],
    this.isProcessing = false,
    this.errorMessage,
    this.successMessage,
  });

  WalletState copyWith({
    WalletStatus? status,
    WalletData? walletData,
    List<WalletTransactionModel>? walletTransactions,
    List<TimeBankTransactionModel>? timeBankTransactions,
    bool? isProcessing,
    String? errorMessage,
    String? successMessage,
  }) {
    return WalletState(
      status: status ?? this.status,
      walletData: walletData ?? this.walletData,
      walletTransactions: walletTransactions ?? this.walletTransactions,
      timeBankTransactions: timeBankTransactions ?? this.timeBankTransactions,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    status, walletData, walletTransactions, timeBankTransactions,
    isProcessing, errorMessage, successMessage,
  ];
}