import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

// Mock activity model
class ActivityModel {
  final String id;
  final String title;
  final String description;
  final String type; // user_action, system, admin_action
  final DateTime timestamp;
  final String? userId;
  final String? userName;
  final IconData icon;
  final Color color;

  const ActivityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    this.userId,
    this.userName,
    required this.icon,
    required this.color,
  });
}

// Mock provider for activities
final recentActivitiesProvider = FutureProvider<List<ActivityModel>>((ref) async {
  // Simulate API call delay
  await Future.delayed(const Duration(milliseconds: 500));

  return [
    ActivityModel(
      id: '1',
      title: 'مستخدم جديد',
      description: 'انضم أحمد محمد إلى التطبيق',
      type: 'user_action',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      userId: 'user1',
      userName: 'أحمد محمد',
      icon: Icons.person_add_rounded,
      color: AppTheme.successColor,
    ),
    ActivityModel(
      id: '2',
      title: 'خدمة جديدة',
      description: 'تم إضافة خدمة تطوير مواقع',
      type: 'user_action',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      userId: 'user2',
      userName: 'سارة أحمد',
      icon: Icons.work_rounded,
      color: AppTheme.primaryColor,
    ),
    ActivityModel(
      id: '3',
      title: 'طلب إيداع',
      description: 'طلب إيداع جديد بقيمة 100 د.ع',
      type: 'user_action',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      userId: 'user3',
      userName: 'محمد علي',
      icon: Icons.account_balance_wallet_rounded,
      color: AppTheme.warningColor,
    ),
    ActivityModel(
      id: '4',
      title: 'تم حل بلاغ',
      description: 'تم حل بلاغ عن محتوى غير مناسب',
      type: 'admin_action',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      icon: Icons.check_circle_rounded,
      color: AppTheme.successColor,
    ),
    ActivityModel(
      id: '5',
      title: 'نسخة احتياطية',
      description: 'تم إنشاء نسخة احتياطية للبيانات',
      type: 'system',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      icon: Icons.backup_rounded,
      color: AppTheme.accentColor,
    ),
  ];
});

class RecentActivitiesWidget extends ConsumerWidget {
  const RecentActivitiesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(recentActivitiesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'النشاطات الأخيرة',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/admin/activities'),
              child: Text('عرض الكل'),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        activitiesAsync.when(
          data: (activities) => _buildActivitiesList(context, activities, isDark),
          loading: () => _buildLoadingState(isDark),
          error: (error, stack) => _buildErrorState(context, error.toString()),
        ),
      ],
    );
  }

  Widget _buildActivitiesList(BuildContext context, List<ActivityModel> activities, bool isDark) {
    if (activities.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

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
        itemCount: activities.length > 5 ? 5 : activities.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return _buildActivityItem(context, activity, isDark);
        },
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, ActivityModel activity, bool isDark) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: CircleAvatar(
        backgroundColor: activity.color.withOpacity(0.1),
        radius: 20.r,
        child: Icon(
          activity.icon,
          color: activity.color,
          size: 20.w,
        ),
      ),
      title: Text(
        activity.title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activity.description,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            _getTimeAgo(activity.timestamp),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
      trailing: _buildActivityTypeChip(context, activity.type, isDark),
      onTap: () => _showActivityDetails(context, activity),
    );
  }

  Widget _buildActivityTypeChip(BuildContext context, String type, bool isDark) {
    Color chipColor;
    String chipLabel;

    switch (type) {
      case 'user_action':
        chipColor = AppTheme.primaryColor;
        chipLabel = 'مستخدم';
        break;
      case 'admin_action':
        chipColor = AppTheme.accentColor;
        chipLabel = 'إدارة';
        break;
      case 'system':
        chipColor = AppTheme.successColor;
        chipLabel = 'نظام';
        break;
      default:
        chipColor = AppTheme.primaryColor;
        chipLabel = 'عام';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        chipLabel,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: chipColor,
          fontWeight: FontWeight.w500,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      height: 300.h,
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
            'خطأ في تحميل النشاطات',
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
            'لا توجد نشاطات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }

  void _showActivityDetails(BuildContext context, ActivityModel activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(activity.icon, color: activity.color),
            SizedBox(width: 8.w),
            Text('تفاصيل النشاط'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('العنوان:', activity.title),
            _buildDetailRow('الوصف:', activity.description),
            _buildDetailRow('النوع:', activity.type),
            if (activity.userName != null)
              _buildDetailRow('المستخدم:', activity.userName!),
            _buildDetailRow('الوقت:', _getTimeAgo(activity.timestamp)),
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