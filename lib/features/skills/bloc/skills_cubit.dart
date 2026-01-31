import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/repositories/skill_repository.dart';
import '../../../core/config/supabase_config.dart';
import 'skills_state.dart';

class SkillsCubit extends Cubit<SkillsState> {
  final SkillRepository _skillRepository = sl<SkillRepository>();

  SkillsCubit() : super(const SkillsState()) {
    loadInitialData();
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAD INITIAL DATA
  // ═══════════════════════════════════════════════════════════════════

  Future<void> loadInitialData() async {
    emit(state.copyWith(status: SkillsStatus.loading));

    try {
      final categories = await _skillRepository.getCategories();
      final skills = await _skillRepository.getSkills();

      emit(state.copyWith(
        status: SkillsStatus.loaded,
        categories: categories,
        skills: skills,
        currentPage: 1,
        hasReachedMax: skills.length < 20,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SkillsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAD MORE SKILLS (PAGINATION)
  // ═══════════════════════════════════════════════════════════════════

  Future<void> loadMoreSkills() async {
    if (state.hasReachedMax || state.status == SkillsStatus.loading) return;

    try {
      final nextPage = state.currentPage + 1;
      final newSkills = await _skillRepository.getSkills(
        categoryId: state.selectedCategoryId,
        searchQuery: state.searchQuery,
        page: nextPage,
      );

      emit(state.copyWith(
        skills: [...state.skills, ...newSkills],
        currentPage: nextPage,
        hasReachedMax: newSkills.length < 20,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // FILTER BY CATEGORY
  // ═══════════════════════════════════════════════════════════════════

  Future<void> filterByCategory(String? categoryId) async {
    emit(state.copyWith(
      status: SkillsStatus.loading,
      selectedCategoryId: categoryId,
      currentPage: 1,
      hasReachedMax: false,
    ));

    try {
      final skills = await _skillRepository.getSkills(
        categoryId: categoryId,
        searchQuery: state.searchQuery,
      );

      emit(state.copyWith(
        status: SkillsStatus.loaded,
        skills: skills,
        hasReachedMax: skills.length < 20,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SkillsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // SEARCH
  // ═══════════════════════════════════════════════════════════════════

  Future<void> search(String query) async {
    emit(state.copyWith(
      status: SkillsStatus.loading,
      searchQuery: query.isEmpty ? null : query,
      currentPage: 1,
      hasReachedMax: false,
    ));

    try {
      final skills = await _skillRepository.getSkills(
        categoryId: state.selectedCategoryId,
        searchQuery: query.isEmpty ? null : query,
      );

      emit(state.copyWith(
        status: SkillsStatus.loaded,
        skills: skills,
        hasReachedMax: skills.length < 20,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SkillsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // TOGGLE FAVORITE
  // ═══════════════════════════════════════════════════════════════════

  Future<void> toggleFavorite(String skillId) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) return;

    try {
      final isFavorite = await _skillRepository.toggleFavorite(skillId, userId);

      final updatedSkills = state.skills.map((skill) {
        if (skill.id == skillId) {
          return skill.copyWith(isFavorite: isFavorite);
        }
        return skill;
      }).toList();

      emit(state.copyWith(skills: updatedSkills));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // DELETE SKILL
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> deleteSkill(String skillId) async {
    try {
      await _skillRepository.deleteSkill(skillId);

      final updatedSkills = state.skills.where((s) => s.id != skillId).toList();
      emit(state.copyWith(skills: updatedSkills));
      
      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // CREATE SKILL
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> createSkill({
    required String titleAr,
    required String categoryId,
    String? titleEn,
    String? descriptionAr,
    String? descriptionEn,
    double? priceHours,
    int? durationMinutes,
  }) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) return false;

    try {
      final skill = SkillModel(
        id: '',
        userId: userId,
        categoryId: categoryId,
        titleAr: titleAr,
        titleEn: titleEn,
        descriptionAr: descriptionAr,
        descriptionEn: descriptionEn,
        priceHours: priceHours ?? 1.0,
        durationMinutes: durationMinutes ?? 60,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdSkill = await _skillRepository.createSkill(skill);

      emit(state.copyWith(
        skills: [createdSkill, ...state.skills],
      ));

      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // REFRESH
  // ═══════════════════════════════════════════════════════════════════

  Future<void> refresh() async {
    emit(state.copyWith(
      currentPage: 1,
      hasReachedMax: false,
    ));
    await loadInitialData();
  }
}