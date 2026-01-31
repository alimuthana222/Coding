import 'package:equatable/equatable.dart';
import 'user_model.dart';
import 'skill_model.dart';

// ═══════════════════════════════════════════════════════════════════
// ENUMS
// ═══════════════════════════════════════════════════════════════════

enum ServiceType {
  offering,   // أعرض خدمة
  requesting, // أطلب خدمة
}

enum PricingType {
  hours,  // بالساعات
  money,  // بالمال
}

enum ServiceStatus {
  active,
  paused,
  completed,
  deleted,
}

enum BookingStatus {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled,
  rejected,
  disputed,
}

// ═══════════════════════════════════════════════════════════════════
// SERVICE MODEL
// ═══════════════════════════════════════════════════════════════════

class ServiceModel extends Equatable {
  final String id;
  final String userId;
  final String? categoryId;
  final ServiceType serviceType;
  final String title;
  final String description;
  final PricingType pricingType;
  final double? priceHours;
  final double? priceMoney;
  final int? estimatedDuration;
  final List<String> images;
  final ServiceStatus status;
  final int views;
  final int totalBookings;
  final int completedBookings;
  final double rating;
  final int totalReviews;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final UserModel? user;
  final SkillCategoryModel? category;

  const ServiceModel({
    required this.id,
    required this.userId,
    this.categoryId,
    required this.serviceType,
    required this.title,
    required this.description,
    required this.pricingType,
    this.priceHours,
    this.priceMoney,
    this.estimatedDuration,
    this.images = const [],
    this.status = ServiceStatus.active,
    this.views = 0,
    this.totalBookings = 0,
    this.completedBookings = 0,
    this.rating = 0,
    this.totalReviews = 0,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.category,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String?,
      serviceType: json['service_type'] == 'offering'
          ? ServiceType.offering
          : ServiceType.requesting,
      title: json['title'] as String,
      description: json['description'] as String,
      pricingType: json['pricing_type'] == 'hours'
          ? PricingType.hours
          : PricingType.money,
      priceHours: (json['price_hours'] as num?)?.toDouble(),
      priceMoney: (json['price_money'] as num?)?.toDouble(),
      estimatedDuration: json['estimated_duration'] as int?,
      images: List<String>.from(json['images'] ?? []),
      status: ServiceStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => ServiceStatus.active,
      ),
      views: json['views'] as int? ?? 0,
      totalBookings: json['total_bookings'] as int? ?? 0,
      completedBookings: json['completed_bookings'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      user: json['profiles'] != null
          ? UserModel.fromJson(json['profiles'])
          : null,
      category: json['skill_categories'] != null
          ? SkillCategoryModel.fromJson(json['skill_categories'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'category_id': categoryId,
      'service_type': serviceType == ServiceType.offering ? 'offering' : 'requesting',
      'title': title,
      'description': description,
      'pricing_type': pricingType == PricingType.hours ? 'hours' : 'money',
      'price_hours': priceHours,
      'price_money': priceMoney,
      'estimated_duration': estimatedDuration,
      'images': images,
    };
  }

  String get serviceTypeLabel => serviceType == ServiceType.offering
      ? 'أعرض خدمة'
      : 'أطلب خدمة';

  String get priceLabel {
    if (pricingType == PricingType.hours) {
      return '${priceHours?.toStringAsFixed(0) ?? 0} ساعة';
    } else {
      return '${priceMoney?.toStringAsFixed(0) ?? 0} د.ع';
    }
  }

  @override
  List<Object?> get props => [
    id, userId, categoryId, serviceType, title, description, pricingType,
    priceHours, priceMoney, estimatedDuration, images, status, views,
    totalBookings, completedBookings, rating, totalReviews, createdAt, updatedAt,
  ];
}

// ═══════════════════════════════════════════════════════════════════
// SERVICE BOOKING MODEL
// ═══════════════════════════════════════════════════════════════════

class ServiceBookingModel extends Equatable {
  final String id;
  final String serviceId;
  final String clientId;
  final String providerId;
  final PricingType pricingType;
  final double? priceHours;
  final double? priceMoney;
  final BookingStatus status;
  final String? clientMessage;
  final String? providerResponse;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancelledBy;
  final String? cancellationReason;
  final int? clientRating;
  final String? clientReview;
  final DateTime? clientReviewedAt;
  final int? providerRating;
  final String? providerReview;
  final DateTime? providerReviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final ServiceModel? service;
  final UserModel? client;
  final UserModel? provider;

  const ServiceBookingModel({
    required this.id,
    required this.serviceId,
    required this.clientId,
    required this.providerId,
    required this.pricingType,
    this.priceHours,
    this.priceMoney,
    this.status = BookingStatus.pending,
    this.clientMessage,
    this.providerResponse,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
    this.clientRating,
    this.clientReview,
    this.clientReviewedAt,
    this.providerRating,
    this.providerReview,
    this.providerReviewedAt,
    required this.createdAt,
    required this.updatedAt,
    this.service,
    this.client,
    this.provider,
  });

  factory ServiceBookingModel.fromJson(Map<String, dynamic> json) {
    return ServiceBookingModel(
      id: json['id'] as String,
      serviceId: json['service_id'] as String,
      clientId: json['client_id'] as String,
      providerId: json['provider_id'] as String,
      pricingType: json['pricing_type'] == 'hours'
          ? PricingType.hours
          : PricingType.money,
      priceHours: (json['price_hours'] as num?)?.toDouble(),
      priceMoney: (json['price_money'] as num?)?.toDouble(),
      status: _parseStatus(json['status'] as String),
      clientMessage: json['client_message'] as String?,
      providerResponse: json['provider_response'] as String?,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'])
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      cancelledBy: json['cancelled_by'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      clientRating: json['client_rating'] as int?,
      clientReview: json['client_review'] as String?,
      clientReviewedAt: json['client_reviewed_at'] != null
          ? DateTime.parse(json['client_reviewed_at'])
          : null,
      providerRating: json['provider_rating'] as int?,
      providerReview: json['provider_review'] as String?,
      providerReviewedAt: json['provider_reviewed_at'] != null
          ? DateTime.parse(json['provider_reviewed_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      service: json['services'] != null
          ? ServiceModel.fromJson(json['services'])
          : null,
      client: json['client'] != null
          ? UserModel.fromJson(json['client'])
          : null,
      provider: json['provider'] != null
          ? UserModel.fromJson(json['provider'])
          : null,
    );
  }

  static BookingStatus _parseStatus(String status) {
    switch (status) {
      case 'pending': return BookingStatus.pending;
      case 'accepted': return BookingStatus.accepted;
      case 'in_progress': return BookingStatus.inProgress;
      case 'completed': return BookingStatus.completed;
      case 'cancelled': return BookingStatus.cancelled;
      case 'rejected': return BookingStatus.rejected;
      case 'disputed': return BookingStatus.disputed;
      default: return BookingStatus.pending;
    }
  }

  String get statusLabel {
    switch (status) {
      case BookingStatus.pending: return 'في الانتظار';
      case BookingStatus.accepted: return 'تم القبول';
      case BookingStatus.inProgress: return 'قيد التنفيذ';
      case BookingStatus.completed: return 'مكتمل';
      case BookingStatus.cancelled: return 'ملغي';
      case BookingStatus.rejected: return 'مرفوض';
      case BookingStatus.disputed: return 'نزاع';
    }
  }

  String get priceLabel {
    if (pricingType == PricingType.hours) {
      return '${priceHours?.toStringAsFixed(0) ?? 0} ساعة';
    } else {
      return '${priceMoney?.toStringAsFixed(0) ?? 0} د.ع';
    }
  }

  @override
  List<Object?> get props => [id, serviceId, clientId, providerId, status, createdAt];
}