import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

final bookingServiceProvider = Provider<BookingService>((ref) {
  return BookingService();
});

final bookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final bookingService = ref.read(bookingServiceProvider);
  return bookingService.getMyBookings();
});

final bookingDetailProvider = FutureProvider.family<BookingModel, String>((ref, bookingId) async {
  final bookingService = ref.read(bookingServiceProvider);
  return bookingService.getBookingById(bookingId);
});

final bookingNotifierProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier(ref.read(bookingServiceProvider));
});

class BookingNotifier extends StateNotifier<BookingState> {
  final BookingService _bookingService;

  BookingNotifier(this._bookingService) : super(const BookingInitial());

  Future<void> createBooking({
    required String serviceId,
    required String providerId,
    required DateTime scheduledDate,
    required int durationHours,
    required double totalAmount,
    String? notes,
  }) async {
    state = const BookingLoading();
    try {
      await _bookingService.createBooking(
        serviceId: serviceId,
        providerId: providerId,
        scheduledDate: scheduledDate,
        durationHours: durationHours,
        totalAmount: totalAmount,
        notes: notes,
      );
      state = const BookingSuccess('Booking created successfully');
    } catch (e) {
      state = BookingError(e.toString());
    }
  }

  Future<void> confirmBooking(String bookingId) async {
    state = const BookingLoading();
    try {
      await _bookingService.confirmBooking(bookingId);
      state = const BookingSuccess('Booking confirmed successfully');
    } catch (e) {
      state = BookingError(e.toString());
    }
  }

  Future<void> startBooking(String bookingId) async {
    state = const BookingLoading();
    try {
      await _bookingService.startBooking(bookingId);
      state = const BookingSuccess('Booking started successfully');
    } catch (e) {
      state = BookingError(e.toString());
    }
  }

  Future<void> completeBooking(String bookingId) async {
    state = const BookingLoading();
    try {
      await _bookingService.completeBooking(bookingId);
      state = const BookingSuccess('Booking completed successfully');
    } catch (e) {
      state = BookingError(e.toString());
    }
  }

  Future<void> cancelBooking(String bookingId, String reason) async {
    state = const BookingLoading();
    try {
      await _bookingService.cancelBooking(bookingId, reason);
      state = const BookingSuccess('Booking cancelled successfully');
    } catch (e) {
      state = BookingError(e.toString());
    }
  }
}

// Define the state classes
abstract class BookingState {
  const BookingState();
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class BookingSuccess extends BookingState {
  final String message;
  const BookingSuccess(this.message);
}

class BookingError extends BookingState {
  final String message;
  const BookingError(this.message);
}