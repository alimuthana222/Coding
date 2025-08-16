import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/moderator_provider.dart';
import '../models/moderator_stats_model.dart';
import '../widgets/moderation_queue_widget.dart';
import '../widgets/recent_actions_widget.dart';

class ModeratorDashboardImproved extends ConsumerStatefulWidget {
  const ModeratorDashboardImproved({super.key});

  @override
  ConsumerState<ModeratorDashboardImproved> createState() => _ModeratorDashboardImprovedState();
}

class _ModeratorDashboardImprovedState extends ConsumerState<ModeratorDashboardImproved> {
  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(moderatorStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('لوحة تحكم المشرف'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_rounded),
            onPressed: () => context.push('/moderator/notifications'),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'guidelines',
                child: Row(
                  children: [
                    Icon(Icons.rule_rounded),
                    SizedBox(width: 8.w),
                    Text('إرشادات الإشراف'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    Icon(Icons.history_rounded),
                    SizedBox(width: 8.w),
                    Text('سجل الإجراءات'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(moderatorStatsProvider);
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(context, isDark),
              
              SizedBox(height: 24.h),
              
              // Statistics Cards
              statsAsync.when(
                data: (stats) => _buildStatsSection(context, stats, isDark),
                loading: () => _buildStatsLoading(isDark),
                error: (error, stack) => _buildErrorState(context, error.toString()),
              ),
              
              SizedBox(height: 24.h),
              
              // Quick Actions
              _buildQuickActions(context, isDark),
              
              SizedBox(height: 24.h),
              
              // Moderation Queue
              ModerationQueueWidget(),
              
              SizedBox(height: 24.h),
              
              // Recent Actions
              RecentActionsWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppTheme.accentColor.withOpacity(0.8), AppTheme.primaryColor.withOpacity(0.8)]
              : [AppTheme.accentColor, AppTheme.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً بك',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'مشرف المحتوى',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'إدارة المحتوى والحفاظ على جودة التطبيق',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.shield_rounded,
            size: 48.w,
            color: Colors.white70,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, ModeratorStatsModel stats, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات الإشراف',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              context,
              title: 'البلاغات المعلقة',
              value: stats.pendingReports.toString(),
              icon: Icons.report_problem_rounded,
              color: AppTheme.errorColor,
              isDark: isDark,
            ),
            _buildStatCard(
              context,
              title: 'المحتوى للمراجعة',
              value: stats.contentForReview.toString(),
              icon: Icons.rate_review_rounded,
              color: AppTheme.warningColor,
              isDark: isDark,
            ),
            _buildStatCard(
              context,
              title: 'الإجراءات اليوم',
              value: stats.todayActions.toString(),
              icon: Icons.done_all_rounded,
              color: AppTheme.successColor,
              isDark: isDark,
            ),
            _buildStatCard(
              context,
              title: 'المستخدمون المحظورون',
              value: stats.bannedUsers.toString(),
              icon: Icons.block_rounded,
              color: AppTheme.accentColor,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color,
                size: 24.w,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsLoading(bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 1.2,
      children: List.generate(4, (index) => Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12.r),
        ),
      )),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات سريعة',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.5,
          children: [
            _buildQuickActionCard(
              context,
              icon: Icons.report_rounded,
              title: 'مراجعة البلاغات',
              subtitle: 'البلاغات الجديدة والمعلقة',
              color: AppTheme.errorColor,
              onTap: () => context.push('/moderator/reports'),
              isDark: isDark,
            ),
            _buildQuickActionCard(
              context,
              icon: Icons.content_paste_rounded,
              title: 'مراجعة المحتوى',
              subtitle: 'المنشورات والتعليقات',
              color: AppTheme.primaryColor,
              onTap: () => context.push('/moderator/content'),
              isDark: isDark,
            ),
            _buildQuickActionCard(
              context,
              icon: Icons.people_rounded,
              title: 'إدارة المستخدمين',
              subtitle: 'حظر وإلغاء حظر المستخدمين',
              color: AppTheme.accentColor,
              onTap: () => context.push('/moderator/users'),
              isDark: isDark,
            ),
            _buildQuickActionCard(
              context,
              icon: Icons.event_rounded,
              title: 'مراجعة الفعاليات',
              subtitle: 'الفعاليات المقترحة',
              color: AppTheme.successColor,
              onTap: () => context.push('/moderator/events'),
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 32.w,
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
            'خطأ في تحميل الإحصائيات',
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
          SizedBox(height: 12.h),
          ElevatedButton(
            onPressed: () => ref.refresh(moderatorStatsProvider),
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'guidelines':
        _showModerationGuidelines();
        break;
      case 'history':
        context.push('/moderator/action-history');
        break;
    }
  }

  void _showModerationGuidelines() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.rule_rounded, color: AppTheme.accentColor),
            SizedBox(width: 8.w),
            Text('إرشادات الإشراف'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGuidelineSection(
                'البلاغات:',
                [
                  'مراجعة البلاغات خلال 24 ساعة',
                  'التحقق من صحة البلاغ قبل اتخاذ إجراء',
                  'توثيق سبب القرار المتخذ',
                ],
              ),
              SizedBox(height: 12.h),
              _buildGuidelineSection(
                'المحتوى:',
                [
                  'حذف المحتوى المخالف فوراً',
                  'إرسال تحذير للمستخدم عند الحاجة',
                  'الحفاظ على الأدلة للمراجعة',
                ],
              ),
              SizedBox(height: 12.h),
              _buildGuidelineSection(
                'المستخدمون:',
                [
                  'الحظر المؤقت قبل الدائم',
                  'إعطاء فرصة للاستئناف',
                  'التواصل مع الإدارة في الحالات المعقدة',
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('فهمت'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineSection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.accentColor,
          ),
        ),
        SizedBox(height: 4.h),
        ...points.map((point) => Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Text(
            '• $point',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        )),
      ],
    );
  }
}

