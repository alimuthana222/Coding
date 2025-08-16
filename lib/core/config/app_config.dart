class AppConfig {
  // Supabase Configuration - Replace these with your actual Supabase credentials
  static const String supabaseUrl = 'https://cnbygtdeswbsdqwtdtee.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_C_FMKTgkJkv6yNMDxkTcGQ_XjLltjeO';

  // App Configuration
  static const String appName = 'Skill Marketplace';
  static const String appVersion = '1.0.0';

  // API Endpoints
  static const String baseUrl = '$supabaseUrl/rest/v1';

  // Storage Buckets
  static const String profileImagesBucket = 'profile-images';
  static const String serviceImagesBucket = 'service-images';
  static const String eventImagesBucket = 'event-images';

  // Pagination
  static const int defaultPageSize = 20;

  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);

  // Currency
  static const String defaultCurrency = 'IQD';
  static const String currencySymbol = 'د.ع';

  // Time Bank
  static const String timeUnit = 'Hours';
}