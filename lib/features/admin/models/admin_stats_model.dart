class AdminStatsModel {
  final int totalUsers;
  final int activeUsers;
  final int verifiedUsers;
  final int totalServices;
  final int activeServices;
  final int pendingServices;
  final int totalBookings;
  final int completedBookings;
  final int pendingBookings;
  final int totalDepositRequests;
  final int pendingDepositRequests;
  final double totalDepositAmount;
  final double totalRevenue;

  const AdminStatsModel({
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.verifiedUsers = 0,
    this.totalServices = 0,
    this.activeServices = 0,
    this.pendingServices = 0,
    this.totalBookings = 0,
    this.completedBookings = 0,
    this.pendingBookings = 0,
    this.totalDepositRequests = 0,
    this.pendingDepositRequests = 0,
    this.totalDepositAmount = 0.0,
    this.totalRevenue = 0.0,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalUsers: json['total_users'] as int? ?? 0,
      activeUsers: json['active_users'] as int? ?? 0,
      verifiedUsers: json['verified_users'] as int? ?? 0,
      totalServices: json['total_services'] as int? ?? 0,
      activeServices: json['active_services'] as int? ?? 0,
      pendingServices: json['pending_services'] as int? ?? 0,
      totalBookings: json['total_bookings'] as int? ?? 0,
      completedBookings: json['completed_bookings'] as int? ?? 0,
      pendingBookings: json['pending_bookings'] as int? ?? 0,
      totalDepositRequests: json['total_deposit_requests'] as int? ?? 0,
      pendingDepositRequests: json['pending_deposit_requests'] as int? ?? 0,
      totalDepositAmount: (json['total_deposit_amount'] as num?)?.toDouble() ?? 0.0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  get userGrowth => null;

  get serviceGrowth => null;

  get revenueGrowth => null;

  get todayTransactions => null;

  get transactionGrowth => null;

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'active_users': activeUsers,
      'verified_users': verifiedUsers,
      'total_services': totalServices,
      'active_services': activeServices,
      'pending_services': pendingServices,
      'total_bookings': totalBookings,
      'completed_bookings': completedBookings,
      'pending_bookings': pendingBookings,
      'total_deposit_requests': totalDepositRequests,
      'pending_deposit_requests': pendingDepositRequests,
      'total_deposit_amount': totalDepositAmount,
      'total_revenue': totalRevenue,
    };
  }

  AdminStatsModel copyWith({
    int? totalUsers,
    int? activeUsers,
    int? verifiedUsers,
    int? totalServices,
    int? activeServices,
    int? pendingServices,
    int? totalBookings,
    int? completedBookings,
    int? pendingBookings,
    int? totalDepositRequests,
    int? pendingDepositRequests,
    double? totalDepositAmount,
    double? totalRevenue,
  }) {
    return AdminStatsModel(
      totalUsers: totalUsers ?? this.totalUsers,
      activeUsers: activeUsers ?? this.activeUsers,
      verifiedUsers: verifiedUsers ?? this.verifiedUsers,
      totalServices: totalServices ?? this.totalServices,
      activeServices: activeServices ?? this.activeServices,
      pendingServices: pendingServices ?? this.pendingServices,
      totalBookings: totalBookings ?? this.totalBookings,
      completedBookings: completedBookings ?? this.completedBookings,
      pendingBookings: pendingBookings ?? this.pendingBookings,
      totalDepositRequests: totalDepositRequests ?? this.totalDepositRequests,
      pendingDepositRequests: pendingDepositRequests ?? this.pendingDepositRequests,
      totalDepositAmount: totalDepositAmount ?? this.totalDepositAmount,
      totalRevenue: totalRevenue ?? this.totalRevenue,
    );
  }
}