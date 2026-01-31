import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/models/post_model.dart';
import '../../../../shared/widgets/auth_guard.dart';
import '../../bloc/posts_cubit.dart';
import '../../bloc/posts_state.dart';

class PostsScreen extends StatelessWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostsCubit(),
      child: const _PostsView(),
    );
  }
}

class _PostsView extends StatefulWidget {
  const _PostsView();

  @override
  State<_PostsView> createState() => _PostsViewState();
}

class _PostsViewState extends State<_PostsView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PostsCubit>().loadMorePosts();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('posts')),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<PostsCubit, PostsState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => context.read<PostsCubit>().refresh(),
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Create Post Card
                _CreatePostCard(
                  onTap: () => _showCreatePostSheet(context),
                ),
                const SizedBox(height: 16),

                // Loading State
                if (state.status == PostsStatus.loading && state.posts.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                // Error State
                else if (state.status == PostsStatus.error && state.posts.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Iconsax.warning_2, size: 64, color: colorScheme.error),
                          const SizedBox(height: 16),
                          Text(state.errorMessage ?? 'حدث خطأ'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.read<PostsCubit>().refresh(),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  )
                // Empty State
                else if (state.posts.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Iconsax.document,
                              size: 64,
                              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              context.t('no_posts'),
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.t('be_first_post'),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    )
                  // Posts List
                  else ...[
                      ...state.posts.map((post) => _PostCard(post: post)),
                      if (!state.hasReachedMax)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          requireAuth(context, () {
            _showCreatePostSheet(context);
          });
        },
        backgroundColor: colorScheme.primary,
        child: const Icon(Iconsax.edit, color: Colors.white),
      ),
    );
  }

  void _showCreatePostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<PostsCubit>(),
        child: const _CreatePostSheet(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CREATE POST CARD
// ═══════════════════════════════════════════════════════════════════

class _CreatePostCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CreatePostCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        requireAuth(context, onTap);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(Iconsax.user, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: Text(
                  context.t('whats_on_your_mind'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(Iconsax.image, color: colorScheme.primary, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// POST CARD
// ═══════════════════════════════════════════════════════════════════

class _PostCard extends StatelessWidget {
  final PostModel post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLiked = post.isLikedByMe ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colorScheme.primaryContainer,
                  backgroundImage: post.user?.avatarUrl != null
                      ? NetworkImage(post.user!.avatarUrl!)
                      : null,
                  child: post.user?.avatarUrl == null
                      ? Icon(Iconsax.user, color: colorScheme.primary, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.user?.fullName ?? 'مستخدم',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        post.timeAgo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (post.userId == SupabaseConfig.currentUserId)
                  PopupMenuButton<String>(
                    icon: const Icon(Iconsax.more, size: 20),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteDialog(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Iconsax.trash, color: AppColors.error, size: 20),
                            SizedBox(width: 8),
                            Text('حذف'),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  IconButton(
                    icon: const Icon(Iconsax.more, size: 20),
                    onPressed: () {},
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.content,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),

          // Images
          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: post.images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      child: Image.network(
                        post.images[index],
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 200,
                          height: 200,
                          color: colorScheme.surfaceContainerHighest,
                          child: const Icon(Iconsax.image),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  isLiked ? Iconsax.heart5 : Iconsax.heart,
                  size: 16,
                  color: isLiked ? AppColors.error : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.likesCount}',
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  '${post.commentsCount} ${context.t('comments')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: colorScheme.outlineVariant.withOpacity(0.5)),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      requireAuth(context, () {
                        context.read<PostsCubit>().toggleLike(post.id);
                      });
                    },
                    icon: Icon(
                      isLiked ? Iconsax.heart5 : Iconsax.heart,
                      size: 20,
                      color: isLiked ? AppColors.error : colorScheme.onSurfaceVariant,
                    ),
                    label: Text(
                      context.t('like'),
                      style: TextStyle(
                        color: isLiked ? AppColors.error : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      requireAuth(context, () {
                        _showCommentsSheetForPost(context, post);
                      });
                    },
                    icon: Icon(
                      Iconsax.message,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    label: Text(
                      context.t('comment'),
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      requireAuth(context, () {
                        _handleSharePostAction(context, post);
                      });
                    },
                    icon: Icon(
                      Iconsax.share,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    label: Text(
                      context.t('share'),
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف المنشور'),
        content: const Text('هل أنت متأكد من حذف هذا المنشور؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PostsCubit>().deletePost(post.id);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CREATE POST SHEET
// ═══════════════════════════════════════════════════════════════════

class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet();

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.t('cancel')),
                ),
                const Spacer(),
                Text(
                  context.t('create_post'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                BlocBuilder<PostsCubit, PostsState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state.isCreating
                          ? null
                          : () async {
                        if (_contentController.text.trim().isEmpty) return;

                        final success = await context
                            .read<PostsCubit>()
                            .createPost(_contentController.text);

                        if (success && context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: state.isCreating
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : Text(context.t('post')),
                    );
                  },
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant.withOpacity(0.5)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(Iconsax.user, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: context.t('whats_on_your_mind'),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant.withOpacity(0.5)),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            child: Row(
              children: [
                _PostActionButton(icon: Iconsax.image, color: AppColors.success),
                const SizedBox(width: 16),
                _PostActionButton(icon: Iconsax.video, color: AppColors.error),
                const SizedBox(width: 16),
                _PostActionButton(icon: Iconsax.link, color: AppColors.info),
                const SizedBox(width: 16),
                _PostActionButton(icon: Iconsax.location, color: AppColors.warning),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _PostActionButton({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// STANDALONE HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════

void _showCommentsSheetForPost(BuildContext context, PostModel post) {
  final commentController = TextEditingController();
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'التعليقات',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            
            // Comments list
            Expanded(
              child: FutureBuilder<List<PostCommentModel>>(
                future: context.read<PostsCubit>().getComments(post.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.message,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد تعليقات بعد',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  final comments = snapshot.data!;
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: comment.user?.avatarUrl != null
                              ? NetworkImage(comment.user!.avatarUrl!)
                              : null,
                          child: comment.user?.avatarUrl == null
                              ? Text(comment.user?.initials ?? '?')
                              : null,
                        ),
                        title: Text(comment.user?.fullName ?? 'Unknown'),
                        subtitle: Text(comment.content),
                      );
                    },
                  );
                },
              ),
            ),
            
            // Comment input
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: 'اكتب تعليق...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Iconsax.send_1),
                    color: AppColors.primary,
                    onPressed: () async {
                      if (commentController.text.trim().isEmpty) return;
                      
                      final success = await context.read<PostsCubit>().addComment(
                        post.id,
                        commentController.text.trim(),
                      );
                      
                      if (success) {
                        commentController.clear();
                        // Refresh the sheet to show new comment
                        Navigator.pop(context);
                        _showCommentsSheetForPost(sheetContext, post);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _handleSharePostAction(BuildContext context, PostModel post) {
  context.read<PostsCubit>().sharePost(post.id);
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('تم مشاركة المنشور'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}