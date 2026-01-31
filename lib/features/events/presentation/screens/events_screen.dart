import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/event_model.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../shared/widgets/auth_guard.dart';
import '../../bloc/events_cubit.dart';
import '../../bloc/events_state.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventsCubit(),
      child: const _EventsView(),
    );
  }
}

class _EventsView extends StatefulWidget {
  const _EventsView();

  @override
  State<_EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends State<_EventsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: Text(context.t('events')),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Iconsax.filter),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          tabs: [
            Tab(text: context.t('all_events')),
            Tab(text: context.t('upcoming_events')),
            Tab(text: context.t('my_events')),
          ],
        ),
      ),
      body: BlocBuilder<EventsCubit, EventsState>(
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _EventsList(
                events: state.events,
                status: state.status,
                errorMessage: state.errorMessage,
                onRefresh: () => context.read<EventsCubit>().refresh(),
              ),
              _EventsList(
                events: state.upcomingEvents,
                status: state.status,
                errorMessage: state.errorMessage,
                onRefresh: () => context.read<EventsCubit>().refresh(),
              ),
              _EventsList(
                events: state.myEvents,
                status: state.status,
                errorMessage: state.errorMessage,
                onRefresh: () => context.read<EventsCubit>().loadMyEvents(),
                emptyMessage: 'لم تسجل في أي فعالية بعد',
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          requireAuth(context, () {
            _showCreateEventSheet(context);
          });
        },
        backgroundColor: colorScheme.primary,
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: Text(
          context.t('create_event'),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<EventsCubit>(),
        child: const _FilterSheet(),
      ),
    );
  }

  void _showCreateEventSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<EventsCubit>(),
        child: const _CreateEventSheet(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// EVENTS LIST
// ═══════════════════════════════════════════════════════════════════

class _EventsList extends StatelessWidget {
  final List<EventModel> events;
  final EventsStatus status;
  final String? errorMessage;
  final Future<void> Function() onRefresh;
  final String? emptyMessage;

  const _EventsList({
    required this.events,
    required this.status,
    this.errorMessage,
    required this.onRefresh,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (status == EventsStatus.loading && events.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (status == EventsStatus.error && events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.warning_2, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(errorMessage ?? 'حدث خطأ'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.calendar,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage ?? 'لا توجد فعاليات',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) => _EventCard(event: events[index]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// EVENT CARD
// ═══════════════════════════════════════════════════════════════════

class _EventCard extends StatelessWidget {
  final EventModel event;

  const _EventCard({required this.event});

  Color get _typeColor {
    switch (event.type) {
      case EventType.job:
        return AppColors.info;
      case EventType.workshop:
        return AppColors.success;
      case EventType.conference:
        return AppColors.primary;
      case EventType.webinar:
        return AppColors.secondary;
      case EventType.training:
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }

  IconData get _typeIcon {
    switch (event.type) {
      case EventType.job:
        return Iconsax.briefcase;
      case EventType.workshop:
        return Iconsax.teacher;
      case EventType.conference:
        return Iconsax.people;
      case EventType.webinar:
        return Iconsax.video;
      case EventType.training:
        return Iconsax.book_1;
      default:
        return Iconsax.calendar;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_typeColor, _typeColor.withOpacity(0.7)],
              ),
            ),
            child: Stack(
              children: [
                // Background Icon
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(_typeIcon, size: 150, color: Colors.white),
                  ),
                ),
                // Type Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_typeIcon, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          context.t(event.type.name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Date Box
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${event.startDate.day}',
                          style: TextStyle(
                            color: _typeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          _getMonthName(event.startDate.month),
                          style: TextStyle(color: _typeColor, fontSize: 12),
                        ),
                      ],
                    ),
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
                  event.titleAr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Organizer
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: _typeColor.withOpacity(0.2),
                      child: Icon(Iconsax.user, size: 14, color: _typeColor),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      event.user?.fullName ?? event.companyName ?? 'منظم',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Info Row
                Row(
                  children: [
                    _InfoChip(
                      icon: Iconsax.clock,
                      text: _formatTime(event.startDate),
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    _InfoChip(
                      icon: event.isOnline ? Iconsax.video : Iconsax.location,
                      text: event.isOnline
                          ? context.t('event_online')
                          : event.location ?? '',
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Price & Attendees
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: event.isFree
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event.isFree ? context.t('free') : '${event.price} ${event.currency}',
                        style: TextStyle(
                          color: event.isFree ? AppColors.success : AppColors.warning,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Iconsax.people, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${event.currentAttendees} ${context.t('attendees')}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (event.seatsLeft != null) ...[
                      const Spacer(),
                      Text(
                        '${event.seatsLeft} ${context.t('seats_available')}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      requireAuth(context, () {
                        context.read<EventsCubit>().registerForEvent(event.id);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _typeColor,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(
                      event.type == EventType.job
                          ? context.t('apply_now')
                          : context.t('register'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'م' : 'ص';
    return '$hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// FILTER SHEET
// ═══════════════════════════════════════════════════════════════════

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 24),
          Text(
            context.t('filter_by'),
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(context.t('event_type'), style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: context.t('job'),
                icon: Iconsax.briefcase,
                color: AppColors.info,
                onTap: () {
                  context.read<EventsCubit>().filterByType(EventType.job);
                  Navigator.pop(context);
                },
              ),
              _FilterChip(
                label: context.t('workshop'),
                icon: Iconsax.teacher,
                color: AppColors.success,
                onTap: () {
                  context.read<EventsCubit>().filterByType(EventType.workshop);
                  Navigator.pop(context);
                },
              ),
              _FilterChip(
                label: context.t('conference'),
                icon: Iconsax.people,
                color: AppColors.primary,
                onTap: () {
                  context.read<EventsCubit>().filterByType(EventType.conference);
                  Navigator.pop(context);
                },
              ),
              _FilterChip(
                label: context.t('webinar'),
                icon: Iconsax.video,
                color: AppColors.secondary,
                onTap: () {
                  context.read<EventsCubit>().filterByType(EventType.webinar);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                context.read<EventsCubit>().filterByType(null);
                Navigator.pop(context);
              },
              child: const Text('إظهار الكل'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CREATE EVENT SHEET
// ═══════════════════════════════════════════════════════════════════

class _CreateEventSheet extends StatefulWidget {
  const _CreateEventSheet();

  @override
  State<_CreateEventSheet> createState() => _CreateEventSheetState();
}

class _CreateEventSheetState extends State<_CreateEventSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  EventType _selectedType = EventType.workshop;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  bool _isOnline = false;
  bool _isFree = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.t('cancel')),
                ),
                const Spacer(),
                Text(
                  context.t('create_event'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _createEvent(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(80, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(context.t('save')),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant.withOpacity(0.5)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Event Type
                Text(context.t('event_type'), style: theme.textTheme.titleSmall),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: EventType.values.take(5).map((type) {
                    final isSelected = _selectedType == type;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          context.t(type.name),
                          style: TextStyle(
                            color: isSelected ? Colors.white : colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Title
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: context.t('event_title'),
                    prefixIcon: const Icon(Iconsax.edit),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: context.t('event_description'),
                    prefixIcon: const Icon(Iconsax.document_text),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),

                // Date
                ListTile(
                  leading: const Icon(Iconsax.calendar),
                  title: Text(context.t('event_date')),
                  subtitle: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Online/Onsite
                SwitchListTile(
                  title: Text(context.t('event_online')),
                  value: _isOnline,
                  onChanged: (value) => setState(() => _isOnline = value),
                ),

                // Location
                if (!_isOnline)
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: context.t('event_location'),
                      prefixIcon: const Icon(Iconsax.location),
                    ),
                  ),
                const SizedBox(height: 16),

                // Free/Paid
                SwitchListTile(
                  title: Text(context.t('free')),
                  value: _isFree,
                  onChanged: (value) => setState(() => _isFree = value),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _createEvent(BuildContext context) {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عنوان الفعالية مطلوب')),
      );
      return;
    }

    final userId = SupabaseConfig.currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
      );
      return;
    }

    final event = EventModel(
      id: '',
      userId: userId,
      titleAr: _titleController.text.trim(),
      descriptionAr: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      type: _selectedType,
      status: EventStatus.published,
      startDate: _selectedDate,
      location: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : null,
      isOnline: _isOnline,
      isFree: _isFree,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<EventsCubit>().createEvent(event).then((success) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الفعالية بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }
}