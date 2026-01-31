import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/models/message_model.dart';
import '../../../../shared/widgets/auth_guard.dart';
import '../../bloc/messages_cubit.dart';
import '../../bloc/messages_state.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MessagesCubit(),
      child: const _MessagesView(),
    );
  }
}

class _MessagesView extends StatelessWidget {
  const _MessagesView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Check if logged in
    if (!SupabaseConfig.isAuthenticated) {
      return _buildLoginRequired(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('messages')),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Iconsax.edit),
            onPressed: () {
              // New conversation
            },
          ),
        ],
      ),
      body: BlocBuilder<MessagesCubit, MessagesState>(
        builder: (context, state) {
          if (state.status == MessagesStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == MessagesStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.warning_2, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? 'حدث خطأ'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<MessagesCubit>().refresh(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.message,
                    size: 64,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد محادثات',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ابدأ محادثة جديدة مع أحد المستخدمين',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<MessagesCubit>().refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.conversations.length,
              itemBuilder: (context, index) {
                final conversation = state.conversations[index];
                return _ConversationItem(conversation: conversation);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginRequired(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('messages')),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.lock,
                  size: 48,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'تسجيل الدخول مطلوب',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'سجل دخولك للوصول إلى رسائلك',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => requireAuth(context, () {}),
                  child: Text(context.t('login')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CONVERSATION ITEM
// ═══════════════════════════════════════════════════════════════════

class _ConversationItem extends StatelessWidget {
  final ConversationModel conversation;

  const _ConversationItem({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = conversation.otherUser;
    final hasUnread = conversation.unreadCount > 0;

    return GestureDetector(
      onTap: () {
        if (user != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                otherUserId: user.id,
                otherUserName: user.fullName,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: hasUnread
              ? colorScheme.primaryContainer.withOpacity(0.3)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage: user?.avatarUrl != null
                    ? NetworkImage(user!.avatarUrl!)
                    : null,
                child: user?.avatarUrl == null
                    ? Icon(Iconsax.user, color: colorScheme.primary)
                    : null,
              ),
              if (user?.isOnline == true)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  user?.fullName ?? 'مستخدم',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _formatLastMessageTime(conversation.lastMessageAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: hasUnread
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  conversation.lastMessage?.content ?? 'ابدأ المحادثة',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: hasUnread
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                    fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
              if (hasUnread)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${conversation.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLastMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'الآن';
    if (difference.inHours < 1) return 'منذ ${difference.inMinutes} د';
    if (difference.inDays < 1) return 'منذ ${difference.inHours} س';
    if (difference.inDays < 7) return 'منذ ${difference.inDays} ي';
    return '${dateTime.day}/${dateTime.month}';
  }
}