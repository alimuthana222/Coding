import 'package:equatable/equatable.dart';
import '../../../core/models/service_model.dart';

enum BookingsStatus { initial, loading, loaded, error }

class BookingsState extends Equatable {
  final BookingsStatus status;
  final List<ServiceBookingModel> myRequests;    // الطلبات اللي قدمتها
  final List<ServiceBookingModel> myOffers;      // الطلبات اللي وصلتني
  final String? errorMessage;
  final bool isProcessing;

  const BookingsState({
    this.status = BookingsStatus.initial,
    this.myRequests = const [],
    this.myOffers = const [],
    this.errorMessage,
    this.isProcessing = false,
  });

  BookingsState copyWith({
    BookingsStatus? status,
    List<ServiceBookingModel>? myRequests,
    List<ServiceBookingModel>? myOffers,
    String? errorMessage,
    bool? isProcessing,
  }) {
    return BookingsState(
      status: status ?? this.status,
      myRequests: myRequests ?? this.myRequests,
      myOffers: myOffers ?? this.myOffers,
      errorMessage: errorMessage,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  List<Object?> get props => [status, myRequests, myOffers, errorMessage, isProcessing];
}