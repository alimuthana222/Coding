import '../config/supabase_config.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final _client = SupabaseConfig.client;

  // ═══════════════════════════════════════════════════════════════════
  // GET USER BOOKINGS (AS LEARNER)
  // ═══════════════════════════════════════════════════════════════════

  Future<List<BookingModel>> getLearnerBookings(String userId) async {
    final response = await _client
        .from(SupabaseConfig.bookingsTable)
        .select('''
          *,
          skills(*, profiles(*), skill_categories(*)),
          teacher:profiles!bookings_teacher_id_fkey(*)
        ''')
        .eq('learner_id', userId)
        .order('scheduled_at', ascending: false);

    return (response as List).map((e) => BookingModel.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET USER BOOKINGS (AS TEACHER)
  // ═══════════════════════════════════════════════════════════════════

  Future<List<BookingModel>> getTeacherBookings(String userId) async {
    final response = await _client
        .from(SupabaseConfig.bookingsTable)
        .select('''
          *,
          skills(*, profiles(*), skill_categories(*)),
          learner:profiles!bookings_learner_id_fkey(*)
        ''')
        .eq('teacher_id', userId)
        .order('scheduled_at', ascending: false);

    return (response as List).map((e) => BookingModel.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET BOOKING BY ID
  // ══��════════════════════════════════════════════════════════════════

  Future<BookingModel?> getBookingById(String id) async {
    final response = await _client
        .from(SupabaseConfig.bookingsTable)
        .select('''
          *,
          skills(*, profiles(*), skill_categories(*)),
          learner:profiles!bookings_learner_id_fkey(*),
          teacher:profiles!bookings_teacher_id_fkey(*)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return BookingModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // CREATE BOOKING
  // ═══════════════════════════════════════════════════════════════════

  Future<BookingModel> createBooking(BookingModel booking) async {
    final response = await _client
        .from(SupabaseConfig.bookingsTable)
        .insert(booking.toJson())
        .select('''
          *,
          skills(*, profiles(*), skill_categories(*)),
          learner:profiles!bookings_learner_id_fkey(*),
          teacher:profiles!bookings_teacher_id_fkey(*)
        ''')
        .single();

    return BookingModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // UPDATE BOOKING STATUS
  // ═══════════════════════════════════════════════════════════════════

  Future<BookingModel> updateStatus(String bookingId, BookingStatus status) async {
    final updateData = <String, dynamic>{
      'status': status.name,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (status == BookingStatus.completed) {
      updateData['completed_at'] = DateTime.now().toIso8601String();
    } else if (status == BookingStatus.cancelled) {
      updateData['cancelled_at'] = DateTime.now().toIso8601String();
    }

    final response = await _client
        .from(SupabaseConfig.bookingsTable)
        .update(updateData)
        .eq('id', bookingId)
        .select('''
          *,
          skills(*, profiles(*), skill_categories(*)),
          learner:profiles!bookings_learner_id_fkey(*),
          teacher:profiles!bookings_teacher_id_fkey(*)
        ''')
        .single();

    return BookingModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // CANCEL BOOKING
  // ═══════════════════════════════════════════════════════════════════

  Future<void> cancelBooking(String bookingId, String reason) async {
    await _client.from(SupabaseConfig.bookingsTable).update({
      'status': 'cancelled',
      'cancelled_at': DateTime.now().toIso8601String(),
      'cancellation_reason': reason,
    }).eq('id', bookingId);
  }

  // ═══════════════════════════════════════════════════════════════════
  // ADD REVIEW
  // ═══════════════════════════════════════════════════════════════════

  Future<void> addReview(
      String bookingId,
      String reviewerId,
      int rating,
      String? review,
      bool isLearnerReview,
      ) async {
    final field = isLearnerReview ? 'learner' : 'teacher';

    await _client.from(SupabaseConfig.bookingsTable).update({
      '${field}_rating': rating,
      '${field}_review': review,
    }).eq('id', bookingId);
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET PENDING BOOKINGS COUNT
  // ═══════════════════════════════════════════════════════════════════

  Future<int> getPendingCount(String teacherId) async {
    final response = await _client
        .from(SupabaseConfig.bookingsTable)
        .select('id')
        .eq('teacher_id', teacherId)
        .eq('status', 'pending');

    return (response as List).length;
  }
}