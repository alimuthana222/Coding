import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../models/event_model.dart';
import '../providers/events_provider.dart';

class EventDetailView extends ConsumerWidget {
  final String eventId;

  const EventDetailView({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventDetail = ref.watch(eventDetailProvider(eventId));

    return Scaffold(
      appBar: const CustomAppBar(title: 'Event Details'),
      body: eventDetail.when(
        data: (event) => _buildEventDetail(context, ref, event),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () => ref.invalidate(eventDetailProvider(eventId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventDetail(BuildContext context, WidgetRef ref, EventModel event) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 8.h),
          Text(
            'Organized by ${event.organizerName ?? 'Unknown'}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            event.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => ref.read(eventsNotifierProvider.notifier).rsvpToEvent(event.id),
            child: const Text('RSVP'),
          ),
        ],
      ),
    );
  }
}