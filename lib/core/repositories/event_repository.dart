import '../config/supabase_config.dart';
import '../models/event_model.dart';

class EventRepository {
  final _client = SupabaseConfig.client;

  // ═══════════════════════════════════════════════════════════════════
  // GET EVENTS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<EventModel>> getEvents({
    EventType? type,
    bool? upcomingOnly,
    int page = 1,
    int limit = 20,
  }) async {
    var query = _client
        .from(SupabaseConfig.eventsTable)
        .select('*, profiles(*)')
        .eq('status', 'published');

    if (type != null) {
      query = query.eq('type', type.name);
    }

    if (upcomingOnly == true) {
      query = query.gte('start_date', DateTime.now().toIso8601String());
    }

    final response = await query
        .order('start_date', ascending: true)
        .range((page - 1) * limit, page * limit - 1);

    return (response as List).map((e) => EventModel.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET EVENT BY ID
  // ═══════════════════════════════════════════════════════════════════

  Future<EventModel?> getEventById(String id) async {
    final response = await _client
        .from(SupabaseConfig.eventsTable)
        .select('*, profiles(*)')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return EventModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET USER EVENTS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<EventModel>> getUserEvents(String userId) async {
    final response = await _client
        .from(SupabaseConfig.eventsTable)
        .select('*, profiles(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => EventModel.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET REGISTERED EVENTS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<EventModel>> getRegisteredEvents(String userId) async {
    final response = await _client
        .from(SupabaseConfig.eventRegistrationsTable)
        .select('events(*, profiles(*))')
        .eq('user_id', userId)
        .eq('status', 'registered');

    return (response as List)
        .map((e) => EventModel.fromJson(e['events']))
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // CREATE EVENT
  // ═══════════════════════════════════════════════════════════════════

  Future<EventModel> createEvent(EventModel event) async {
    final response = await _client
        .from(SupabaseConfig.eventsTable)
        .insert(event.toJson())
        .select('*, profiles(*)')
        .single();

    return EventModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // UPDATE EVENT
  // ═══════════════���═══════════════════════════════════════════════════

  Future<EventModel> updateEvent(EventModel event) async {
    final response = await _client
        .from(SupabaseConfig.eventsTable)
        .update(event.toJson())
        .eq('id', event.id)
        .select('*, profiles(*)')
        .single();

    return EventModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // DELETE EVENT
  // ═══════════════════════════════════════════════════════════════════

  Future<void> deleteEvent(String eventId) async {
    await _client
        .from(SupabaseConfig.eventsTable)
        .update({'status': 'cancelled'})
        .eq('id', eventId);
  }

  // ═══════════════════════════════════════════════════════════════════
  // REGISTER FOR EVENT
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> registerForEvent(String eventId, String userId) async {
    // Check if already registered
    final existing = await _client
        .from(SupabaseConfig.eventRegistrationsTable)
        .select()
        .eq('event_id', eventId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      return false; // Already registered
    }

    // Register
    await _client.from(SupabaseConfig.eventRegistrationsTable).insert({
      'event_id': eventId,
      'user_id': userId,
      'status': 'registered',
    });

    // Update attendees count
    await _client.rpc('increment_event_attendees', params: {'event_id': eventId});

    return true;
  }

  // ═══════════════════════════════════════════════════════════════════
  // UNREGISTER FROM EVENT
  // ═══════════════════════════════════════════════════════════════════

  Future<void> unregisterFromEvent(String eventId, String userId) async {
    await _client
        .from(SupabaseConfig.eventRegistrationsTable)
        .delete()
        .eq('event_id', eventId)
        .eq('user_id', userId);

    // Update attendees count
    await _client.rpc('decrement_event_attendees', params: {'event_id': eventId});
  }

  // ═══════════════════════════════════════════════════════════════════
  // CHECK IF REGISTERED
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> isRegistered(String eventId, String userId) async {
    final response = await _client
        .from(SupabaseConfig.eventRegistrationsTable)
        .select()
        .eq('event_id', eventId)
        .eq('user_id', userId)
        .maybeSingle();

    return response != null;
  }
}