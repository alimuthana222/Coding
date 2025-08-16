import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../services/community_service.dart';

final communityServiceProvider = Provider<CommunityService>((ref) {
  return CommunityService();
});

final postsProvider = FutureProvider<List<PostModel>>((ref) async {
  final communityService = ref.read(communityServiceProvider);
  return communityService.getPosts();
});

final postCommentsProvider = FutureProvider.family<List<CommentModel>, String>((ref, postId) async {
  final communityService = ref.read(communityServiceProvider);
  return communityService.getPostComments(postId);
});

final communityNotifierProvider = StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
  return CommunityNotifier(ref.read(communityServiceProvider));
});

class CommunityNotifier extends StateNotifier<CommunityState> {
  final CommunityService _communityService;

  CommunityNotifier(this._communityService) : super(const CommunityInitial());

  Future<void> createPost({
    required String content,
    List<String>? imagePaths,
  }) async {
    state = const CommunityLoading();
    try {
      await _communityService.createPost(
        content: content,
        imagePaths: imagePaths,
      );
      state = const CommunitySuccess('Post created successfully');
    } catch (e) {
      state = CommunityError(e.toString());
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await _communityService.likePost(postId);
    } catch (e) {
      state = CommunityError(e.toString());
    }
  }

  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    state = const CommunityLoading();
    try {
      await _communityService.addComment(
        postId: postId,
        content: content,
      );
      state = const CommunitySuccess('Comment added successfully');
    } catch (e) {
      state = CommunityError(e.toString());
    }
  }
}

// Define the state classes
abstract class CommunityState {
  const CommunityState();
}

class CommunityInitial extends CommunityState {
  const CommunityInitial();
}

class CommunityLoading extends CommunityState {
  const CommunityLoading();
}

class CommunitySuccess extends CommunityState {
  final String message;
  const CommunitySuccess(this.message);
}

class CommunityError extends CommunityState {
  final String message;
  const CommunityError(this.message);
}