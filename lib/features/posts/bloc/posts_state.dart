import 'package:equatable/equatable.dart';
import '../../../core/models/post_model.dart';

enum PostsStatus { initial, loading, loaded, error }

class PostsState extends Equatable {
  final PostsStatus status;
  final List<PostModel> posts;
  final String? errorMessage;
  final bool hasReachedMax;
  final int currentPage;
  final bool isCreating;
  final List<PostCommentModel> comments;
  final bool isLoadingComments;
  final bool isAddingComment;

  const PostsState({
    this.status = PostsStatus.initial,
    this.posts = const [],
    this.errorMessage,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.isCreating = false,
    this.comments = const [],
    this.isLoadingComments = false,
    this.isAddingComment = false,
  });

  PostsState copyWith({
    PostsStatus? status,
    List<PostModel>? posts,
    String? errorMessage,
    bool? hasReachedMax,
    int? currentPage,
    bool? isCreating,
    List<PostCommentModel>? comments,
    bool? isLoadingComments,
    bool? isAddingComment,
  }) {
    return PostsState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isCreating: isCreating ?? this.isCreating,
      comments: comments ?? this.comments,
      isLoadingComments: isLoadingComments ?? this.isLoadingComments,
      isAddingComment: isAddingComment ?? this.isAddingComment,
    );
  }

  @override
  List<Object?> get props => [status, posts, errorMessage, hasReachedMax, currentPage, isCreating, comments, isLoadingComments, isAddingComment];
}