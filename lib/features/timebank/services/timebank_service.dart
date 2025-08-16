import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/time_transaction_model.dart';

class TimebankService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int> getTimeBalance() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('profiles')
        .select('time_balance')
        .eq('id', user.id)
        .single();

    return response['time_balance'] ?? 0;
  }

  Future<List<TimeTransactionModel>> getTimeTransactions({
    int limit = 50,
    int offset = 0,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('time_transactions')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return response.map<TimeTransactionModel>((json) => TimeTransactionModel.fromJson(json)).toList();
  }

  Future<void> transferTime({
    required String toUserId,
    required int hours,
    required String description,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check if user has sufficient time balance
    final balance = await getTimeBalance();
    if (balance < hours) {
      throw Exception('Insufficient time balance');
    }

    // Transfer time
    await _supabase.rpc('transfer_time', params: {
      'from_user_id': user.id,
      'to_user_id': toUserId,
      'hours': hours,
      'description': description,
    });
  }

  Future<void> exchangeSkill({
    required String serviceId,
    required int hours,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check if user has sufficient time balance
    final balance = await getTimeBalance();
    if (balance < hours) {
      throw Exception('Insufficient time balance');
    }

    // Create skill exchange transaction
    await _supabase.from('time_transactions').insert({
      'user_id': user.id,
      'type': 'spent',
      'hours': hours,
      'description': 'Skill exchange',
      'service_id': serviceId,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Update user's time balance
    await _supabase.rpc('update_time_balance', params: {
      'user_id': user.id,
      'amount': -hours,
    });
  }

  Future<void> earnTime({
    required int hours,
    required String description,
    String? serviceId,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Create earn transaction
    await _supabase.from('time_transactions').insert({
      'user_id': user.id,
      'type': 'earned',
      'hours': hours,
      'description': description,
      'service_id': serviceId,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Update user's time balance
    await _supabase.rpc('update_time_balance', params: {
      'user_id': user.id,
      'amount': hours,
    });
  }
}