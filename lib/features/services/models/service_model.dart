enum ServiceCategory {
  programming,
  design,
  writing,
  marketing,
  tutoring,
  consultation,
  other,
}

class ServiceModel {
  final String id;
  final String providerId;
  final String title;
  final String description;
  final ServiceCategory category;
  final double hourlyRate;
  final List<String> imageUrls;
  final List<String> tags;
  final bool isActive;
  final double rating;
  final int reviewCount;
  final int totalOrders;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Provider info (joined)
  final String? providerName;
  final String? providerAvatar;
  final double? providerRating;

  const ServiceModel({
    required this.id,
    required this.providerId,
    required this.title,
    required this.description,
    required this.category,
    required this.hourlyRate,
    this.imageUrls = const [],
    this.tags = const [],
    this.isActive = true,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.totalOrders = 0,
    required this.createdAt,
    required this.updatedAt,
    this.providerName,
    this.providerAvatar,
    this.providerRating,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      providerId: json['provider_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: _parseServiceCategory(json['category'] as String),
      hourlyRate: (json['hourly_rate'] as num).toDouble(),
      imageUrls: (json['image_urls'] as List<dynamic>?)?.cast<String>() ?? [],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isActive: json['is_active'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      totalOrders: json['total_orders'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      providerName: json['provider_name'] as String?,
      providerAvatar: json['provider_avatar'] as String?,
      providerRating: (json['provider_rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'title': title,
      'description': description,
      'category': _serviceCategoryToString(category),
      'hourly_rate': hourlyRate,
      'image_urls': imageUrls,
      'tags': tags,
      'is_active': isActive,
      'rating': rating,
      'review_count': reviewCount,
      'total_orders': totalOrders,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'provider_name': providerName,
      'provider_avatar': providerAvatar,
      'provider_rating': providerRating,
    };
  }

  ServiceModel copyWith({
    String? title,
    String? description,
    ServiceCategory? category,
    double? hourlyRate,
    List<String>? imageUrls,
    List<String>? tags,
    bool? isActive,
    double? rating,
    int? reviewCount,
    int? totalOrders,
  }) {
    return ServiceModel(
      id: id,
      providerId: providerId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      imageUrls: imageUrls ?? this.imageUrls,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      totalOrders: totalOrders ?? this.totalOrders,
      createdAt: createdAt,
      updatedAt: updatedAt,
      providerName: providerName,
      providerAvatar: providerAvatar,
      providerRating: providerRating,
    );
  }

  // Helper methods for enum conversion
  static ServiceCategory _parseServiceCategory(String value) {
    switch (value) {
      case 'programming':
        return ServiceCategory.programming;
      case 'design':
        return ServiceCategory.design;
      case 'writing':
        return ServiceCategory.writing;
      case 'marketing':
        return ServiceCategory.marketing;
      case 'tutoring':
        return ServiceCategory.tutoring;
      case 'consultation':
        return ServiceCategory.consultation;
      case 'other':
        return ServiceCategory.other;
      default:
        return ServiceCategory.other;
    }
  }

  static String _serviceCategoryToString(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.programming:
        return 'programming';
      case ServiceCategory.design:
        return 'design';
      case ServiceCategory.writing:
        return 'writing';
      case ServiceCategory.marketing:
        return 'marketing';
      case ServiceCategory.tutoring:
        return 'tutoring';
      case ServiceCategory.consultation:
        return 'consultation';
      case ServiceCategory.other:
        return 'other';
    }
  }
}