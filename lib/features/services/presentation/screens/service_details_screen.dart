import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/models/service_model.dart';
import '../../../../shared/widgets/auth_guard.dart';
import '../../bloc/services_cubit.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailsScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isOffering = service.serviceType == ServiceType.offering;
    final isHoursBased = service.pricingType == PricingType.hours;
    final isOwner = service.userId == SupabaseConfig.currentUserId;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Iconsax.arrow_right_3, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isOffering
                        ? [AppColors.success, AppColors.success.withOpacity(0.7)]
                        : [AppColors.info, AppColors.info.withOpacity(0.7)],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background Pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Icon(
                          isOffering ? Iconsax.export_3 : Iconsax.import_1,
                          size: 200,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Content
                    Positioned(
                      bottom: 60,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isOffering ? 'عرض خدمة' : 'طلب خدمة',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isHoursBased ? Iconsax.clock : Iconsax.money,
                                      size: 16,
                                      color: isHoursBased
                                          ? AppColors.secondary
                                          : AppColors.success,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      service.priceLabel,
                                      style: TextStyle(
                                        color: isHoursBased
                                            ? AppColors.secondary
                                            : AppColors.success,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    service.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Category
                  if (service.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        service.category!.nameAr,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Stats
                  Row(
                    children: [
                      _StatChip(
                        icon: Iconsax.eye,
                        value: '${service.views}',
                        label: 'مشاهدة',
                      ),
                      const SizedBox(width: 12),
                      _StatChip(
                        icon: Iconsax.shopping_bag,
                        value: '${service.completedBookings}',
                        label: 'مكتمل',
                      ),
                      const SizedBox(width: 12),
                      if (service.rating > 0)
                        _StatChip(
                          icon: Icons.star_rounded,
                          iconColor: AppColors.star,
                          value: service.rating.toStringAsFixed(1),
                          label: '(${service.totalReviews})',
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description Section
                  Text(
                    'الوصف',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      service.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Provider Section
                  Text(
                    isOffering ? 'مقدم الخدمة' : 'طالب الخدمة',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
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
                          radius: 28,
                          backgroundColor: colorScheme.primaryContainer,
                          backgroundImage: service.user?.avatarUrl != null
                              ? NetworkImage(service.user!.avatarUrl!)
                              : null,
                          child: service.user?.avatarUrl == null
                              ? Icon(
                            Iconsax.user,
                            color: colorScheme.primary,
                          )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.user?.fullName ?? 'مستخدم',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (service.user?.university != null)
                                Text(
                                  service.user!.university!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              if (service.user != null &&
                                  service.user!.providerRating > 0)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: AppColors.star,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${service.user!.providerRating.toStringAsFixed(1)} (${service.user!.totalReviews} تقييم)',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Open chat
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Iconsax.message,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Action Button
      bottomNavigationBar: !isOwner
          ? Container(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Price
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'السعر',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        isHoursBased ? Iconsax.clock : Iconsax.money,
                        size: 20,
                        color: isHoursBased
                            ? AppColors.secondary
                            : AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        service.priceLabel,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isHoursBased
                              ? AppColors.secondary
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Button
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  requireAuth(context, () {
                    _showBookingSheet(context);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isOffering ? AppColors.primary : AppColors.info,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: Text(
                  isOffering ? 'طلب الخدمة' : 'تقديم عرض',
                ),
              ),
            ),
          ],
        ),
      )
          : null,
    );
  }

  void _showBookingSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'تأكيد الطلب',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الخدمة:'),
                      Expanded(
                        child: Text(
                          service.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('السعر:'),
                      Text(
                        service.priceLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: service.pricingType == PricingType.hours
                              ? AppColors.secondary
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Message
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'رسالة (اختياري)',
                hintText: 'اكتب رسالة لمقدم الخدمة...',
                alignLabelWithHint: true,
              ),
            ),
            const Spacer(),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  final cubit = context.read<ServicesCubit>();
                  final error = await cubit.bookService(
                    service: service,
                    message: messageController.text.isNotEmpty
                        ? messageController.text
                        : null,
                  );

                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }

                  if (context.mounted) {
                    if (error == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم إرسال الطلب بنجاح! ✅'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
                child: const Text('تأكيد الطلب'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String value;
  final String label;

  const _StatChip({
    required this.icon,
    this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor ?? colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}