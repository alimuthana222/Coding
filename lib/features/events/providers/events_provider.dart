import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../services/events_service.dart';

final eventsServiceProvider = Provider<EventsService>((ref) {
  return EventsService();
});

final eventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final eventsService = ref.read(eventsServiceProvider);
  return eventsService.getEvents();
});

final eventDetailProvider = FutureProvider.family<EventModel, String>((ref, eventId) async {
  final eventsService = ref.read(eventsServiceProvider);
  return eventsService.getEventById(eventId);
});

final eventsNotifierProvider = StateNotifierProvider<EventsNotifier, EventsState>((ref) {
  return EventsNotifier(ref.read(eventsServiceProvider));
});

class EventsNotifier extends StateNotifier<EventsState> {
  final EventsService _eventsService;

  EventsNotifier(this._eventsService) : super(const EventsInitial());

  Future<void> createEvent({
    required String title,
    required String description,
    required EventType type,
    required DateTime startDate,
    required DateTime endDate,
    String? location,
    int? maxAttendees,
    bool? isOnline,
    String? meetingLink,
  }) async {
    state = const EventsLoading();
    try {
      await _eventsService.createEvent(
        title: title,
        description: description,
        type: type,
        startDate: startDate,
        endDate: endDate,
        location: location,
        maxAttendees: maxAttendees,
        isOnline: isOnline,
        meetingLink: meetingLink,
      );
      state = const EventsSuccess('Event created successfully');
    } catch (e) {
      state = EventsError(e.toString());
    }
  }

  Future<void> rsvpToEvent(String eventId) async {
    state = const EventsLoading();
    try {
      await _eventsService.rsvpToEvent(eventId);
      state = const EventsSuccess('RSVP confirmed');
    } catch (e) {
      state = EventsError(e.toString());
    }
  }
}

// Define the state classes
abstract class EventsState {
  const EventsState();
}

class EventsInitial extends EventsState {
  const EventsInitial();
}

class EventsLoading extends EventsState {
  const EventsLoading();
}

class EventsSuccess extends EventsState {
  final String message;
  const EventsSuccess(this.message);
}

class EventsError extends EventsState {
  final String message;
  const EventsError(this.message);
}