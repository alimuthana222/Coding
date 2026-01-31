import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/repositories/skill_repository.dart';
import '../../../core/repositories/post_repository.dart';
import '../../../core/repositories/event_repository.dart';
import '../../../core/repositories/notification_repository.dart';
import '../../../core/repositories/message_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final AuthRepository _authRepository = sl<AuthRepository>();
  final SkillRepository _skillRepository = sl<SkillRepository>();
  final PostRepository _postRepository = sl<PostRepository>();
  final EventRepository _eventRepository = sl<EventRepository>();
  final NotificationRepository _notificationRepository = sl<NotificationRepository>();
  final MessageRepository _messageRepository = sl<MessageRepository>();

  HomeCubit() : super(const HomeState()) {
    loadHomeData();
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAD ALL HOME DATA
  // ═══════════════════════════════════════════════════════════════════

  Future<void> loadHomeData() async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      // Load data in parallel for better performance
      final results = await Future.wait([
        _loadUserData(),
        _loadCategories(),
        _loadFeaturedSkills(),
        _loadRecentSkills(),
        _loadRecentPosts(),
        _loadUpcomingEvents(),
        _loadUnreadCounts(),
      ]);

      emit(state.copyWith(status: HomeStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAD USER DATA
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _loadUserData() async {
    if (!SupabaseConfig.isAuthenticated) return;

    try {
      final user = await _authRepository.getCurrentUserProfile();
      if (user != null) {
        emit(state.copyWith(
          currentUser: user,
          walletHours: user.walletHours,
        ));
      }
    } catch (e) {
      // Silent fail - user might not be logged in
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAD CATEGORIES
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _loadCategories() async {
    try {
      final categories = await _skillRepository.getCategories();
      emit(state.copyWith(categories: categories));
    } catch (e) {
      // Use empty list on error
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAD FEATURED SKILLS (Top rated)
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _loadFeaturedSkills() async {
    try {
      final skills = await _skillRepository.getSkills(limit: 6);
      // Sort by rating for featured
      skills.sort((a, b) => b.rating.compareTo(a.rating));
      emit(state.copyWith(featuredSkills: skills.take(4).toList()));
    } catch (e) {
      // Use empty list on error
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAD RECENT SKILLS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _loadRecentSkills() async {
    try {
      final skills = await _skillRepository.getSkills(limit: 6);
      emit(state.copyWith(recentSkills: skills));
    } catch (e) {
      // Use empty list on error
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAD RECENT POSTS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _loadRecentPosts() async {
    try {
      final posts = await _postRepository.getPosts(limit: 5);
      emit(state.copyWith(recentPosts: posts));
    } catch (e) {
      // Use empty list on error
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAD UPCOMING EVENTS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _loadUpcomingEvents() async {
    try {
      final events = await _eventRepository.getEvents(
        upcomingOnly: true,
        limit: 5,
      );
      emit(state.copyWith(upcomingEvents: events));
    } catch (e) {
      // Use empty list on error
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAD UNREAD COUNTS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _loadUnreadCounts() async {
    if (!SupabaseConfig.isAuthenticated) return;

    try {
      final userId = SupabaseConfig.currentUserId!;

      final notifCount = await _notificationRepository.getUnreadCount(userId);
      final msgCount = await _messageRepository.getUnreadCount(userId);

      emit(state.copyWith(
        unreadNotifications: notifCount,
        unreadMessages: msgCount,
      ));
    } catch (e) {
      // Silent fail
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // REFRESH
  // ═══════════════════════════════════════════════════════════════════

  Future<void> refresh() async {
    await loadHomeData();
  }

  // ═══════════════════════════════════════════════════════════════════
  // TOGGLE SKILL FAVORITE
  // ═══════════════════════════════════════════════════════════════════

  Future<void> toggleSkillFavorite(String skillId) async {
    if (!SupabaseConfig.isAuthenticated) return;

    try {
      final userId = SupabaseConfig.currentUserId!;
      await _skillRepository.toggleFavorite(skillId, userId);

      // Refresh skills
      await _loadFeaturedSkills();
      await _loadRecentSkills();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}