import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_stats_model.dart';
import '/core/models/user_model.dart';
import '/features/services/models/service_model.dart';
import '/features/bookings/models/booking_model.dart';
import '../services/admin_service.dart';

// Service Provider
final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
});

// Admin Stats Provider
final adminStatsProvider = FutureProvider<AdminStatsModel>((ref) async {
  final adminService = ref.read(adminServiceProvider);
  return adminService.getAdminStats();
});

// All Users Provider
final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final adminService = ref.read(adminServiceProvider);
  return adminService.getAllUsers();
});

// All Services Provider
final allServicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final adminService = ref.read(adminServiceProvider);
  return adminService.getAllServices();
});

// All Bookings Provider
final allBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final adminService = ref.read(adminServiceProvider);
  return adminService.getAllBookings();
});

// Admin Notifier Provider
final adminNotifierProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref.read(adminServiceProvider));
});

// Admin State
class AdminState {
  final bool isLoading;
  final String? error;
  final AdminStatsModel? stats;

  const AdminState({
    this.isLoading = false,
    this.error,
    this.stats,
  });

  AdminState copyWith({
    bool? isLoading,
    String? error,
    AdminStatsModel? stats,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stats: stats ?? this.stats,
    );
  }
}

// Admin Notifier
class AdminNotifier extends StateNotifier<AdminState> {
  final AdminService _adminService;

  AdminNotifier(this._adminService) : super(const AdminState());

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final stats = await _adminService.getAdminStats();
      state = state.copyWith(isLoading: false, stats: stats);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> banUser(String userId) async {
    try {
      await _adminService.banUser(userId);
      await loadStats();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> unbanUser(String userId) async {
    try {
      await _adminService.unbanUser(userId);
      await loadStats();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> verifyUser(String userId) async {
    try {
      await _adminService.verifyUser(userId);
      await loadStats();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> approveService(String serviceId) async {
    try {
      await _adminService.approveService(serviceId);
      await loadStats();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> rejectService(String serviceId, String reason) async {
    try {
      await _adminService.rejectService(serviceId, reason);
      await loadStats();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}