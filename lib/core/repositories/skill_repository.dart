import '../config/supabase_config.dart';
import '../models/skill_model.dart';

class SkillRepository {
  final _client = SupabaseConfig.client;

  // ═══════════════════════════════════════════════════════════════════
  // GET ALL SKILLS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<SkillModel>> getSkills({
    String? categoryId,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    var query = _client
        .from(SupabaseConfig.skillsTable)
        .select('*, profiles(*), skill_categories(*)')
        .eq('is_active', true);

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('title_ar.ilike.%$searchQuery%,title_en.ilike.%$searchQuery%');
    }

    final response = await query
        .order('created_at', ascending: false)
        .range((page - 1) * limit, page * limit - 1);

    return (response as List).map((e) => SkillModel.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET SKILL BY ID
  // ═══════════════════════════════════════════════════════════════════

  Future<SkillModel?> getSkillById(String id) async {
    final response = await _client
        .from(SupabaseConfig.skillsTable)
        .select('*, profiles(*), skill_categories(*)')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return SkillModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET USER SKILLS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<SkillModel>> getUserSkills(String userId) async {
    final response = await _client
        .from(SupabaseConfig.skillsTable)
        .select('*, profiles(*), skill_categories(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => SkillModel.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // CREATE SKILL
  // ═══════════════════════════════════════════════════════════════════

  Future<SkillModel> createSkill(SkillModel skill) async {
    final response = await _client
        .from(SupabaseConfig.skillsTable)
        .insert(skill.toJson())
        .select('*, profiles(*), skill_categories(*)')
        .single();

    return SkillModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // UPDATE SKILL
  // ═══════════════════════════════════════════════════════════════════

  Future<SkillModel> updateSkill(SkillModel skill) async {
    final response = await _client
        .from(SupabaseConfig.skillsTable)
        .update(skill.toJson())
        .eq('id', skill.id)
        .select('*, profiles(*), skill_categories(*)')
        .single();

    return SkillModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // DELETE SKILL
  // ═══════════════════════════════════════════════════════════════════

  Future<void> deleteSkill(String id) async {
    await _client.from(SupabaseConfig.skillsTable).delete().eq('id', id);
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET CATEGORIES
  // ═══════════════════════════════════════════════════════════════════

  Future<List<SkillCategoryModel>> getCategories() async {
    final response = await _client
        .from(SupabaseConfig.skillCategoriesTable)
        .select()
        .order('name_ar');

    return (response as List).map((e) => SkillCategoryModel.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // TOGGLE FAVORITE
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> toggleFavorite(String skillId, String userId) async {
    final existing = await _client
        .from(SupabaseConfig.favoritesTable)
        .select()
        .eq('skill_id', skillId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from(SupabaseConfig.favoritesTable)
          .delete()
          .eq('skill_id', skillId)
          .eq('user_id', userId);
      return false;
    } else {
      await _client.from(SupabaseConfig.favoritesTable).insert({
        'skill_id': skillId,
        'user_id': userId,
      });
      return true;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET FAVORITES
  // ═══════════════════════════════════════════════════════════════════

  Future<List<SkillModel>> getFavorites(String userId) async {
    final response = await _client
        .from(SupabaseConfig.favoritesTable)
        .select('skills(*, profiles(*), skill_categories(*))')
        .eq('user_id', userId);

    return (response as List)
        .map((e) => SkillModel.fromJson(e['skills']))
        .toList();
  }
}