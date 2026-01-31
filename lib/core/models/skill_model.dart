import 'package:equatable/equatable.dart';
import 'user_model.dart';

// ═══════════════════════════════════════════════════════════════════
// SKILL CATEGORY MODEL
// ═══════════════════════════════════════════════════════════════════

class SkillCategoryModel extends Equatable {
  final String id;
  final String nameAr;
  final String nameEn;
  final String? icon;
  final String? color;
  final DateTime createdAt;

  const SkillCategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.icon,
    this.color,
    required this.createdAt,
  });

  factory SkillCategoryModel.fromJson(Map<String, dynamic> json) {
    return SkillCategoryModel(
      id: json['id'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  String getName(bool isArabic) => isArabic ? nameAr : nameEn;

  @override
  List<Object?> get props => [id, nameAr, nameEn, icon, color, createdAt];
}

// ═══════════════════════════════════════════════════════════════════
// SKILL MODEL
// ═══════════════════════════════════════════════════════════════════

class SkillModel extends Equatable {
  final String id;
  final String userId;
  final String? categoryId;
  final String titleAr;
  final String? titleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final double priceHours;
  final int durationMinutes;
  final bool isOnline;
  final bool isActive;
  final double rating;
  final int totalReviews;
  final int totalSessions;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final UserModel? user;
  final SkillCategoryModel? category;
  final bool? isFavorite;

  const SkillModel({
    required this.id,
    required this.userId,
    this.categoryId,
    required this.titleAr,
    this.titleEn,
    this.descriptionAr,
    this.descriptionEn,
    this.priceHours = 1.0,
    this.durationMinutes = 60,
    this.isOnline = true,
    this.isActive = true,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalSessions = 0,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.category,
    this.isFavorite,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String?,
      titleAr: json['title_ar'] as String,
      titleEn: json['title_en'] as String?,
      descriptionAr: json['description_ar'] as String?,
      descriptionEn: json['description_en'] as String?,
      priceHours: (json['price_hours'] as num?)?.toDouble() ?? 1.0,
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      isOnline: json['is_online'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      totalSessions: json['total_sessions'] as int? ?? 0,
      images: List<String>.from(json['images'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      user: json['profiles'] != null ? UserModel.fromJson(json['profiles']) : null,
      category: json['skill_categories'] != null
          ? SkillCategoryModel.fromJson(json['skill_categories'])
          : null,
      isFavorite: json['is_favorite'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'category_id': categoryId,
      'title_ar': titleAr,
      'title_en': titleEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'price_hours': priceHours,
      'duration_minutes': durationMinutes,
      'is_online': isOnline,
      'is_active': isActive,
      'images': images,
    };
  }

  // Helpers
  String getTitle(bool isArabic) => isArabic ? titleAr : (titleEn ?? titleAr);
  String? getDescription(bool isArabic) => isArabic ? descriptionAr : (descriptionEn ?? descriptionAr);

  SkillModel copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? titleAr,
    String? titleEn,
    String? descriptionAr,
    String? descriptionEn,
    double? priceHours,
    int? durationMinutes,
    bool? isOnline,
    bool? isActive,
    double? rating,
    int? totalReviews,
    int? totalSessions,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? user,
    SkillCategoryModel? category,
    bool? isFavorite,
  }) {
    return SkillModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      priceHours: priceHours ?? this.priceHours,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isOnline: isOnline ?? this.isOnline,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalSessions: totalSessions ?? this.totalSessions,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
    id, userId, categoryId, titleAr, titleEn, descriptionAr, descriptionEn,
    priceHours, durationMinutes, isOnline, isActive, rating, totalReviews,
    totalSessions, images, createdAt, updatedAt, isFavorite,
  ];
}