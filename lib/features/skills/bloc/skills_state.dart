import 'package:equatable/equatable.dart';
import '../../../core/models/skill_model.dart';

enum SkillsStatus { initial, loading, loaded, error }

class SkillsState extends Equatable {
  final SkillsStatus status;
  final List<SkillModel> skills;
  final List<SkillCategoryModel> categories;
  final String? selectedCategoryId;
  final String? searchQuery;
  final String? errorMessage;
  final bool hasReachedMax;
  final int currentPage;

  const SkillsState({
    this.status = SkillsStatus.initial,
    this.skills = const [],
    this.categories = const [],
    this.selectedCategoryId,
    this.searchQuery,
    this.errorMessage,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  SkillsState copyWith({
    SkillsStatus? status,
    List<SkillModel>? skills,
    List<SkillCategoryModel>? categories,
    String? selectedCategoryId,
    String? searchQuery,
    String? errorMessage,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return SkillsState(
      status: status ?? this.status,
      skills: skills ?? this.skills,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
    status, skills, categories, selectedCategoryId,
    searchQuery, errorMessage, hasReachedMax, currentPage,
  ];
}