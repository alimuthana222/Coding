import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/repositories/service_repository.dart';
import '../../../core/repositories/wallet_repository.dart';
import '../../../core/models/service_model.dart';
import '../../../core/models/wallet_model.dart';
import 'bookings_state.dart';

class BookingsCubit extends Cubit<BookingsState> {
  final ServiceRepository _serviceRepository = sl<ServiceRepository>();
  final WalletRepository _walletRepository = sl<WalletRepository>();

  BookingsCubit() : super(const BookingsState()) {
    loadBookings();
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAD BOOKINGS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> loadBookings() async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) return;

    emit(state.copyWith(status: BookingsStatus.loading));

    try {
      final results = await Future.wait([
        _serviceRepository.getUserBookings(userId, asClient: true),
        _serviceRepository.getUserBookings(userId, asClient: false),
      ]);

      emit(state.copyWith(
        status: BookingsStatus.loaded,
        myRequests: results[0],
        myOffers: results[1],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BookingsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // ACCEPT BOOKING
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> acceptBooking(String bookingId) async {
    emit(state.copyWith(isProcessing: true));

    try {
      await _serviceRepository.updateBookingStatus(
        bookingId,
        BookingStatus.accepted,
      );

      await loadBookings();
      emit(state.copyWith(isProcessing: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // REJECT BOOKING
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> rejectBooking(String bookingId) async {
    emit(state.copyWith(isProcessing: true));

    try {
      await _serviceRepository.updateBookingStatus(
        bookingId,
        BookingStatus.rejected,
      );

      await loadBookings();
      emit(state.copyWith(isProcessing: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // START BOOKING
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> startBooking(String bookingId) async {
    emit(state.copyWith(isProcessing: true));

    try {
      await _serviceRepository.updateBookingStatus(
        bookingId,
        BookingStatus.inProgress,
      );

      await loadBookings();
      emit(state.copyWith(isProcessing: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // COMPLETE BOOKING (مع تحويل الأموال/الساعات)
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> completeBooking(ServiceBookingModel booking) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) return false;

    emit(state.copyWith(isProcessing: true));

    try {
      // تحديث حالة الحجز
      await _serviceRepository.updateBookingStatus(
        booking.id,
        BookingStatus.completed,
      );

      // تحويل الأموال/الساعات
      // ملاحظة: هذا يجب أن يتم في الـ Backend عبر Supabase Functions
      // لكن سنضع الـ Logic هنا للتوضيح

      await loadBookings();
      emit(state.copyWith(isProcessing: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // CANCEL BOOKING
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> cancelBooking(String bookingId) async {
    emit(state.copyWith(isProcessing: true));

    try {
      await _serviceRepository.updateBookingStatus(
        bookingId,
        BookingStatus.cancelled,
      );

      await loadBookings();
      emit(state.copyWith(isProcessing: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // ADD REVIEW
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> addReview({
    required String bookingId,
    required int rating,
    String? review,
    required bool isClientReview,
  }) async {
    emit(state.copyWith(isProcessing: true));

    try {
      await _serviceRepository.addReview(
        bookingId: bookingId,
        rating: rating,
        review: review,
        isClientReview: isClientReview,
      );

      await loadBookings();
      emit(state.copyWith(isProcessing: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // REFRESH
  // ═══════════════════════════════════════════════════════════════════

  Future<void> refresh() async {
    await loadBookings();
  }
}