import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../models/post_model.dart';
import '../providers/community_provider.dart';
import 'create_post_view.dart';

class CommunityView extends ConsumerWidget {
  const CommunityView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Community',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePostView()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(postsProvider);
        },
        child: posts.when(
          data: (posts) => _buildPostsList(context, ref, posts),
          loading: () => _buildPostsLoading(),
          error: (error, stack) => _buildErrorState(context, error.toString()),
        ),
      ),
    );
  }

  Widget _buildPostsList(BuildContext context, WidgetRef ref, List<PostModel> posts) {
    if (posts.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return FadeInUp(
          delay: Duration(milliseconds: index * 100),
          child: Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: _buildPostCard(context, ref, posts[index]),
          ),
        );
      },
    );
  }

  Widget _buildPostCard(BuildContext context, WidgetRef ref, PostModel post) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostHeader(context, post),
            SizedBox(height: 12.h),
            _buildPostContent(context, post),
            if (post.imageUrls.isNotEmpty) ...[
              SizedBox(height: 12.h),
              _buildPostImages(context, post.imageUrls),
            ],
            SizedBox(height: 16.h),
            _buildPostActions(context, ref, post),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context, PostModel post) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: AppTheme.primaryColor,
          backgroundImage: post.authorAvatar != null
              ? NetworkImage(post.authorAvatar!)
              : null,
          child: post.authorAvatar == null
              ? Text(
            post.authorName?.substring(0, 1).toUpperCase() ?? 'U',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          )
              : null,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName ?? 'Unknown User',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatDate(post.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showPostOptions(context, post),
        ),
      ],
    );
  }

  Widget _buildPostContent(BuildContext context, PostModel post) {
    return Text(
      post.content,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        height: 1.5,
      ),
    );
  }

  Widget _buildPostImages(BuildContext context, List<String> imageUrls) {
    if (imageUrls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: CachedNetworkImage(
          imageUrl: imageUrls.first,
          width: double.infinity,
          height: 200.h,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200.h,
            color: AppTheme.surfaceColor,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200.h,
            color: AppTheme.surfaceColor,
            child: const Icon(Icons.error),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(right: 8.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: CachedNetworkImage(
                imageUrl: imageUrls[index],
                width: 120.w,
                height: 120.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 120.w,
                  height: 120.h,
                  color: AppTheme.surfaceColor,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 120.w,
                  height: 120.h,
                  color: AppTheme.surfaceColor,
                  child: const Icon(Icons.error),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostActions(BuildContext context, WidgetRef ref, PostModel post) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => ref.read(communityNotifierProvider.notifier).likePost(post.id),
          child: Row(
            children: [
              Icon(
                post.isLiked ? Icons.favorite : Icons.favorite_border,
                color: post.isLiked ? AppTheme.errorColor : AppTheme.textSecondaryColor,
                size: 20.w,
              ),
              SizedBox(width: 4.w),
              Text(
                '${post.likesCount}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        SizedBox(width: 24.w),
        GestureDetector(
          onTap: () => _showCommentsBottomSheet(context, ref, post),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: AppTheme.textSecondaryColor,
                size: 20.w,
              ),
              SizedBox(width: 4.w),
              Text(
                '${post.commentsCount}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const Spacer(),
        IconButton(
          icon: Icon(
            Icons.share,
            color: AppTheme.textSecondaryColor,
            size: 20.w,
          ),
          onPressed: () => _sharePost(context, post),
        ),
      ],
    );
  }

  Widget _buildPostsLoading() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          height: 200.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12.r),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 64.w,
            color: AppTheme.textSecondaryColor,
          ),
          SizedBox(height: 16.h),
          Text(
            'No posts yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Be the first to share something with the community!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePostView()),
            ),
            child: const Text('Create Post'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.w,
            color: AppTheme.errorColor,
          ),
          SizedBox(height: 16.h),
          Text(
            'Error loading posts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.errorColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.errorColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showPostOptions(BuildContext context, PostModel post) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _sharePost(context, post);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement report functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sharePost(BuildContext context, PostModel post) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _showCommentsBottomSheet(BuildContext context, WidgetRef ref, PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Text(
                  'Comments',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final comments = ref.watch(postCommentsProvider(post.id));
                      return comments.when(
                        data: (comments) => ListView.builder(
                          controller: scrollController,
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 16.r,
                                backgroundColor: AppTheme.primaryColor,
                                backgroundImage: comment.authorAvatar != null
                                    ? NetworkImage(comment.authorAvatar!)
                                    : null,
                                child: comment.authorAvatar == null
                                    ? Text(
                                  comment.authorName?.substring(0, 1).toUpperCase() ?? 'U',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                  ),
                                )
                                    : null,
                              ),
                              title: Text(comment.authorName ?? 'Unknown User'),
                              subtitle: Text(comment.content),
                              trailing: Text(
                                _formatDate(comment.createdAt),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            );
                          },
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Center(child: Text('Error: $error')),
                      );
                    },
                  ),
                ),
                // TODO: Add comment input field
              ],
            ),
          );
        },
      ),
    );
  }
}