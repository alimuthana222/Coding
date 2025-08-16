import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';

class BookingDetailView extends ConsumerWidget {
  final String bookingId;

  const BookingDetailView({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingDetail = ref.watch(bookingDetailProvider(bookingId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Booking Details'),
      body: bookingDetail.when(
        data: (booking) => currentUser.when(
          data: (user) => _buildBookingDetail(context, ref, booking, user?.id),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Error loading user data')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () => ref.invalidate(bookingDetailProvider(bookingId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingDetail(BuildContext context, WidgetRef ref, BookingModel booking, String? currentUserId) {
    final isClient = booking.clientId == currentUserId;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(context, booking),
          SizedBox(height: 24.h),
          _buildServiceCard(context, booking),
          SizedBox(height: 24.h),
          _buildParticipantCard(context, booking, isClient),
          SizedBox(height: 24.h),
          _buildBookingDetails(context, booking),
          if (booking.notes != null && booking.notes!.isNotEmpty) ...[
            SizedBox(height: 24.h),
            _buildNotesCard(context, booking),
          ],
          if (booking.cancellationReason != null && booking.cancellationReason!.isNotEmpty) ...[
            SizedBox(height: 24.h),
            _buildCancellationCard(context, booking),
          ],
          SizedBox(height: 32.h),
          _buildActionButtons(context, ref, booking, isClient),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, BookingModel booking) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: booking.getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: booking.getStatusColor()),
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(booking.status),
            color: booking.getStatusColor(),
            size: 48.w,
          ),
          SizedBox(height: 12.h),
          Text(
            booking.getStatusLabel(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: booking.getStatusColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _getStatusDescription(booking.status),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: booking.getStatusColor(),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, BookingModel booking) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(
                  Icons.work,
                  color: AppTheme.primaryColor,
                  size: 24.w,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    booking.serviceName ?? 'Service',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppTheme.primaryColor,
                  size: 24.w,
                ),
                SizedBox(width: 12.w),
                Text(
                  _formatDateTime(booking.scheduledDate),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Icons.timer,
                  color: AppTheme.primaryColor,
                  size: 24.w,
                ),
                SizedBox(width: 12.w),
                Text(
                  '${booking.durationHours} hours',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  color: AppTheme.primaryColor,
                  size: 24.w,
                ),
                SizedBox(width: 12.w),
                Text(
                  '${booking.totalAmount.toStringAsFixed(0)} IQD',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantCard(BuildContext context, BookingModel booking, bool isClient) {
    final participantName = isClient ? booking.providerName : booking.clientName;
    final participantAvatar = isClient ? booking.providerAvatar : booking.clientAvatar;
    final participantRole = isClient ? 'Service Provider' : 'Client';

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              participantRole,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                CircleAvatar(
                  radius: 32.r,
                  backgroundColor: AppTheme.primaryColor,
                  backgroundImage: participantAvatar != null
                      ? NetworkImage(participantAvatar)
                      : null,
                  child: participantAvatar == null
                      ? Text(
                    participantName?.substring(0, 1).toUpperCase() ?? 'U',
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
                        participantName ?? 'Unknown User',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        participantRole,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    // TODO: Start conversation with participant
                  },
                  child: const Text('Message'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetails(BuildContext context, BookingModel booking) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16.h),
            _buildDetailRow(context, 'Booking ID', booking.id),
            _buildDetailRow(context, 'Created', _formatDateTime(booking.createdAt)),
            _buildDetailRow(context, 'Last Updated', _formatDateTime(booking.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context, BookingModel booking) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 12.h),
            Text(
              booking.notes!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancellationCard(BuildContext context, BookingModel booking) {
    return Card(
      color: AppTheme.errorColor.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cancel,
                  color: AppTheme.errorColor,
                  size: 24.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Cancellation Reason',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              booking.cancellationReason!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, BookingModel booking, bool isClient) {
    List<Widget> buttons = [];

    if (!isClient && booking.status == BookingStatus.pending) {
      buttons.addAll([
        Expanded(
          child: ElevatedButton(
            onPressed: () => _confirmBooking(context, ref, booking.id),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
            child: const Text('Confirm Booking'),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showCancelDialog(context, ref, booking.id),
            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Decline'),
          ),
        ),
      ]);
    } else if (booking.status == BookingStatus.confirmed) {
      buttons.addAll([
        Expanded(
          child: ElevatedButton(
            onPressed: () => _startBooking(context, ref, booking.id),
            child: const Text('Start Session'),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showCancelDialog(context, ref, booking.id),
            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Cancel'),
          ),
        ),
      ]);
    } else if (booking.status == BookingStatus.inProgress) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _completeBooking(context, ref, booking.id),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
            child: const Text('Complete Session'),
          ),
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(children: buttons);
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.pending;
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.inProgress:
        return Icons.play_circle;
      case BookingStatus.completed:
        return Icons.done_all;
      case BookingStatus.cancelled:
        return Icons.cancel;
      case BookingStatus.refunded:
        return Icons.money_off;
    }
  }

  String _getStatusDescription(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Waiting for provider confirmation';
      case BookingStatus.confirmed:
        return 'Booking confirmed and scheduled';
      case BookingStatus.inProgress:
        return 'Session is currently active';
      case BookingStatus.completed:
        return 'Session completed successfully';
      case BookingStatus.cancelled:
        return 'Booking has been cancelled';
      case BookingStatus.refunded:
        return 'Payment has been refunded';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _confirmBooking(BuildContext context, WidgetRef ref, String bookingId) {
    ref.read(bookingNotifierProvider.notifier).confirmBooking(bookingId);
    ref.invalidate(bookingDetailProvider(bookingId));
  }

  void _startBooking(BuildContext context, WidgetRef ref, String bookingId) {
    ref.read(bookingNotifierProvider.notifier).startBooking(bookingId);
    ref.invalidate(bookingDetailProvider(bookingId));
  }

  void _completeBooking(BuildContext context, WidgetRef ref, String bookingId) {
    ref.read(bookingNotifierProvider.notifier).completeBooking(bookingId);
    ref.invalidate(bookingDetailProvider(bookingId));
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, String bookingId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for cancellation:'),
            SizedBox(height: 16.h),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Cancellation reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                ref.read(bookingNotifierProvider.notifier).cancelBooking(
                  bookingId,
                  reasonController.text.trim(),
                );
                ref.invalidate(bookingDetailProvider(bookingId));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }
}