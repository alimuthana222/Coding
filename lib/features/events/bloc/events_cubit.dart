import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/repositories/event_repository.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/models/event_model.dart';
import 'events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  final EventRepository _eventRepository = sl<EventRepository>();

  EventsCubit() : super(const EventsState()) {
    loadEvents();
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAD EVENTS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> loadEvents() async {
    emit(state.copyWith(status: EventsStatus.loading));

    try {
      final events = await _eventRepository.getEvents();

      emit(state.copyWith(
        status: EventsStatus.loaded,
        events: events,
        currentPage: 1,
        hasReachedMax: events.length < 20,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EventsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAD MY EVENTS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> loadMyEvents() async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) return;

    try {
      final myEvents = await _eventRepository.getRegisteredEvents(userId);
      emit(state.copyWith(myEvents: myEvents));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // FILTER BY TYPE
  // ═══════════════════════════════════════════════════════════════════

  Future<void> filterByType(EventType? type) async {
    emit(state.copyWith(
      status: EventsStatus.loading,
      selectedType: type,
      currentPage: 1,
      hasReachedMax: false,
    ));

    try {
      final events = await _eventRepository.getEvents(type: type);

      emit(state.copyWith(
        status: EventsStatus.loaded,
        events: events,
        hasReachedMax: events.length < 20,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EventsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // CREATE EVENT
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> createEvent(EventModel event) async {
    emit(state.copyWith(isCreating: true));

    try {
      final createdEvent = await _eventRepository.createEvent(event);

      emit(state.copyWith(
        isCreating: false,
        events: [createdEvent, ...state.events],
      ));

      return true;
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // REGISTER FOR EVENT
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> registerForEvent(String eventId) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) return false;

    try {
      final success = await _eventRepository.registerForEvent(eventId, userId);

      if (success) {
        final updatedEvents = state.events.map((event) {
          if (event.id == eventId) {
            return EventModel(
              id: event.id,
              userId: event.userId,
              titleAr: event.titleAr,
              titleEn: event.titleEn,
              descriptionAr: event.descriptionAr,
              descriptionEn: event.descriptionEn,
              type: event.type,
              status: event.status,
              startDate: event.startDate,
              endDate: event.endDate,
              location: event.location,
              isOnline: event.isOnline,
              meetingLink: event.meetingLink,
              imageUrl: event.imageUrl,
              isFree: event.isFree,
              price: event.price,
              currency: event.currency,
              maxAttendees: event.maxAttendees,
              currentAttendees: event.currentAttendees + 1,
              registrationDeadline: event.registrationDeadline,
              companyName: event.companyName,
              jobType: event.jobType,
              salaryRange: event.salaryRange,
              requirements: event.requirements,
              benefits: event.benefits,
              createdAt: event.createdAt,
              updatedAt: event.updatedAt,
              user: event.user,
              isRegisteredByMe: true,
            );
          }
          return event;
        }).toList();

        emit(state.copyWith(events: updatedEvents));
      }

      return success;
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // UNREGISTER FROM EVENT
  // ═══════════════════════════════════════════════════════════════════

  Future<void> unregisterFromEvent(String eventId) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) return;

    try {
      await _eventRepository.unregisterFromEvent(eventId, userId);

      final updatedEvents = state.events.map((event) {
        if (event.id == eventId) {
          return EventModel(
            id: event.id,
            userId: event.userId,
            titleAr: event.titleAr,
            titleEn: event.titleEn,
            descriptionAr: event.descriptionAr,
            descriptionEn: event.descriptionEn,
            type: event.type,
            status: event.status,
            startDate: event.startDate,
            endDate: event.endDate,
            location: event.location,
            isOnline: event.isOnline,
            meetingLink: event.meetingLink,
            imageUrl: event.imageUrl,
            isFree: event.isFree,
            price: event.price,
            currency: event.currency,
            maxAttendees: event.maxAttendees,
            currentAttendees: event.currentAttendees - 1,
            registrationDeadline: event.registrationDeadline,
            companyName: event.companyName,
            jobType: event.jobType,
            salaryRange: event.salaryRange,
            requirements: event.requirements,
            benefits: event.benefits,
            createdAt: event.createdAt,
            updatedAt: event.updatedAt,
            user: event.user,
            isRegisteredByMe: false,
          );
        }
        return event;
      }).toList();

      emit(state.copyWith(events: updatedEvents));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // REFRESH
  // ═══════════════════════════════════════════════════════════════════

  Future<void> refresh() async {
    emit(state.copyWith(currentPage: 1, hasReachedMax: false));
    await loadEvents();
  }
}