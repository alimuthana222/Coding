import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/service_model.dart';
import '../../bloc/bookings_cubit.dart';
import '../../bloc/bookings_state.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingsCubit(),
      child: const _BookingsView(),
    );
  }
}

class _BookingsView extends StatefulWidget {
  const _BookingsView();

  @override
  State<_BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<_BookingsView>
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حجوزاتي'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: 'طلباتي'),
            Tab(text: 'الطلبات الواردة'),
          ],
        ),
      ),
      body: BlocBuilder<BookingsCubit, BookingsState>(
        builder: (context, state) {
          if (state.status == BookingsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _BookingsList(
                bookings: state.myRequests,
                isMyRequests: true,
                emptyMessage: 'لم تقدم أي طلبات بعد',
              ),
              _BookingsList(
                bookings: state.myOffers,
                isMyRequests: false,
                emptyMessage: 'لم تصلك أي طلبات بعد',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final List<ServiceBookingModel> bookings;
  final bool isMyRequests;
  final String emptyMessage;

  const _BookingsList({
    required this.bookings,
    required this.isMyRequests,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.clipboard_text,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<BookingsCubit>().refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _BookingCard(
            booking: booking,
            isMyRequest: isMyRequests,
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final ServiceBookingModel booking;
  final bool isMyRequest;

  const _BookingCard({
    required this.booking,
    required this.isMyRequest,
  });

  Color get _statusColor {
    switch (booking.status) {
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.accepted:
        return AppColors.info;
      case BookingStatus.inProgress:
        return AppColors.secondary;
      case BookingStatus.completed:
        return AppColors.success;
      case BookingStatus.cancelled:
      case BookingStatus.rejected:
        return AppColors.error;
      case BookingStatus.disputed:
        return AppColors.error;
    }
  }

  IconData get _statusIcon {
    switch (booking.status) {
      case BookingStatus.pending:
        return Iconsax.clock;
      case BookingStatus.accepted:
        return Iconsax.tick_circle;
      case BookingStatus.inProgress:
        return Iconsax.activity;
      case BookingStatus.completed:
        return Iconsax.verify;
      case BookingStatus.cancelled:
      case BookingStatus.rejected:
        return Iconsax.close_circle;
      case BookingStatus.disputed:
        return Iconsax.warning_2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isHoursBased = booking.pricingType == PricingType.hours;

    return Container(
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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusXl),
              ),
            ),
            child: Row(
              children: [
                Icon(_statusIcon, color: _statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  booking.statusLabel,
                  style: TextStyle(
                    color: _statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isHoursBased ? Iconsax.clock : Iconsax.money,
                        size: 14,
                        color: isHoursBased ? AppColors.secondary : AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        booking.priceLabel,
                        style: TextStyle(
                          color: isHoursBased ? AppColors.secondary : AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
                // Service Title
                Text(
                  booking.service?.title ?? 'خدمة',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Other User
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        Iconsax.user,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMyRequest ? 'مقدم الخدمة' : 'طالب الخدمة',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          isMyRequest
                              ? booking.provider?.fullName ?? 'مستخدم'
                              : booking.client?.fullName ?? 'مستخدم',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Message
                if (booking.clientMessage != null && booking.clientMessage!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Iconsax.message,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            booking.clientMessage!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Actions
                if (!isMyRequest && booking.status == BookingStatus.pending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            context.read<BookingsCubit>().rejectBooking(booking.id);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                          child: const Text('رفض'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<BookingsCubit>().acceptBooking(booking.id);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                          ),
                          child: const Text('قبول'),
                        ),
                      ),
                    ],
                  ),
                ],

                if (!isMyRequest && booking.status == BookingStatus.accepted) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<BookingsCubit>().startBooking(booking.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                      ),
                      child: const Text('بدء العمل'),
                    ),
                  ),
                ],

                if (!isMyRequest && booking.status == BookingStatus.inProgress) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<BookingsCubit>().completeBooking(booking);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                      child: const Text('إتمام الخدمة'),
                    ),
                  ),
                ],

                // Review Button
                if (booking.status == BookingStatus.completed &&
                    isMyRequest &&
                    booking.clientRating == null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showReviewDialog(context, booking),
                      icon: const Icon(Iconsax.star),
                      label: const Text('أضف تقييم'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context, ServiceBookingModel booking) {
    int rating = 5;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تقييم الخدمة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => setState(() => rating = index + 1),
                    icon: Icon(
                      index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: AppColors.star,
                      size: 36,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'تعليقك (اختياري)',
                  hintText: 'اكتب تعليقك عن الخدمة...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await context.read<BookingsCubit>().addReview(
                  bookingId: booking.id,
                  rating: rating,
                  review: reviewController.text.isNotEmpty
                      ? reviewController.text
                      : null,
                  isClientReview: true,
                );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }

                if (context.mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('شكراً على تقييمك! ⭐'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('إرسال'),
            ),
          ],
        ),
      ),
    );
  }
}