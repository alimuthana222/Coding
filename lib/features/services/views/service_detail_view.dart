import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../models/service_model.dart';
import '../providers/services_provider.dart';

class ServiceDetailView extends ConsumerWidget {
  final String serviceId;

  const ServiceDetailView({
    super.key,
    required this.serviceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceDetail = ref.watch(serviceDetailProvider(serviceId));

    return Scaffold(
      appBar: const CustomAppBar(title: 'Service Details'),
      body: serviceDetail.when(
        data: (service) => _buildServiceDetail(context, service),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () => ref.invalidate(serviceDetailProvider(serviceId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: serviceDetail.when(
        data: (service) => _buildBottomBar(context, service),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildServiceDetail(BuildContext context, ServiceModel service) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageGallery(service.imageUrls),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildServiceHeader(context, service),
                SizedBox(height: 16.h),
                _buildProviderInfo(context, service),
                SizedBox(height: 24.h),
                _buildServiceDescription(context, service),
                SizedBox(height: 24.h),
                _buildServiceTags(context, service),
                SizedBox(height: 24.h),
                _buildServiceStats(context, service),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return Container(
        height: 200.h,
        width: double.infinity,
        color: AppTheme.surfaceColor,
        child: Icon(
          Icons.image,
          size: 64.w,
          color: AppTheme.textSecondaryColor,
        ),
      );
    }

    return SizedBox(
      height: 200.h,
      child: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: imageUrls[index],
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppTheme.surfaceColor,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppTheme.surfaceColor,
              child: Icon(
                Icons.error,
                size: 64.w,
                color: AppTheme.errorColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceHeader(BuildContext context, ServiceModel service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                service.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _getCategoryColor(service.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                _getCategoryLabel(service.category),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: _getCategoryColor(service.category),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Icon(
              Icons.star,
              color: AppTheme.warningColor,
              size: 20.w,
            ),
            SizedBox(width: 4.w),
            Text(
              '${service.rating.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '(${service.reviewCount} reviews)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const Spacer(),
            Text(
              '${service.hourlyRate.toStringAsFixed(0)} IQD/hour',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProviderInfo(BuildContext context, ServiceModel service) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: AppTheme.primaryColor,
            backgroundImage: service.providerAvatar != null
                ? NetworkImage(service.providerAvatar!)
                : null,
            child: service.providerAvatar == null
                ? Text(
              service.providerName?.substring(0, 1).toUpperCase() ?? 'U',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
            )
                : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.providerName ?? 'Unknown Provider',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: AppTheme.warningColor,
                      size: 16.w,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${service.providerRating?.toStringAsFixed(1) ?? '0.0'} Provider Rating',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '${service.totalOrders} completed orders',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              // TODO: Navigate to provider profile
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              minimumSize: Size.zero,
            ),
            child: const Text('View Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDescription(BuildContext context, ServiceModel service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 12.h),
        Text(
          service.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceTags(BuildContext context, ServiceModel service) {
    if (service.tags.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills & Tags',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: service.tags.map((tag) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Text(
                tag,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildServiceStats(BuildContext context, ServiceModel service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Statistics',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Orders',
                '${service.totalOrders}',
                Icons.shopping_cart,
                AppTheme.primaryColor,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                context,
                'Rating',
                '${service.rating.toStringAsFixed(1)}',
                Icons.star,
                AppTheme.warningColor,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                context,
                'Reviews',
                '${service.reviewCount}',
                Icons.rate_review,
                AppTheme.accentColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
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
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ServiceModel service) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // TODO: Start chat with provider
              },
              child: const Text('Message'),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Book service
                _showBookingDialog(context, service);
              },
              child: const Text('Book Now'),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(BuildContext context, ServiceModel service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Service'),
        content: Text('Book "${service.title}" for ${service.hourlyRate} IQD/hour?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to booking form
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.programming:
        return 'Programming';
      case ServiceCategory.design:
        return 'Design';
      case ServiceCategory.writing:
        return 'Writing';
      case ServiceCategory.marketing:
        return 'Marketing';
      case ServiceCategory.tutoring:
        return 'Tutoring';
      case ServiceCategory.consultation:
        return 'Consultation';
      case ServiceCategory.other:
        return 'Other';
    }
  }

  Color _getCategoryColor(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.programming:
        return Colors.blue;
      case ServiceCategory.design:
        return Colors.purple;
      case ServiceCategory.writing:
        return Colors.green;
      case ServiceCategory.marketing:
        return Colors.orange;
      case ServiceCategory.tutoring:
        return Colors.red;
      case ServiceCategory.consultation:
        return Colors.teal;
      case ServiceCategory.other:
        return Colors.grey;
    }
  }
}