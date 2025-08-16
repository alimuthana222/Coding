import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

class BookingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<BookingModel>> getMyBookings() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('bookings')
        .select('''
          *,
          services:service_id (
            title
          ),
          client:client_id (
            full_name,
            avatar_url
          ),
          provider:provider_id (
            full_name,
            avatar_url
          )
        ''')
        .or('client_id.eq.${user.id},provider_id.eq.${user.id}')
        .order('created_at', ascending: false);

    return response.map<BookingModel>((json) {
      final serviceData = json['services'] as Map<String, dynamic>?;
      final clientData = json['client'] as Map<String, dynamic>?;
      final providerData = json['provider'] as Map<String, dynamic>?;

      return BookingModel.fromJson({
        ...json,
        'service_name': serviceData?['title'],
        'client_name': clientData?['full_name'],
        'client_avatar': clientData?['avatar_url'],
        'provider_name': providerData?['full_name'],
        'provider_avatar': providerData?['avatar_url'],
      });
    }).toList();
  }

  Future<BookingModel> getBookingById(String bookingId) async {
    final response = await _supabase
        .from('bookings')
        .select('''
          *,
          services:service_id (
            title
          ),
          client:client_id (
            full_name,
            avatar_url
          ),
          provider:provider_id (
            full_name,
            avatar_url
          )
        ''')
        .eq('id', bookingId)
        .single();

    final serviceData = response['services'] as Map<String, dynamic>?;
    final clientData = response['client'] as Map<String, dynamic>?;
    final providerData = response['provider'] as Map<String, dynamic>?;

    return BookingModel.fromJson({
      ...response,
      'service_name': serviceData?['title'],
      'client_name': clientData?['full_name'],
      'client_avatar': clientData?['avatar_url'],
      'provider_name': providerData?['full_name'],
      'provider_avatar': providerData?['avatar_url'],
    });
  }

  Future<void> createBooking({
    required String serviceId,
    required String providerId,
    required DateTime scheduledDate,
    required int durationHours,
    required double totalAmount,
    String? notes,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabase.from('bookings').insert({
      'service_id': serviceId,
      'client_id': user.id,
      'provider_id': providerId,
      'scheduled_date': scheduledDate.toIso8601String(),
      'duration_hours': durationHours,
      'total_amount': totalAmount,
      'status': 'pending',
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
    String? cancellationReason,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final updates = <String, dynamic>{
      'status': _bookingStatusToString(status),
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (cancellationReason != null) {
      updates['cancellation_reason'] = cancellationReason;
    }

    await _supabase
        .from('bookings')
        .update(updates)
        .eq('id', bookingId);
  }

  Future<void> confirmBooking(String bookingId) async {
    await updateBookingStatus(bookingId: bookingId, status: BookingStatus.confirmed);
  }

  Future<void> startBooking(String bookingId) async {
    await updateBookingStatus(bookingId: bookingId, status: BookingStatus.inProgress);
  }

  Future<void> completeBooking(String bookingId) async {
    await updateBookingStatus(bookingId: bookingId, status: BookingStatus.completed);
  }

  Future<void> cancelBooking(String bookingId, String reason) async {
    await updateBookingStatus(
      bookingId: bookingId,
      status: BookingStatus.cancelled,
      cancellationReason: reason,
    );
  }

  String _bookingStatusToString(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.inProgress:
        return 'in_progress';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.refunded:
        return 'refunded';
    }
  }
}