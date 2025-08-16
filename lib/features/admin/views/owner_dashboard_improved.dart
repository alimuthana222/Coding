import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/admin_provider.dart';
import '../models/admin_stats_model.dart';
import '../widgets/stats_card_widget.dart';
import '../widgets/recent_activities_widget.dart';
import '../widgets/pending_requests_widget.dart';

class OwnerDashboardImproved extends ConsumerStatefulWidget {
  const OwnerDashboardImproved({super.key});

  @override
  ConsumerState<OwnerDashboardImproved> createState() => _OwnerDashboardImprovedState();
}

class _OwnerDashboardImprovedState extends ConsumerState<OwnerDashboardImproved> {
  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(adminStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('لوحة تحكم المالك'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_rounded),
            onPressed: () => context.push('/admin/notifications'),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_rounded),
                    SizedBox(width: 8.w),
                    Text('الإعدادات'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'backup',
                child: Row(
                  children: [
                    Icon(Icons.backup_rounded),
                    SizedBox(width: 8.w),
                    Text('النسخ الاحتياطي'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logs',
                child: Row(
                  children: [
                    Icon(Icons.history_rounded),
                    SizedBox(width: 8.w),
                    Text('سجل النشاطات'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(adminStatsProvider);
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(context, isDark),
              
              SizedBox(height: 24.h),
              
              // Quick Actions
              _buildQuickActions(context, isDark),
              
              SizedBox(height: 24.h),
              
              // Statistics Cards
              statsAsync.when(
                data: (stats) => _buildStatsSection(context, stats, isDark),
                loading: () => _buildStatsLoading(isDark),
                error: (error, stack) => _buildErrorState(context, error.toString()),
              ),
              
              SizedBox(height: 24.h),
              
              // Management Sections
              _buildManagementSections(context, isDark),
              
              SizedBox(height: 24.h),
              
              // Recent Activities
              RecentActivitiesWidget(),
              
              SizedBox(height: 24.h),
              
              // Pending Requests
              PendingRequestsWidget(),
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
              ? [AppTheme.primaryColor.withOpacity(0.8), AppTheme.secondaryColor.withOpacity(0.8)]
              : [AppTheme.primaryColor, AppTheme.secondaryColor],
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
                  'مالك التطبيق',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'إدارة شاملة لجميع جوانب التطبيق',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.admin_panel_settings_rounded,
            size: 48.w,
            color: Colors.white70,
          ),
        ],
      ),
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
              icon: Icons.people_rounded,
              title: 'إدارة المستخدمين',
              subtitle: 'عرض وإدارة المستخدمين',
              color: AppTheme.primaryColor,
              onTap: () => context.push('/admin/users'),
              isDark: isDark,
            ),
            _buildQuickActionCard(
              context,
              icon: Icons.account_balance_wallet_rounded,
              title: 'طلبات الإيداع',
              subtitle: 'مراجعة طلبات الإيداع',
              color: AppTheme.successColor,
              onTap: () => context.push('/admin/deposit-requests'),
              isDark: isDark,
            ),
            _buildQuickActionCard(
              context,
              icon: Icons.report_rounded,
              title: 'البلاغات',
              subtitle: 'مراجعة البلاغات',
              color: AppTheme.errorColor,
              onTap: () => context.push('/admin/reports'),
              isDark: isDark,
            ),
            _buildQuickActionCard(
              context,
              icon: Icons.supervisor_account_rounded,
              title: 'إدارة المشرفين',
              subtitle: 'إضافة وإدارة المشرفين',
              color: AppTheme.accentColor,
              onTap: () => context.push('/admin/moderators'),
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

  Widget _buildStatsSection(BuildContext context, AdminStatsModel stats, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات عامة',
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
            StatsCardWidget(
              title: 'إجمالي المستخدمين',
              value: stats.totalUsers.toString(),
              icon: Icons.people_rounded,
              color: AppTheme.primaryColor,
              trend: stats.userGrowth,
            ),
            StatsCardWidget(
              title: 'الخدمات النشطة',
              value: stats.activeServices.toString(),
              icon: Icons.work_rounded,
              color: AppTheme.successColor,
              trend: stats.serviceGrowth,
            ),
            StatsCardWidget(
              title: 'إجمالي الإيرادات',
              value: '\$${stats.totalRevenue.toStringAsFixed(0)}',
              icon: Icons.attach_money_rounded,
              color: AppTheme.warningColor,
              trend: stats.revenueGrowth,
            ),
            StatsCardWidget(
              title: 'المعاملات اليوم',
              value: stats.todayTransactions.toString(),
              icon: Icons.trending_up_rounded,
              color: AppTheme.accentColor,
              trend: stats.transactionGrowth,
            ),
          ],
        ),
      ],
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

  Widget _buildManagementSections(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إدارة التطبيق',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        _buildManagementCard(
          context,
          icon: Icons.content_paste_rounded,
          title: 'إدارة المحتوى',
          subtitle: 'المنشورات، التعليقات، والفعاليات',
          onTap: () => context.push('/admin/content'),
          isDark: isDark,
        ),
        SizedBox(height: 12.h),
        _buildManagementCard(
          context,
          icon: Icons.payment_rounded,
          title: 'إدارة المدفوعات',
          subtitle: 'المحافظ، التحويلات، والعمولات',
          onTap: () => context.push('/admin/payments'),
          isDark: isDark,
        ),
        SizedBox(height: 12.h),
        _buildManagementCard(
          context,
          icon: Icons.analytics_rounded,
          title: 'التقارير والتحليلات',
          subtitle: 'تقارير مفصلة وإحصائيات متقدمة',
          onTap: () => context.push('/admin/analytics'),
          isDark: isDark,
        ),
        SizedBox(height: 12.h),
        _buildManagementCard(
          context,
          icon: Icons.settings_applications_rounded,
          title: 'إعدادات التطبيق',
          subtitle: 'إعدادات عامة وتخصيص التطبيق',
          onTap: () => context.push('/admin/app-settings'),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildManagementCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
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
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24.w,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.w,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
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
            onPressed: () => ref.refresh(adminStatsProvider),
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'settings':
        context.push('/admin/settings');
        break;
      case 'backup':
        _showBackupDialog();
        break;
      case 'logs':
        context.push('/admin/logs');
        break;
    }
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('النسخ الاحتياطي'),
        content: Text('هل تريد إنشاء نسخة احتياطية من البيانات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _createBackup();
            },
            child: Text('إنشاء نسخة احتياطية'),
          ),
        ],
      ),
    );
  }

  void _createBackup() {
    // Implement backup functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('جاري إنشاء النسخة الاحتياطية...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}

