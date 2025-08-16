import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/app_config.dart';
import '../models/post_model.dart';

class CommunityService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<PostModel>> getPosts({
    int limit = 20,
    int offset = 0,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('posts')
        .select('''
          *,
          profiles:author_id (
            full_name,
            avatar_url
          ),
          post_likes!left (
            user_id
          )
        ''')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return response.map<PostModel>((json) {
      final profileData = json['profiles'] as Map<String, dynamic>?;
      final likes = json['post_likes'] as List<dynamic>? ?? [];
      final isLiked = likes.any((like) => like['user_id'] == user.id);

      return PostModel.fromJson({
        ...json,
        'author_name': profileData?['full_name'],
        'author_avatar': profileData?['avatar_url'],
        'is_liked': isLiked,
      });
    }).toList();
  }

  Future<List<CommentModel>> getPostComments(String postId) async {
    final response = await _supabase
        .from('post_comments')
        .select('''
          *,
          profiles:author_id (
            full_name,
            avatar_url
          )
        ''')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return response.map<CommentModel>((json) {
      final profileData = json['profiles'] as Map<String, dynamic>?;
      return CommentModel.fromJson({
        ...json,
        'author_name': profileData?['full_name'],
        'author_avatar': profileData?['avatar_url'],
      });
    }).toList();
  }

  Future<void> createPost({
    required String content,
    List<String>? imagePaths,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    List<String> imageUrls = [];
    if (imagePaths != null && imagePaths.isNotEmpty) {
      imageUrls = await _uploadPostImages(imagePaths);
    }

    await _supabase.from('posts').insert({
      'author_id': user.id,
      'content': content,
      'image_urls': imageUrls,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> likePost(String postId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check if already liked
    final existingLike = await _supabase
        .from('post_likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', user.id)
        .maybeSingle();

    if (existingLike != null) {
      // Unlike
      await _supabase
          .from('post_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', user.id);
    } else {
      // Like
      await _supabase.from('post_likes').insert({
        'post_id': postId,
        'user_id': user.id,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    // Update likes count
    await _supabase.rpc('update_post_likes_count', params: {
      'post_id': postId,
    });
  }

  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabase.from('post_comments').insert({
      'post_id': postId,
      'author_id': user.id,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Update comments count
    await _supabase.rpc('update_post_comments_count', params: {
      'post_id': postId,
    });
  }

  Future<List<String>> _uploadPostImages(List<String> imagePaths) async {
    final List<String> imageUrls = [];

    for (final imagePath in imagePaths) {
      final file = File(imagePath);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imagePaths.indexOf(imagePath)}.jpg';

      await _supabase.storage
          .from('post-images')
          .upload(fileName, file);

      final imageUrl = _supabase.storage
          .from('post-images')
          .getPublicUrl(fileName);

      imageUrls.add(imageUrl);
    }

    return imageUrls;
  }
}