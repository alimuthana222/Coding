import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/user_model.dart';

class UserRepository {
  final _client = SupabaseConfig.client;

  // ══════���════════════════════════════════════════════════════════════
  // GET USER BY ID
  // ═══════════════════════════════════════════════════════════════════

  Future<UserModel?> getUserById(String userId) async {
    final response = await _client
        .from(SupabaseConfig.profilesTable)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // UPDATE USER PROFILE
  // ═══════════════════════════════════════════════════════════════════

  Future<UserModel> updateProfile(UserModel user) async {
    final response = await _client
        .from(SupabaseConfig.profilesTable)
        .update(user.toUpdateJson())
        .eq('id', user.id)
        .select()
        .single();

    return UserModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // UPLOAD AVATAR
  // ═══════════════════════════════════════════════════════════════════

  Future<String> uploadAvatar(String userId, File file) async {
    final fileExt = file.path.split('.').last;
    final fileName = '$userId/avatar.$fileExt';

    await _client.storage.from(SupabaseConfig.avatarsBucket).upload(
      fileName,
      file,
      fileOptions: const FileOptions(upsert: true),
    );

    final url = _client.storage
        .from(SupabaseConfig.avatarsBucket)
        .getPublicUrl(fileName);

    // Update profile with new avatar URL
    await _client.from(SupabaseConfig.profilesTable).update({
      'avatar_url': url,
    }).eq('id', userId);

    return url;
  }

  // ═══════════════════════════════════════════════════════════════════
  // CHECK USERNAME AVAILABILITY
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> isUsernameAvailable(String username) async {
    final response = await _client
        .from(SupabaseConfig.profilesTable)
        .select('id')
        .eq('username', username)
        .maybeSingle();

    return response == null;
  }

  // ═══════════════════════════════════════════════════════════════════
  // SEARCH USERS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<UserModel>> searchUsers(String query, {int limit = 20}) async {
    final response = await _client
        .from(SupabaseConfig.profilesTable)
        .select()
        .or('full_name.ilike.%$query%,username.ilike.%$query%')
        .limit(limit);

    return (response as List).map((e) => UserModel.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET WALLET BALANCE
  // ═══════════════════════════════════════════════════════════════════

  Future<double> getWalletBalance(String userId) async {
    final response = await _client
        .from(SupabaseConfig.profilesTable)
        .select('wallet_hours')
        .eq('id', userId)
        .single();

    return (response['wallet_hours'] as num).toDouble();
  }

  // ═══════════════════════════════════════════════════════════════════
  // UPDATE WALLET
  // ═══════════════════════════════════════════════════════════════════

  Future<void> updateWallet(String userId, double hours, String type, String description) async {
    // Get current balance
    final currentBalance = await getWalletBalance(userId);
    final newBalance = currentBalance + hours;

    // Update balance
    await _client.from(SupabaseConfig.profilesTable).update({
      'wallet_hours': newBalance,
    }).eq('id', userId);

    // Record transaction
    await _client.from(SupabaseConfig.walletTransactionsTable).insert({
      'user_id': userId,
      'type': type,
      'hours': hours,
      'balance_after': newBalance,
      'description_ar': description,
    });
  }
}