import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../generated/l10n.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                // Welcome Section
                currentUserAsync.when(
                  data: (user) => _buildWelcomeSection(context, user?.fullName ?? 'مستخدم'),
                  loading: () => _buildWelcomeSection(context, 'مستخدم'),
                  error: (_, __) => _buildWelcomeSection(context, 'مستخدم'),
                ),

                SizedBox(height: 24.h),

                // Stats Cards
                _buildStatsSection(context, currentUserAsync),

                SizedBox(height: 32.h),

                // Featured Services Section
                Text(
                  'الخدمات المميزة',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),

                SizedBox(height: 16.h),

                _buildFeaturedServices(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, String userName) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.getCardGradientStart(context, 'wallet'),
            AppTheme.getCardGradientEnd(context, 'wallet'),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً، $userName',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'أهلاً بك مرة أخرى',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondaryColor,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, AsyncValue currentUserAsync) {
    return currentUserAsync.when(
      data: (user) => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.access_time,
                  iconColor: Colors.white,
                  iconBgColor: AppTheme.getIconColor('timebank'),
                  title: 'بنك الوقت',
                  value: '${user?.timeBalance ?? 0} س',
                  bgColor: AppTheme.getCardGradientStart(context, 'timebank'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.account_balance_wallet,
                  iconColor: Colors.white,
                  iconBgColor: AppTheme.getIconColor('wallet'),
                  title: 'المحفظة',
                  value: '${user?.walletBalance.toStringAsFixed(0) ?? '0'} د.ع',
                  bgColor: AppTheme.getCardGradientStart(context, 'wallet'),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.star,
                  iconColor: Colors.white,
                  iconBgColor: AppTheme.getIconColor('reviews'),
                  title: 'التقييمات',
                  value: '${user?.reviewCount ?? 0}',
                  bgColor: AppTheme.getCardGradientStart(context, 'reviews'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.star_rate,
                  iconColor: Colors.white,
                  iconBgColor: AppTheme.getIconColor('rating'),
                  title: 'التقييم',
                  value: '${user?.rating.toStringAsFixed(1) ?? '0.0'}',
                  bgColor: AppTheme.getCardGradientStart(context, 'rating'),
                ),
              ),
            ],
          ),
        ],
      ),
      loading: () => _buildStatsLoading(),
      error: (_, __) => _buildStatsPlaceholder(context),
    );
  }

  Widget _buildStatCard(
      BuildContext context, {
        required IconData icon,
        required Color iconColor,
        required Color iconBgColor,
        required String title,
        required String value,
        required Color bgColor,
      }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12.sp,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsLoading() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCardSkeleton()),
            SizedBox(width: 12.w),
            Expanded(child: _buildStatCardSkeleton()),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _buildStatCardSkeleton()),
            SizedBox(width: 12.w),
            Expanded(child: _buildStatCardSkeleton()),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCardSkeleton() {
    return Container(
      height: 72.h,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 20.w,
          height: 20.h,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsPlaceholder(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.access_time,
                iconColor: Colors.white,
                iconBgColor: AppTheme.getIconColor('timebank'),
                title: 'بنك الوقت',
                value: '0 س',
                bgColor: AppTheme.getCardGradientStart(context, 'timebank'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.account_balance_wallet,
                iconColor: Colors.white,
                iconBgColor: AppTheme.getIconColor('wallet'),
                title: 'المحفظة',
                value: '0 د.ع',
                bgColor: AppTheme.getCardGradientStart(context, 'wallet'),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.star,
                iconColor: Colors.white,
                iconBgColor: AppTheme.getIconColor('reviews'),
                title: 'التقييمات',
                value: '0',
                bgColor: AppTheme.getCardGradientStart(context, 'reviews'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.star_rate,
                iconColor: Colors.white,
                iconBgColor: AppTheme.getIconColor('rating'),
                title: 'التقييم',
                value: '0.0',
                bgColor: AppTheme.getCardGradientStart(context, 'rating'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturedServices(BuildContext context) {
    final services = [
      {
        'title': 'تطوير المواقع',
        'subtitle': 'تطوير',
        'icon': Icons.web,
        'colorType': 'webdev',
      },
      {
        'title': 'التصميم الجرافيكي',
        'subtitle': 'تصميم',
        'icon': Icons.design_services,
        'colorType': 'design',
      },
      {
        'title': 'تحرير الصوت',
        'subtitle': 'صوتيات',
        'icon': Icons.audiotrack,
        'colorType': 'audio',
      },
    ];

    return Column(
      children: services.map((service) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          child: _buildServiceCard(
            context,
            title: service['title'] as String,
            subtitle: service['subtitle'] as String,
            icon: service['icon'] as IconData,
            colorType: service['colorType'] as String,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildServiceCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required String colorType,
      }) {
    final iconColor = AppTheme.getIconColor(colorType);
    final bgColor = Theme.of(context).cardColor;
    
    return GestureDetector(
      onTap: () {
        context.push('/services');
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppTheme.borderColor.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28.w,
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
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textSecondaryColor,
              size: 16.w,
            ),
          ],
        ),
      ),
    );
  }
}