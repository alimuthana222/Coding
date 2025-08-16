import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/moderator_stats_model.dart';
import '../models/report_model.dart';
import '../models/moderator_action_model.dart';
import '../services/moderator_service.dart';

// Service Provider
final moderatorServiceProvider = Provider<ModeratorService>((ref) {
  return ModeratorService();
});

// Stats Provider
final moderatorStatsProvider = FutureProvider<ModeratorStatsModel>((ref) async {
  final service = ref.read(moderatorServiceProvider);
  return service.getModeratorStats();
});

// Reports Providers
final pendingReportsProvider = FutureProvider<List<ReportModel>>((ref) async {
  final service = ref.read(moderatorServiceProvider);
  return service.getPendingReports();
});

final allReportsProvider = FutureProvider<List<ReportModel>>((ref) async {
  final service = ref.read(moderatorServiceProvider);
  return service.getAllReports();
});

// Recent Actions Provider
final recentActionsProvider = FutureProvider<List<ModeratorActionModel>>((ref) async {
  final service = ref.read(moderatorServiceProvider);
  return service.getRecentActions();
});

// Moderator Notifier
final moderatorNotifierProvider = StateNotifierProvider<ModeratorNotifier, ModeratorState>((ref) {
  return ModeratorNotifier(ref.read(moderatorServiceProvider));
});

// Moderator State
class ModeratorState {
  final bool isLoading;
  final String? error;
  final List<ReportModel> reports;
  final List<ModeratorActionModel> actions;

  const ModeratorState({
    this.isLoading = false,
    this.error,
    this.reports = const [],
    this.actions = const [],
  });

  ModeratorState copyWith({
    bool? isLoading,
    String? error,
    List<ReportModel>? reports,
    List<ModeratorActionModel>? actions,
  }) {
    return ModeratorState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      reports: reports ?? this.reports,
      actions: actions ?? this.actions,
    );
  }
}

// Moderator Notifier
class ModeratorNotifier extends StateNotifier<ModeratorState> {
  final ModeratorService _service;

  ModeratorNotifier(this._service) : super(const ModeratorState());

  Future<void> loadReports() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final reports = await _service.getAllReports();
      state = state.copyWith(isLoading: false, reports: reports);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> resolveReport(String reportId, String resolution, String actionTaken) async {
    try {
      await _service.resolveReport(reportId, resolution, actionTaken);
      await loadReports();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> rejectReport(String reportId, String reason) async {
    try {
      await _service.rejectReport(reportId, reason);
      await loadReports();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> banUser(String userId, String reason, {Duration? duration}) async {
    try {
      await _service.banUser(userId, reason, duration: duration);
      await loadReports();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> warnUser(String userId, String reason) async {
    try {
      await _service.warnUser(userId, reason);
      await loadReports();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteContent(String contentId, String contentType, String reason) async {
    try {
      await _service.deleteContent(contentId, contentType, reason);
      await loadReports();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}