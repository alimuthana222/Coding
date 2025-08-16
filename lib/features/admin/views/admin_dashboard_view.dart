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

class AdminDashboardView extends ConsumerStatefulWidget {
  const AdminDashboardView({super.key});

  @override
  ConsumerState<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends ConsumerState<AdminDashboardView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final adminStats = ref.watch(adminStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الإدارة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_rounded),
            onPressed: () => context.push('/admin/notifications'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings_rounded),
                    SizedBox(width: 8.w),
                    const Text('الإعدادات'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'backup',
                child: Row(
                  children: [
                    const Icon(Icons.backup_rounded),
                    SizedBox(width: 8.w),
                    const Text('النسخ الاحتياطي'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'reports',
                child: Row(
                  children: [
                    const Icon(Icons.analytics_rounded),
                    SizedBox(width: 8.w),
                    const Text('التقارير'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded), text: 'الرئيسية'),
            Tab(icon: Icon(Icons.people_rounded), text: 'المستخدمين'),
            Tab(icon: Icon(Icons.work_rounded), text: 'الخدمات'),
            Tab(icon: Icon(Icons.analytics_rounded), text: 'التحليلات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMainDashboard(context, adminStats, isDark),
          _buildUsersTab(context, isDark),
          _buildServicesTab(context, isDark),
          _buildAnalyticsTab(context, isDark),
        ],
      ),
    );
  }

  Widget _buildMainDashboard(BuildContext context, AsyncValue<AdminStatsModel> adminStats, bool isDark) {
    return RefreshIndicator(
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

            // Statistics Section
            adminStats.when(
              data: (stats) => _buildStatsSection(context, stats, isDark),
              loading: () => _buildStatsLoading(isDark),
              error: (error, stack) => _buildErrorState(context, error.toString()),
            ),

            SizedBox(height: 24.h),

            // Recent Activities
            const RecentActivitiesWidget(),

            SizedBox(height: 24.h),

            // Pending Requests
            const PendingRequestsWidget(),
          ],
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
              ? [
            AppTheme.primaryColor.withValues(alpha: 0.8),
            AppTheme.accentColor.withValues(alpha: 0.8)
          ]
              : [AppTheme.primaryColor, AppTheme.accentColor],
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
                  'مرحباً بك في لوحة التحكم',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'إدارة التطبيق',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'تحكم كامل في جميع جوانب التطبيق والمستخدمين',
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
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.5,
          children: [
            _buildQuickActionCard(
              context,
              icon: Icons.people_rounded,
              title: 'إدارة المستخدمين',
              subtitle: '${_getUsersCount()} مستخدم نشط',
              color: AppTheme.primaryColor,
              onTap: () => context.push('/admin/users'),
              isDark: isDark,
            ),
            _buildQuickActionCard(
              context,
              icon: Icons.account_balance_wallet_rounded,
              title: 'طلبات الإيداع',
              subtitle: 'مراجعة الطلبات المعلقة',
              color: AppTheme.successColor,
              onTap: () => context.push('/admin/deposit-requests'),
              isDark: isDark,
            ),
            _buildQuickActionCard(
              context,
              icon: Icons.work_rounded,
              title: 'إدارة الخدمات',
              subtitle: 'الخدمات النشطة والمعلقة',
              color: AppTheme.accentColor,
              onTap: () => context.push('/admin/services'),
              isDark: isDark,
            ),
            _buildQuickActionCard(
              context,
              icon: Icons.report_rounded,
              title: 'البلاغات',
              subtitle: 'مراجعة البلاغات الجديدة',
              color: AppTheme.errorColor,
              onTap: () => context.push('/admin/reports'),
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
            color: color.withValues(alpha: 0.3),
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
          'إحصائيات شاملة',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
              trend: 15.5,
            ),
            StatsCardWidget(
              title: 'الخدمات النشطة',
              value: stats.activeServices.toString(),
              icon: Icons.work_rounded,
              color: AppTheme.successColor,
              trend: 8.3,
            ),
            StatsCardWidget(
              title: 'إجمالي الإيرادات',
              value: '${stats.totalRevenue.toStringAsFixed(0)} د.ع',
              icon: Icons.attach_money_rounded,
              color: AppTheme.warningColor,
              trend: 23.1,
            ),
            StatsCardWidget(
              title: 'الحجوزات المكتملة',
              value: stats.completedBookings.toString(),
              icon: Icons.check_circle_rounded,
              color: AppTheme.accentColor,
              trend: 12.7,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsLoading(bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 1.2,
      children: List.generate(4, (index) => Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      )),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
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
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إدارة المستخدمين',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          _buildUserManagementSection(context, isDark),
        ],
      ),
    );
  }

  Widget _buildServicesTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إدارة الخدمات',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          _buildServiceManagementSection(context, isDark),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التحليلات والتقارير',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          _buildAnalyticsSection(context, isDark),
        ],
      ),
    );
  }

  Widget _buildUserManagementSection(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildManagementButton(
                context,
                icon: Icons.person_add_rounded,
                title: 'إضافة مستخدم',
                onTap: () => context.push('/admin/users/add'),
                color: AppTheme.primaryColor,
              ),
              _buildManagementButton(
                context,
                icon: Icons.verified_user_rounded,
                title: 'توثيق المستخدمين',
                onTap: () => context.push('/admin/users/verification'),
                color: AppTheme.successColor,
              ),
              _buildManagementButton(
                context,
                icon: Icons.block_rounded,
                title: 'المستخدمون المحظورون',
                onTap: () => context.push('/admin/users/banned'),
                color: AppTheme.errorColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceManagementSection(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildManagementButton(
                context,
                icon: Icons.pending_actions_rounded,
                title: 'الخدمات المعلقة',
                onTap: () => context.push('/admin/services/pending'),
                color: AppTheme.warningColor,
              ),
              _buildManagementButton(
                context,
                icon: Icons.check_circle_rounded,
                title: 'الخدمات المعتمدة',
                onTap: () => context.push('/admin/services/approved'),
                color: AppTheme.successColor,
              ),
              _buildManagementButton(
                context,
                icon: Icons.category_rounded,
                title: 'إدارة التصنيفات',
                onTap: () => context.push('/admin/categories'),
                color: AppTheme.accentColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildManagementButton(
                context,
                icon: Icons.trending_up_rounded,
                title: 'تقرير النمو',
                onTap: () => context.push('/admin/analytics/growth'),
                color: AppTheme.primaryColor,
              ),
              _buildManagementButton(
                context,
                icon: Icons.attach_money_rounded,
                title: 'تقرير الإيرادات',
                onTap: () => context.push('/admin/analytics/revenue'),
                color: AppTheme.successColor,
              ),
              _buildManagementButton(
                context,
                icon: Icons.assessment_rounded,
                title: 'تقرير شامل',
                onTap: () => context.push('/admin/analytics/comprehensive'),
                color: AppTheme.accentColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManagementButton(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        required Color color,
      }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 24.w,
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
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
      case 'reports':
        context.push('/admin/reports');
        break;
    }
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إنشاء نسخة احتياطية'),
        content: const Text('هل تريد إنشاء نسخة احتياطية من البيانات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _createBackup();
            },
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
  }

  void _createBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('جاري إنشاء النسخة الاحتياطية...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  String _getUsersCount() {
    // Get from admin stats if available
    final adminStatsAsync = ref.read(adminStatsProvider);
    return adminStatsAsync.when(
      data: (stats) => stats.totalUsers.toString(),
      loading: () => '...',
      error: (_, __) => '0',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}