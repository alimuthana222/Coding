import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_button.dart';
import '../models/event_model.dart';
import '../providers/events_provider.dart';

class CreateEventView extends ConsumerStatefulWidget {
  const CreateEventView({super.key});

  @override
  ConsumerState<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends ConsumerState<CreateEventView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxAttendeesController = TextEditingController();

  EventType _selectedType = EventType.workshop;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isOnline = false;

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventsNotifierProvider);

    ref.listen(eventsNotifierProvider, (previous, next) {
      if (next is EventsSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      } else if (next is EventsError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    });

    return Scaffold(
      appBar: const CustomAppBar(title: 'Create Event'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Event Title',
                hintText: 'Enter event title',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hintText: 'Describe your event...',
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              _buildEventTypeSelector(),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Checkbox(
                    value: _isOnline,
                    onChanged: (value) {
                      setState(() {
                        _isOnline = value ?? false;
                      });
                    },
                  ),
                  const Text('Online Event'),
                ],
              ),
              if (!_isOnline) ...[
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _locationController,
                  label: 'Location',
                  hintText: 'Enter event location',
                  validator: (value) {
                    if (!_isOnline && (value == null || value.isEmpty)) {
                      return 'Please enter event location';
                    }
                    return null;
                  },
                ),
              ],
              SizedBox(height: 16.h),
              CustomTextField(
                controller: _maxAttendeesController,
                label: 'Maximum Attendees',
                hintText: 'Enter maximum number of attendees',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter maximum attendees';
                  }
                  final attendees = int.tryParse(value);
                  if (attendees == null || attendees <= 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32.h),
              LoadingButton(
                onPressed: _handleCreateEvent,
                isLoading: eventsState is EventsLoading,
                text: 'Create Event',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Type',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<EventType>(
          value: _selectedType,
          onChanged: (type) {
            if (type != null) {
              setState(() {
                _selectedType = type;
              });
            }
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          items: EventType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(_getEventTypeLabel(type)),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _handleCreateEvent() {
    if (_formKey.currentState!.validate()) {
      // For now, using placeholder dates
      final now = DateTime.now();
      ref.read(eventsNotifierProvider.notifier).createEvent(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        startDate: now.add(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 1, hours: 2)),
        location: _isOnline ? null : _locationController.text.trim(),
        maxAttendees: int.parse(_maxAttendeesController.text),
        isOnline: _isOnline,
      );
    }
  }

  String _getEventTypeLabel(EventType type) {
    switch (type) {
      case EventType.workshop:
        return 'Workshop';
      case EventType.seminar:
        return 'Seminar';
      case EventType.networking:
        return 'Networking';
      case EventType.conference:
        return 'Conference';
      case EventType.other:
        return 'Other';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxAttendeesController.dispose();
    super.dispose();
  }
}