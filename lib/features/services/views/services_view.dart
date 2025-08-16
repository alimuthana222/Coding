import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../generated/l10n.dart';

class ServicesView extends ConsumerStatefulWidget {
  const ServicesView({super.key});

  @override
  ConsumerState<ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends ConsumerState<ServicesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.services,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: تنفيذ البحث
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: تنفيذ التصفية
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          tabs: [
            Tab(text: l10n.serviceOffer),
            Tab(text: l10n.serviceRequest),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildServiceOffers(),
          _buildServiceRequests(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateServiceDialog(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          l10n.createService,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildServiceOffers() {
    return RefreshIndicator(
      onRefresh: () async {
        // TODO: تحديث العروض
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 5, // بيانات وهمية
        itemBuilder: (context, index) {
          return _buildServiceCard(
            title: 'تصميم تطبيقات الموبايل',
            description: 'أقوم بتصميم وتطوير تطبيقات الموبايل باستخدام Flutter',
            price: '50000',
            providerName: 'أحمد محمد',
            rating: 4.8,
            isOffer: true,
          );
        },
      ),
    );
  }

  Widget _buildServiceRequests() {
    return RefreshIndicator(
      onRefresh: () async {
        // TODO: تحديث الطلبات
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 3, // بيانات وهمية
        itemBuilder: (context, index) {
          return _buildServiceCard(
            title: 'مطلوب مصمم جرافيك',
            description: 'أحتاج لتصميم شعار ومواد تسويقية لشركتي الناشئة',
            price: '30000',
            providerName: 'سارة أحمد',
            rating: null,
            isOffer: false,
          );
        },
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String description,
    required String price,
    required String providerName,
    required double? rating,
    required bool isOffer,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isOffer
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  isOffer ? 'عرض خدمة' : 'طلب خدمة',
                  style: TextStyle(
                    color: isOffer ? AppTheme.successColor : AppTheme.infoColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$price د.ع',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  providerName[0],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  providerName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (rating != null) ...[
                Icon(
                  Icons.star,
                  color: AppTheme.warningColor,
                  size: 16.w,
                ),
                SizedBox(width: 4.w),
                Text(
                  rating.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.warningColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: عرض التفاصيل
                  },
                  child: const Text('التفاصيل'),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: تواصل أو حجز
                  },
                  child: Text(isOffer ? 'احجز الآن' : 'تقدم للطلب'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateServiceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 12.h),
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'إنشاء خدمة جديدة',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  _buildCreateServiceOption(
                    icon: Icons.work_outline,
                    title: 'تقديم خدمة',
                    subtitle: 'أقدم خدمة أو مهارة للآخرين',
                    color: AppTheme.successColor,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/services/create?type=offer');
                    },
                  ),
                  SizedBox(height: 16.h),
                  _buildCreateServiceOption(
                    icon: Icons.search,
                    title: 'طلب خدمة',
                    subtitle: 'أحتاج خدمة أو مهارة معينة',
                    color: AppTheme.infoColor,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/services/create?type=request');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateServiceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: color,
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
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16.w,
            ),
          ],
        ),
      ),
    );
  }
}