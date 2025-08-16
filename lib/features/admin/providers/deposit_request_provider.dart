import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/deposit_request_model.dart';
import '../services/admin_service.dart';

// Service Provider
final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
});

// Main Provider for Deposit Requests
final depositRequestsProvider = StateNotifierProvider<DepositRequestsNotifier, AsyncValue<List<DepositRequestModel>>>((ref) {
  return DepositRequestsNotifier(ref.read(adminServiceProvider));
});

// Filtered Providers
final pendingDepositRequestsProvider = Provider<AsyncValue<List<DepositRequestModel>>>((ref) {
  final requestsAsync = ref.watch(depositRequestsProvider);
  return requestsAsync.when(
    data: (requests) => AsyncValue.data(requests.where((r) => r.isPending).toList()),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

final approvedDepositRequestsProvider = Provider<AsyncValue<List<DepositRequestModel>>>((ref) {
  final requestsAsync = ref.watch(depositRequestsProvider);
  return requestsAsync.when(
    data: (requests) => AsyncValue.data(requests.where((r) => r.isApproved).toList()),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

final rejectedDepositRequestsProvider = Provider<AsyncValue<List<DepositRequestModel>>>((ref) {
  final requestsAsync = ref.watch(depositRequestsProvider);
  return requestsAsync.when(
    data: (requests) => AsyncValue.data(requests.where((r) => r.isRejected).toList()),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Statistics Provider
final depositRequestsStatsProvider = Provider<Map<String, int>>((ref) {
  final requestsAsync = ref.watch(depositRequestsProvider);
  return requestsAsync.when(
    data: (requests) {
      return {
        'total': requests.length,
        'pending': requests.where((r) => r.isPending).length,
        'approved': requests.where((r) => r.isApproved).length,
        'rejected': requests.where((r) => r.isRejected).length,
      };
    },
    loading: () => {'total': 0, 'pending': 0, 'approved': 0, 'rejected': 0},
    error: (_, __) => {'total': 0, 'pending': 0, 'approved': 0, 'rejected': 0},
  );
});

class DepositRequestsNotifier extends StateNotifier<AsyncValue<List<DepositRequestModel>>> {
  final AdminService _adminService;

  DepositRequestsNotifier(this._adminService) : super(const AsyncValue.loading()) {
    loadDepositRequests();
  }

  Future<void> loadDepositRequests() async {
    state = const AsyncValue.loading();
    try {
      final requests = await _adminService.getDepositRequests();
      state = AsyncValue.data(requests);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshRequests() async {
    await loadDepositRequests();
  }

  Future<void> approveRequest(String requestId, {String? adminNotes}) async {
    try {
      await _adminService.approveDepositRequest(requestId, adminNotes: adminNotes);
      await refreshRequests();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> rejectRequest(String requestId, {required String reason}) async {
    try {
      await _adminService.rejectDepositRequest(requestId, reason: reason);
      await refreshRequests();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateRequest(String requestId, Map<String, dynamic> updates) async {
    try {
      await _adminService.updateDepositRequest(requestId, updates);
      await refreshRequests();
    } catch (error) {
      rethrow;
    }
  }

  void filterByStatus(String status) {
    final currentData = state.value;
    if (currentData != null) {
      final filtered = currentData.where((r) => r.status == status).toList();
      state = AsyncValue.data(filtered);
    }
  }

  void filterByDateRange(DateTime startDate, DateTime endDate) {
    final currentData = state.value;
    if (currentData != null) {
      final filtered = currentData.where((r) =>
      r.createdAt.isAfter(startDate) && r.createdAt.isBefore(endDate)).toList();
      state = AsyncValue.data(filtered);
    }
  }

  void sortByAmount({bool ascending = true}) {
    final currentData = state.value;
    if (currentData != null) {
      final sorted = List<DepositRequestModel>.from(currentData);
      sorted.sort((a, b) => ascending ? a.amount.compareTo(b.amount) : b.amount.compareTo(a.amount));
      state = AsyncValue.data(sorted);
    }
  }

  void sortByDate({bool ascending = false}) {
    final currentData = state.value;
    if (currentData != null) {
      final sorted = List<DepositRequestModel>.from(currentData);
      sorted.sort((a, b) => ascending ? a.createdAt.compareTo(b.createdAt) : b.createdAt.compareTo(a.createdAt));
      state = AsyncValue.data(sorted);
    }
  }
}