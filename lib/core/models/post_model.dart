import 'package:equatable/equatable.dart';
import 'user_model.dart';

// ═══════════════════════════════════════════════════════════════════
// POST MODEL
// ═══════════════════════════════════════════════════════════════════

class PostModel extends Equatable {
  final String id;
  final String userId;
  final String content;
  final List<String> images;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final UserModel? user;
  final bool? isLikedByMe;

  const PostModel({
    required this.id,
    required this.userId,
    required this.content,
    this.images = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.isLikedByMe,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      images: List<String>.from(json['images'] ?? []),
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      sharesCount: json['shares_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      user: json['profiles'] != null ? UserModel.fromJson(json['profiles']) : null,
      isLikedByMe: json['is_liked_by_me'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'content': content,
      'images': images,
    };
  }

  PostModel copyWith({
    String? id,
    String? userId,
    String? content,
    List<String>? images,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? user,
    bool? isLikedByMe,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      images: images ?? this.images,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }

  // Time ago helper
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) return 'الآن';
    if (difference.inMinutes < 60) return 'منذ ${difference.inMinutes} دقيقة';
    if (difference.inHours < 24) return 'منذ ${difference.inHours} ساعة';
    if (difference.inDays < 7) return 'منذ ${difference.inDays} يوم';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  @override
  List<Object?> get props => [
    id, userId, content, images, likesCount, commentsCount, sharesCount,
    isActive, createdAt, updatedAt, isLikedByMe,
  ];
}

// ═══════════════════════════════════════════════════════════════════
// POST COMMENT MODEL
// ═════════════════════════════════════════════════��═════════════════

class PostCommentModel extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final int likesCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? user;

  const PostCommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.likesCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    return PostCommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      likesCount: json['likes_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      user: json['profiles'] != null ? UserModel.fromJson(json['profiles']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'user_id': userId,
      'content': content,
    };
  }

  @override
  List<Object?> get props => [id, postId, userId, content, likesCount, createdAt, updatedAt];
}