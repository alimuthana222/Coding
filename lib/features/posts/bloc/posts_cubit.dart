import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/repositories/post_repository.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/models/post_model.dart';
import 'posts_state.dart';

class PostsCubit extends Cubit<PostsState> {
  final PostRepository _postRepository = sl<PostRepository>();

  PostsCubit() : super(const PostsState()) {
    loadPosts();
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAD POSTS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> loadPosts() async {
    emit(state.copyWith(status: PostsStatus.loading));

    try {
      final posts = await _postRepository.getPosts();

      emit(state.copyWith(
        status: PostsStatus.loaded,
        posts: posts,
        currentPage: 1,
        hasReachedMax: posts.length < 20,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PostsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ════════════════════════════════════════════���══════════════════════
  // LOAD MORE POSTS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> loadMorePosts() async {
    if (state.hasReachedMax || state.status == PostsStatus.loading) return;

    try {
      final nextPage = state.currentPage + 1;
      final newPosts = await _postRepository.getPosts(page: nextPage);

      emit(state.copyWith(
        posts: [...state.posts, ...newPosts],
        currentPage: nextPage,
        hasReachedMax: newPosts.length < 20,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // CREATE POST
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> createPost(String content, {List<String> images = const []}) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) return false;

    emit(state.copyWith(isCreating: true));

    try {
      final post = PostModel(
        id: '',
        userId: userId,
        content: content,
        images: images,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdPost = await _postRepository.createPost(post);

      emit(state.copyWith(
        isCreating: false,
        posts: [createdPost, ...state.posts],
      ));

      return true;
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // TOGGLE LIKE
  // ═══════════════════════════════════════════════════════════════════

  Future<void> toggleLike(String postId) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) return;

    try {
      final isLiked = await _postRepository.toggleLike(postId, userId);

      final updatedPosts = state.posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            isLikedByMe: isLiked,
            likesCount: isLiked ? post.likesCount + 1 : post.likesCount - 1,
          );
        }
        return post;
      }).toList();

      emit(state.copyWith(posts: updatedPosts));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // DELETE POST
  // ═══════════════════════════════════════════════════════════════════

  Future<void> deletePost(String postId) async {
    try {
      await _postRepository.deletePost(postId);

      final updatedPosts = state.posts.where((p) => p.id != postId).toList();
      emit(state.copyWith(posts: updatedPosts));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // ADD COMMENT
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> addComment(String postId, String content) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) return false;

    try {
      await _postRepository.addComment(postId, userId, content);

      // Update comments count for the post
      final updatedPosts = state.posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(commentsCount: post.commentsCount + 1);
        }
        return post;
      }).toList();

      emit(state.copyWith(posts: updatedPosts));
      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET COMMENTS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<PostCommentModel>> getComments(String postId) async {
    try {
      return await _postRepository.getComments(postId);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // SHARE POST
  // ═══════════════════════════════════════════════════════════════════

  Future<void> sharePost(String postId) async {
    try {
      // Update shares count for the post
      final updatedPosts = state.posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(sharesCount: post.sharesCount + 1);
        }
        return post;
      }).toList();

      emit(state.copyWith(posts: updatedPosts));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // REFRESH
  // ═══════════════════════════════════════════════════════════════════

  Future<void> refresh() async {
    emit(state.copyWith(currentPage: 1, hasReachedMax: false));
    await loadPosts();
  }
}