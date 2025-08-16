
import 'package:flutter/material.dart';

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  refunded,
}

class BookingModel {
  final String id;
  final String serviceId;
  final String clientId;
  final String providerId;
  final DateTime scheduledDate;
  final int durationHours;
  final double totalAmount;
  final BookingStatus status;
  final String? notes;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data (joined)
  final String? serviceName;
  final String? clientName;
  final String? clientAvatar;
  final String? providerName;
  final String? providerAvatar;

  const BookingModel({
    required this.id,
    required this.serviceId,
    required this.clientId,
    required this.providerId,
    required this.scheduledDate,
    required this.durationHours,
    required this.totalAmount,
    required this.status,
    this.notes,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    this.serviceName,
    this.clientName,
    this.clientAvatar,
    this.providerName,
    this.providerAvatar,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      serviceId: json['service_id'] as String,
      clientId: json['client_id'] as String,
      providerId: json['provider_id'] as String,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      durationHours: json['duration_hours'] as int,
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: _parseBookingStatus(json['status'] as String),
      notes: json['notes'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      serviceName: json['service_name'] as String?,
      clientName: json['client_name'] as String?,
      clientAvatar: json['client_avatar'] as String?,
      providerName: json['provider_name'] as String?,
      providerAvatar: json['provider_avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'client_id': clientId,
      'provider_id': providerId,
      'scheduled_date': scheduledDate.toIso8601String(),
      'duration_hours': durationHours,
      'total_amount': totalAmount,
      'status': _bookingStatusToString(status),
      'notes': notes,
      'cancellation_reason': cancellationReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'service_name': serviceName,
      'client_name': clientName,
      'client_avatar': clientAvatar,
      'provider_name': providerName,
      'provider_avatar': providerAvatar,
    };
  }

  static BookingStatus _parseBookingStatus(String value) {
    switch (value) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'in_progress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'refunded':
        return BookingStatus.refunded;
      default:
        return BookingStatus.pending;
    }
  }

  static String _bookingStatusToString(BookingStatus status) {
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

  Color getStatusColor() {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.inProgress:
        return Colors.purple;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.refunded:
        return Colors.grey;
    }
  }

  String getStatusLabel() {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.refunded:
        return 'Refunded';
    }
  }
}