enum UserRole {
  user,
  moderator,
  manager,
  owner,
}

class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final String? university;
  final String? major;
  final UserRole role;
  final double walletBalance;
  final double reservedBalance;
  final int timeBalance;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final bool isSuspended;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.university,
    this.major,
    this.role = UserRole.user,
    this.walletBalance = 0.0,
    this.reservedBalance = 0.0,
    this.timeBalance = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isVerified = false,
    this.isSuspended = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      university: json['university'] as String?,
      major: json['major'] as String?,
      role: _parseUserRole(json['role'] as String? ?? 'user'),
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      reservedBalance: (json['reserved_balance'] as num?)?.toDouble() ?? 0.0,
      timeBalance: json['time_balance'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      isSuspended: json['is_suspended'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'university': university,
      'major': major,
      'role': _userRoleToString(role),
      'wallet_balance': walletBalance,
      'reserved_balance': reservedBalance,
      'time_balance': timeBalance,
      'rating': rating,
      'review_count': reviewCount,
      'is_verified': isVerified,
      'is_suspended': isSuspended,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? university,
    String? major,
    UserRole? role,
    double? walletBalance,
    double? reservedBalance,
    int? timeBalance,
    double? rating,
    int? reviewCount,
    bool? isVerified,
    bool? isSuspended,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      university: university ?? this.university,
      major: major ?? this.major,
      role: role ?? this.role,
      walletBalance: walletBalance ?? this.walletBalance,
      reservedBalance: reservedBalance ?? this.reservedBalance,
      timeBalance: timeBalance ?? this.timeBalance,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isVerified: isVerified ?? this.isVerified,
      isSuspended: isSuspended ?? this.isSuspended,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static UserRole _parseUserRole(String value) {
    switch (value) {
      case 'user':
        return UserRole.user;
      case 'moderator':
        return UserRole.moderator;
      case 'manager':
        return UserRole.manager;
      case 'owner':
        return UserRole.owner;
      default:
        return UserRole.user;
    }
  }

  static String _userRoleToString(UserRole role) {
    switch (role) {
      case UserRole.user:
        return 'user';
      case UserRole.moderator:
        return 'moderator';
      case UserRole.manager:
        return 'manager';
      case UserRole.owner:
        return 'owner';
    }
  }
}