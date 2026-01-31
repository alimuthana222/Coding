import 'package:equatable/equatable.dart';
import '../../../core/models/event_model.dart';

enum EventsStatus { initial, loading, loaded, error }

class EventsState extends Equatable {
  final EventsStatus status;
  final List<EventModel> events;
  final List<EventModel> myEvents;
  final EventType? selectedType;
  final String? errorMessage;
  final bool hasReachedMax;
  final int currentPage;
  final bool isCreating;

  const EventsState({
    this.status = EventsStatus.initial,
    this.events = const [],
    this.myEvents = const [],
    this.selectedType,
    this.errorMessage,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.isCreating = false,
  });

  EventsState copyWith({
    EventsStatus? status,
    List<EventModel>? events,
    List<EventModel>? myEvents,
    EventType? selectedType,
    String? errorMessage,
    bool? hasReachedMax,
    int? currentPage,
    bool? isCreating,
  }) {
    return EventsState(
      status: status ?? this.status,
      events: events ?? this.events,
      myEvents: myEvents ?? this.myEvents,
      selectedType: selectedType ?? this.selectedType,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isCreating: isCreating ?? this.isCreating,
    );
  }

  List<EventModel> get upcomingEvents =>
      events.where((e) => e.isUpcoming).toList();

  @override
  List<Object?> get props => [
    status, events, myEvents, selectedType,
    errorMessage, hasReachedMax, currentPage, isCreating,
  ];
}