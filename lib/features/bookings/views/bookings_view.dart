import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';

class BookingsView extends ConsumerStatefulWidget {
  const BookingsView({super.key});

  @override
  ConsumerState<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends ConsumerState<BookingsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(bookingsProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Bookings',
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Bookings'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Bookings Tab
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(bookingsProvider);
            },
            child: bookings.when(
              data: (bookings) => currentUser.when(
                data: (user) => _buildBookingsList(
                  context,
                  bookings.where((b) => b.clientId == user?.id).toList(),
                  true,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Error loading user data')),
              ),
              loading: () => _buildBookingsLoading(),
              error: (error, stack) => _buildErrorState(context, error.toString()),
            ),
          ),
          // Booking Requests Tab
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(bookingsProvider);
            },
            child: bookings.when(
              data: (bookings) => currentUser.when(
                data: (user) => _buildBookingsList(
                  context,
                  bookings.where((b) => b.providerId == user?.id).toList(),
                  false,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Error loading user data')),
              ),
              loading: () => _buildBookingsLoading(),
              error: (error, stack) => _buildErrorState(context, error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(BuildContext context, List<BookingModel> bookings, bool isClient) {
    if (bookings.isEmpty) {
      return _buildEmptyState(context, isClient);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return FadeInUp(
          delay: Duration(milliseconds: index * 100),
          child: Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: _buildBookingCard(context, bookings[index], isClient),
          ),
        );
      },
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking, bool isClient) {
    return GestureDetector(
      onTap: () => context.go('/bookings/${booking.id}'),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: AppTheme.primaryColor,
                    backgroundImage: (isClient ? booking.providerAvatar : booking.clientAvatar) != null
                        ? NetworkImage(isClient ? booking.providerAvatar! : booking.clientAvatar!)
                        : null,
                    child: (isClient ? booking.providerAvatar : booking.clientAvatar) == null
                        ? Text(
                      (isClient ? booking.providerName : booking.clientName)
                          ?.substring(0, 1).toUpperCase() ?? 'U',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                          booking.serviceName ?? 'Service',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          isClient
                              ? 'Provider: ${booking.providerName ?? 'Unknown'}'
                              : 'Client: ${booking.clientName ?? 'Unknown'}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: booking.getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: booking.getStatusColor()),
                    ),
                    child: Text(
                      booking.getStatusLabel(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: booking.getStatusColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: AppTheme.textSecondaryColor,
                    size: 16.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _formatDateTime(booking.scheduledDate),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(width: 24.w),
                  Icon(
                    Icons.timer,
                    color: AppTheme.textSecondaryColor,
                    size: 16.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${booking.durationHours} hours',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${booking.totalAmount.toStringAsFixed(0)} IQD',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      if (!isClient && booking.status == BookingStatus.pending) ...[
                        ElevatedButton(
                          onPressed: () => _confirmBooking(context, booking.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            minimumSize: Size.zero,
                          ),
                          child: const Text('Confirm'),
                        ),
                        SizedBox(width: 8.w),
                      ],
                      if (booking.status == BookingStatus.confirmed) ...[
                        ElevatedButton(
                          onPressed: () => _startBooking(context, booking.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            minimumSize: Size.zero,
                          ),
                          child: const Text('Start'),
                        ),
                        SizedBox(width: 8.w),
                      ],
                      if (booking.status == BookingStatus.inProgress) ...[
                        ElevatedButton(
                          onPressed: () => _completeBooking(context, booking.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            minimumSize: Size.zero,
                          ),
                          child: const Text('Complete'),
                        ),
                        SizedBox(width: 8.w),
                      ],
                      OutlinedButton(
                        onPressed: () => context.go('/bookings/${booking.id}'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsLoading() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          height: 150.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12.r),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isClient) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64.w,
            color: AppTheme.textSecondaryColor,
          ),
          SizedBox(height: 16.h),
          Text(
            isClient ? 'No bookings yet' : 'No booking requests yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            isClient
                ? 'Book a service to see your bookings here'
                : 'Booking requests will appear here',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.w,
            color: AppTheme.errorColor,
          ),
          SizedBox(height: 16.h),
          Text(
            'Error loading bookings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.errorColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.errorColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _confirmBooking(BuildContext context, String bookingId) {
    ref.read(bookingNotifierProvider.notifier).confirmBooking(bookingId);
    ref.invalidate(bookingsProvider);
  }

  void _startBooking(BuildContext context, String bookingId) {
    ref.read(bookingNotifierProvider.notifier).startBooking(bookingId);
    ref.invalidate(bookingsProvider);
  }

  void _completeBooking(BuildContext context, String bookingId) {
    ref.read(bookingNotifierProvider.notifier).completeBooking(bookingId);
    ref.invalidate(bookingsProvider);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}