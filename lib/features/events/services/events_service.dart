import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';

class EventsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<EventModel>> getEvents({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _supabase
        .from('events')
        .select('''
          *,
          profiles:organizer_id (
            full_name,
            avatar_url
          )
        ''')
        .eq('is_active', true)
        .gte('start_date', DateTime.now().toIso8601String())
        .order('start_date', ascending: true)
        .range(offset, offset + limit - 1);

    return response.map<EventModel>((json) {
      final profileData = json['profiles'] as Map<String, dynamic>?;
      return EventModel.fromJson({
        ...json,
        'organizer_name': profileData?['full_name'],
        'organizer_avatar': profileData?['avatar_url'],
      });
    }).toList();
  }

  Future<EventModel> getEventById(String eventId) async {
    final response = await _supabase
        .from('events')
        .select('''
          *,
          profiles:organizer_id (
            full_name,
            avatar_url
          )
        ''')
        .eq('id', eventId)
        .single();

    final profileData = response['profiles'] as Map<String, dynamic>?;
    return EventModel.fromJson({
      ...response,
      'organizer_name': profileData?['full_name'],
      'organizer_avatar': profileData?['avatar_url'],
    });
  }

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
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabase.from('events').insert({
      'organizer_id': user.id,
      'title': title,
      'description': description,
      'type': type.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'location': location,
      'max_attendees': maxAttendees ?? 50,
      'is_online': isOnline ?? false,
      'meeting_link': meetingLink,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> rsvpToEvent(String eventId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check if already RSVP'd
    final existingRsvp = await _supabase
        .from('event_rsvps')
        .select('id')
        .eq('event_id', eventId)
        .eq('user_id', user.id)
        .maybeSingle();

    if (existingRsvp != null) {
      throw Exception('Already RSVP\'d to this event');
    }

    await _supabase.from('event_rsvps').insert({
      'event_id': eventId,
      'user_id': user.id,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Update current attendees count
    await _supabase.rpc('increment_event_attendees', params: {
      'event_id': eventId,
    });
  }
}