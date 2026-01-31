import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? username;
  final String? avatarUrl;
  final String? phone;
  final String? bio;
  final String? university;
  final double walletBalance;
  final double timeBankHours;
  final double totalEarnings;
  final int totalServicesProvided;
  final int totalServicesReceived;
  final double providerRating;
  final int totalReviews;
  final List<String> skills;
  final List<String> interests;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.username,
    this.avatarUrl,
    this.phone,
    this.bio,
    this.university,
    this.walletBalance = 0,
    this.timeBankHours = 2,
    this.totalEarnings = 0,
    this.totalServicesProvided = 0,
    this.totalServicesReceived = 0,
    this.providerRating = 0,
    this.totalReviews = 0,
    this.skills = const [],
    this.interests = const [],
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters
  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  // للتوافق مع الكود القديم
  double get walletHours => timeBankHours;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'مستخدم',
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
      university: json['university'] as String?,
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0,
      timeBankHours: (json['time_bank_hours'] as num?)?.toDouble() ?? 2,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0,
      totalServicesProvided: json['total_services_provided'] as int? ?? 0,
      totalServicesReceived: json['total_services_received'] as int? ?? 0,
      providerRating: (json['provider_rating'] as num?)?.toDouble() ?? 0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      skills: List<String>.from(json['skills'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
      isOnline: json['is_online'] as bool? ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'username': username,
      'avatar_url': avatarUrl,
      'phone': phone,
      'bio': bio,
      'university': university,
      'wallet_balance': walletBalance,
      'time_bank_hours': timeBankHours,
      'total_earnings': totalEarnings,
      'total_services_provided': totalServicesProvided,
      'total_services_received': totalServicesReceived,
      'provider_rating': providerRating,
      'total_reviews': totalReviews,
      'skills': skills,
      'interests': interests,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'full_name': fullName,
      'username': username,
      'phone': phone,
      'avatar_url': avatarUrl,
      'bio': bio,
      'university': university,
      'skills': skills,
      'interests': interests,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? username,
    String? avatarUrl,
    String? phone,
    String? bio,
    String? university,
    double? walletBalance,
    double? timeBankHours,
    double? totalEarnings,
    int? totalServicesProvided,
    int? totalServicesReceived,
    double? providerRating,
    int? totalReviews,
    List<String>? skills,
    List<String>? interests,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      university: university ?? this.university,
      walletBalance: walletBalance ?? this.walletBalance,
      timeBankHours: timeBankHours ?? this.timeBankHours,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalServicesProvided: totalServicesProvided ?? this.totalServicesProvided,
      totalServicesReceived: totalServicesReceived ?? this.totalServicesReceived,
      providerRating: providerRating ?? this.providerRating,
      totalReviews: totalReviews ?? this.totalReviews,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, email, fullName, username, avatarUrl, phone, bio, university,
    walletBalance, timeBankHours, totalEarnings, totalServicesProvided,
    totalServicesReceived, providerRating, totalReviews, skills, interests,
    isOnline, lastSeen, createdAt, updatedAt,
  ];
}