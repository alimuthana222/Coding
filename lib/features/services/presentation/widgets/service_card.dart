import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/service_model.dart';
import '../screens/service_details_screen.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isOffering = service.serviceType == ServiceType.offering;
    final isHoursBased = service.pricingType == PricingType.hours;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailsScreen(service: service),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with badges
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isOffering ? AppColors.success : AppColors.info).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusXl),
                ),
              ),
              child: Row(
                children: [
                  // Service Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isOffering ? AppColors.success : AppColors.info,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isOffering ? Iconsax.export_3 : Iconsax.import_1,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOffering ? 'أعرض خدمة' : 'أطلب خدمة',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Pricing Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isHoursBased ? Iconsax.clock : Iconsax.money,
                          size: 14,
                          color: isHoursBased ? AppColors.secondary : AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          service.priceLabel,
                          style: TextStyle(
                            color: isHoursBased ? AppColors.secondary : AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    service.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    service.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Category
                  if (service.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        service.category!.nameAr,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Footer - User & Stats
                  Row(
                    children: [
                      // User
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: colorScheme.primaryContainer,
                        backgroundImage: service.user?.avatarUrl != null
                            ? NetworkImage(service.user!.avatarUrl!)
                            : null,
                        child: service.user?.avatarUrl == null
                            ? Icon(
                          Iconsax.user,
                          size: 16,
                          color: colorScheme.primary,
                        )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.user?.fullName ?? 'مستخدم',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (service.user != null && service.user!.providerRating > 0)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 12,
                                    color: AppColors.star,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    service.user!.providerRating.toStringAsFixed(1),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      // Stats
                      Row(
                        children: [
                          Icon(
                            Iconsax.eye,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${service.views}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (service.rating > 0) ...[
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: AppColors.star,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              service.rating.toStringAsFixed(1),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}