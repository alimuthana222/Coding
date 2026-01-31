import 'package:equatable/equatable.dart';
import '../../../core/models/skill_model.dart';
import '../../../core/models/post_model.dart';
import '../../../core/models/event_model.dart';
import '../../../core/models/user_model.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final UserModel? currentUser;
  final double walletHours;
  final List<SkillCategoryModel> categories;
  final List<SkillModel> featuredSkills;
  final List<SkillModel> recentSkills;
  final List<PostModel> recentPosts;
  final List<EventModel> upcomingEvents;
  final int unreadNotifications;
  final int unreadMessages;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.currentUser,
    this.walletHours = 0,
    this.categories = const [],
    this.featuredSkills = const [],
    this.recentSkills = const [],
    this.recentPosts = const [],
    this.upcomingEvents = const [],
    this.unreadNotifications = 0,
    this.unreadMessages = 0,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    UserModel? currentUser,
    double? walletHours,
    List<SkillCategoryModel>? categories,
    List<SkillModel>? featuredSkills,
    List<SkillModel>? recentSkills,
    List<PostModel>? recentPosts,
    List<EventModel>? upcomingEvents,
    int? unreadNotifications,
    int? unreadMessages,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      currentUser: currentUser ?? this.currentUser,
      walletHours: walletHours ?? this.walletHours,
      categories: categories ?? this.categories,
      featuredSkills: featuredSkills ?? this.featuredSkills,
      recentSkills: recentSkills ?? this.recentSkills,
      recentPosts: recentPosts ?? this.recentPosts,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status, currentUser, walletHours, categories, featuredSkills,
    recentSkills, recentPosts, upcomingEvents, unreadNotifications,
    unreadMessages, errorMessage,
  ];
}