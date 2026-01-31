import '../config/supabase_config.dart';
import '../models/post_model.dart';

class PostRepository {
  final _client = SupabaseConfig.client;

  // ═══════════════════════════════════════════════════════════════════
  // GET POSTS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<PostModel>> getPosts({int page = 1, int limit = 20}) async {
    final response = await _client
        .from(SupabaseConfig.postsTable)
        .select('*, profiles(*)')
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .range((page - 1) * limit, page * limit - 1);

    return (response as List).map((e) => PostModel.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET POST BY ID
  // ═══════════════════════════════════════════════════════════════════

  Future<PostModel?> getPostById(String id) async {
    final response = await _client
        .from(SupabaseConfig.postsTable)
        .select('*, profiles(*)')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return PostModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET USER POSTS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<PostModel>> getUserPosts(String userId, {int page = 1, int limit = 20}) async {
    final response = await _client
        .from(SupabaseConfig.postsTable)
        .select('*, profiles(*)')
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .range((page - 1) * limit, page * limit - 1);

    return (response as List).map((e) => PostModel.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // CREATE POST
  // ═══════════════════════════════════════════════════════════════════

  Future<PostModel> createPost(PostModel post) async {
    final response = await _client
        .from(SupabaseConfig.postsTable)
        .insert(post.toJson())
        .select('*, profiles(*)')
        .single();

    return PostModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // UPDATE POST
  // ═════════════════════════════════════════════════════════���═════════

  Future<PostModel> updatePost(String postId, String content, List<String> images) async {
    final response = await _client
        .from(SupabaseConfig.postsTable)
        .update({
      'content': content,
      'images': images,
      'updated_at': DateTime.now().toIso8601String(),
    })
        .eq('id', postId)
        .select('*, profiles(*)')
        .single();

    return PostModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // DELETE POST
  // ═══════════════════════════════════════════════════════════════════

  Future<void> deletePost(String postId) async {
    await _client
        .from(SupabaseConfig.postsTable)
        .update({'is_active': false})
        .eq('id', postId);
  }

  // ═══════════════════════════════════════════════════════════════════
  // LIKE POST
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> toggleLike(String postId, String userId) async {
    final existing = await _client
        .from(SupabaseConfig.postLikesTable)
        .select()
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      // Unlike
      await _client
          .from(SupabaseConfig.postLikesTable)
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
      return false;
    } else {
      // Like
      await _client.from(SupabaseConfig.postLikesTable).insert({
        'post_id': postId,
        'user_id': userId,
      });
      return true;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // CHECK IF LIKED
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> isLikedByUser(String postId, String userId) async {
    final response = await _client
        .from(SupabaseConfig.postLikesTable)
        .select()
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();

    return response != null;
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET COMMENTS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<PostCommentModel>> getComments(String postId) async {
    final response = await _client
        .from(SupabaseConfig.postCommentsTable)
        .select('*, profiles(*)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return (response as List).map((e) => PostCommentModel.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════════════��═══
  // ADD COMMENT
  // ═══════════════════════════════════════════════════════════════════

  Future<PostCommentModel> addComment(String postId, String userId, String content) async {
    final response = await _client
        .from(SupabaseConfig.postCommentsTable)
        .insert({
      'post_id': postId,
      'user_id': userId,
      'content': content,
    })
        .select('*, profiles(*)')
        .single();

    return PostCommentModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // DELETE COMMENT
  // ═══════════════════════════════════════════════════════════════════

  Future<void> deleteComment(String commentId) async {
    await _client
        .from(SupabaseConfig.postCommentsTable)
        .delete()
        .eq('id', commentId);
  }
}