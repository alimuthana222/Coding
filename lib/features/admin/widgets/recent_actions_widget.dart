import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/moderator_provider.dart';
import '../models/moderator_action_model.dart';

class RecentActionsWidget extends ConsumerWidget {
  const RecentActionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionsAsync = ref.watch(recentActionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الإجراءات الأخيرة',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/moderator/action-history'),
              child: Text('عرض الكل'),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        actionsAsync.when(
          data: (actions) => _buildActionsList(context, actions, isDark),
          loading: () => _buildLoadingState(isDark),
          error: (error, stack) => _buildErrorState(context, error.toString()),
        ),
      ],
    );
  }

  Widget _buildActionsList(BuildContext context, List<ModeratorActionModel> actions, bool isDark) {
    if (actions.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    final limitedActions = actions.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: limitedActions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
        itemBuilder: (context, index) {
          final action = limitedActions[index];
          return _buildActionItem(context, action, isDark);
        },
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, ModeratorActionModel action, bool isDark) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: CircleAvatar(
        backgroundColor: _getActionColor(action.actionType).withOpacity(0.1),
        child: Icon(
          _getActionIcon(action.actionType),
          color: _getActionColor(action.actionType),
          size: 20.w,
        ),
      ),
      title: Text(
        action.actionTypeDisplayName,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${action.targetTypeDisplayName}: ${action.targetName ?? action.targetId}',
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            'بواسطة: ${action.moderatorName ?? 'مشرف'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
      trailing: Text(
        action.timeAgo,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
        ),
      ),
      onTap: () => _showActionDetails(context, action),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppTheme.errorColor,
            size: 32.w,
          ),
          SizedBox(height: 8.h),
          Text(
            'خطأ في تحميل الإجراءات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.errorColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_rounded,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            size: 48.w,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد إجراءات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'لم يتم تنفيذ أي إجراءات حتى الآن',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getActionColor(String actionType) {
    switch (actionType) {
      case 'ban_user':
        return AppTheme.errorColor;
      case 'unban_user':
        return AppTheme.successColor;
      case 'approve_content':
        return AppTheme.successColor;
      case 'reject_content':
      case 'delete_content':
        return AppTheme.errorColor;
      case 'resolve_report':
        return AppTheme.primaryColor;
      case 'reject_report':
        return AppTheme.warningColor;
      case 'warn_user':
        return AppTheme.warningColor;
      default:
        return AppTheme.accentColor;
    }
  }

  IconData _getActionIcon(String actionType) {
    switch (actionType) {
      case 'ban_user':
        return Icons.block_rounded;
      case 'unban_user':
        return Icons.check_circle_rounded;
      case 'approve_content':
        return Icons.thumb_up_rounded;
      case 'reject_content':
        return Icons.thumb_down_rounded;
      case 'delete_content':
        return Icons.delete_rounded;
      case 'resolve_report':
        return Icons.check_rounded;
      case 'reject_report':
        return Icons.close_rounded;
      case 'warn_user':
        return Icons.warning_rounded;
      default:
        return Icons.admin_panel_settings_rounded;
    }
  }

  void _showActionDetails(BuildContext context, ModeratorActionModel action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل الإجراء'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('الإجراء:', action.actionTypeDisplayName),
            _buildDetailRow('الهدف:', action.targetTypeDisplayName),
            _buildDetailRow('المشرف:', action.moderatorName ?? 'غير معروف'),
            _buildDetailRow('السبب:', action.reason),
            if (action.details != null)
              _buildDetailRow('التفاصيل:', action.details!),
            _buildDetailRow('الوقت:', action.timeAgo),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}