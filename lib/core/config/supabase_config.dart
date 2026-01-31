import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  // ═══════════════════════════════════════════════════════════════════
  // SUPABASE CREDENTIALS
  // ⚠️ استبدل هذه القيم من Supabase Dashboard > Project Settings > API
  // ═══════════════════════════════════════════════════════════════════

  static const String supabaseUrl = 'https://bkemwnmeifsvtjeuptzy.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_SjMShIXAKmBIZaCDa5PtcQ_Cl2-K_u9';

  // ═══════════════════════════════════════════════════════════════════
  // SUPABASE INSTANCES
  // ═══════════════════════════════════════════════════════════════════

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
  static SupabaseStorageClient get storage => client.storage;

  // ═══════════════════════════════════════════════════════════════════
  // INITIALIZE
  // ═══════════════════════════════════════════════════════════════════

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // AUTH HELPERS
  // ═══════════════════════════════════════════════════════════════════

  static User? get currentUser => auth.currentUser;
  static String? get currentUserId => currentUser?.id;
  static bool get isAuthenticated => currentUser != null;
  static Session? get currentSession => auth.currentSession;
  static Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  // ═══════════════════════════════════════════════════════════════════
  // TABLE NAMES
  // ═══════════════════════════════════════════════════════════════════

  static const String profilesTable = 'profiles';
  static const String skillCategoriesTable = 'skill_categories';
  static const String skillsTable = 'skills';
  static const String bookingsTable = 'bookings';
  static const String postsTable = 'posts';
  static const String postLikesTable = 'post_likes';
  static const String postCommentsTable = 'post_comments';
  static const String eventsTable = 'events';
  static const String eventRegistrationsTable = 'event_registrations';
  static const String conversationsTable = 'conversations';
  static const String messagesTable = 'messages';
  static const String notificationsTable = 'notifications';
  static const String walletTransactionsTable = 'wallet_transactions';
  static const String reviewsTable = 'reviews';
  static const String favoritesTable = 'favorites';

  // ═══════════════════════════════════════════════════════════════════
  // STORAGE BUCKETS
  // ═══════════════════════════════════════════════════════════════════

  static const String avatarsBucket = 'avatars';
  static const String skillImagesBucket = 'skill-images';
  static const String postImagesBucket = 'post-images';
  static const String eventImagesBucket = 'event-images';
  static const String messageFilesBucket = 'message-files';
}