import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/time_transaction_model.dart';
import '../services/timebank_service.dart';

final timebankServiceProvider = Provider<TimebankService>((ref) {
  return TimebankService();
});

final timeBalanceProvider = FutureProvider<int>((ref) async {
  final timebankService = ref.read(timebankServiceProvider);
  return timebankService.getTimeBalance();
});

final timeTransactionsProvider = FutureProvider<List<TimeTransactionModel>>((ref) async {
  final timebankService = ref.read(timebankServiceProvider);
  return timebankService.getTimeTransactions();
});

final timebankNotifierProvider = StateNotifierProvider<TimebankNotifier, TimebankState>((ref) {
  return TimebankNotifier(ref.read(timebankServiceProvider));
});

class TimebankNotifier extends StateNotifier<TimebankState> {
  final TimebankService _timebankService;

  TimebankNotifier(this._timebankService) : super(const TimebankState.initial());

  Future<void> transferTime({
    required String toUserId,
    required int hours,
    required String description,
  }) async {
    state = const TimebankState.loading();
    try {
      await _timebankService.transferTime(
        toUserId: toUserId,
        hours: hours,
        description: description,
      );
      state = const TimebankState.success('Time transferred successfully');
    } catch (e) {
      state = TimebankState.error(e.toString());
    }
  }

  Future<void> exchangeSkill({
    required String serviceId,
    required int hours,
  }) async {
    state = const TimebankState.loading();
    try {
      await _timebankService.exchangeSkill(
        serviceId: serviceId,
        hours: hours,
      );
      state = const TimebankState.success('Skill exchange completed');
    } catch (e) {
      state = TimebankState.error(e.toString());
    }
  }
}

sealed class TimebankState {
  const TimebankState();

  const factory TimebankState.initial() = _Initial;
  const factory TimebankState.loading() = _Loading;
  const factory TimebankState.success(String message) = _Success;
  const factory TimebankState.error(String message) = _Error;
}

class _Initial extends TimebankState {
  const _Initial();
}

class _Loading extends TimebankState {
  const _Loading();
}

class _Success extends TimebankState {
  final String message;
  const _Success(this.message);
}

class _Error extends TimebankState {
  final String message;
  const _Error(this.message);
}