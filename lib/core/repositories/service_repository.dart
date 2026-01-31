import '../config/supabase_config.dart';
import '../models/service_model.dart';
import '../models/skill_model.dart';

class ServiceRepository {
  final _client = SupabaseConfig.client;

  // ═══════════════════════════════════════════════════════════════════
  // GET SERVICES
  // ═══════════════════════════════════════════════════════════════════

  Future<List<ServiceModel>> getServices({
    ServiceType? type,
    PricingType? pricingType,
    String? categoryId,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    var query = _client
        .from('services')
        .select('*, profiles(*), skill_categories(*)')
        .eq('status', 'active');

    if (type != null) {
      query = query.eq('service_type', type == ServiceType.offering ? 'offering' : 'requesting');
    }

    if (pricingType != null) {
      query = query.eq('pricing_type', pricingType == PricingType.hours ? 'hours' : 'money');
    }

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
    }

    final response = await query
        .order('created_at', ascending: false)
        .range((page - 1) * limit, page * limit - 1);

    return (response as List).map((e) => ServiceModel.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET SERVICE BY ID
  // ═══════════════════════════════════════════════════════════════════

  Future<ServiceModel?> getServiceById(String id) async {
    final response = await _client
        .from('services')
        .select('*, profiles(*), skill_categories(*)')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    // Increment views
    await _client.from('services').update({
      'views': (response['views'] as int) + 1,
    }).eq('id', id);

    return ServiceModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET USER SERVICES
  // ═══════════════════════════════════════════════════════════════════

  Future<List<ServiceModel>> getUserServices(String userId) async {
    final response = await _client
        .from('services')
        .select('*, profiles(*), skill_categories(*)')
        .eq('user_id', userId)
        .neq('status', 'deleted')
        .order('created_at', ascending: false);

    return (response as List).map((e) => ServiceModel.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // CREATE SERVICE
  // ═══════════════════════════════════════════════════════════════════

  Future<ServiceModel> createService(ServiceModel service) async {
    final response = await _client
        .from('services')
        .insert(service.toJson())
        .select('*, profiles(*), skill_categories(*)')
        .single();

    return ServiceModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // UPDATE SERVICE
  // ═══════════════════════════════════════════════════════════════════

  Future<ServiceModel> updateService(String id, Map<String, dynamic> data) async {
    final response = await _client
        .from('services')
        .update(data)
        .eq('id', id)
        .select('*, profiles(*), skill_categories(*)')
        .single();

    return ServiceModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // DELETE SERVICE
  // ═══════════════════════════════════════════════════════════════════

  Future<void> deleteService(String id) async {
    await _client.from('services').update({'status': 'deleted'}).eq('id', id);
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET CATEGORIES
  // ═══════════════════════════════════════════════════════════════════

  Future<List<SkillCategoryModel>> getCategories() async {
    final response = await _client
        .from(SupabaseConfig.skillCategoriesTable)
        .select()
        .order('name_ar');

    return (response as List).map((e) => SkillCategoryModel.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // CREATE BOOKING
  // ═══════════════════════════════════════════════════════════════════

  Future<ServiceBookingModel> createBooking({
    required String serviceId,
    required String clientId,
    required String providerId,
    required PricingType pricingType,
    double? priceHours,
    double? priceMoney,
    String? clientMessage,
  }) async {
    final response = await _client
        .from('service_bookings')
        .insert({
      'service_id': serviceId,
      'client_id': clientId,
      'provider_id': providerId,
      'pricing_type': pricingType == PricingType.hours ? 'hours' : 'money',
      'price_hours': priceHours,
      'price_money': priceMoney,
      'client_message': clientMessage,
    })
        .select('''
          *,
          services(*),
          client:profiles!service_bookings_client_id_fkey(*),
          provider:profiles!service_bookings_provider_id_fkey(*)
        ''')
        .single();

    return ServiceBookingModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // GET USER BOOKINGS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<ServiceBookingModel>> getUserBookings(String userId, {bool asClient = true}) async {
    final response = await _client
        .from('service_bookings')
        .select('''
          *,
          services(*),
          client:profiles!service_bookings_client_id_fkey(*),
          provider:profiles!service_bookings_provider_id_fkey(*)
        ''')
        .eq(asClient ? 'client_id' : 'provider_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => ServiceBookingModel.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // UPDATE BOOKING STATUS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    final updateData = <String, dynamic>{
      'status': _statusToString(status),
      'updated_at': DateTime.now().toIso8601String(),
    };

    switch (status) {
      case BookingStatus.accepted:
        updateData['accepted_at'] = DateTime.now().toIso8601String();
        break;
      case BookingStatus.inProgress:
        updateData['started_at'] = DateTime.now().toIso8601String();
        break;
      case BookingStatus.completed:
        updateData['completed_at'] = DateTime.now().toIso8601String();
        break;
      case BookingStatus.cancelled:
        updateData['cancelled_at'] = DateTime.now().toIso8601String();
        break;
      default:
        break;
    }

    await _client.from('service_bookings').update(updateData).eq('id', bookingId);
  }

  String _statusToString(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending: return 'pending';
      case BookingStatus.accepted: return 'accepted';
      case BookingStatus.inProgress: return 'in_progress';
      case BookingStatus.completed: return 'completed';
      case BookingStatus.cancelled: return 'cancelled';
      case BookingStatus.rejected: return 'rejected';
      case BookingStatus.disputed: return 'disputed';
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // ADD REVIEW
  // ═══════════════════════════════════════════════════════════════════

  Future<void> addReview({
    required String bookingId,
    required int rating,
    String? review,
    required bool isClientReview,
  }) async {
    final updateData = <String, dynamic>{
      isClientReview ? 'client_rating' : 'provider_rating': rating,
      isClientReview ? 'client_review' : 'provider_review': review,
      isClientReview ? 'client_reviewed_at' : 'provider_reviewed_at':
      DateTime.now().toIso8601String(),
    };

    await _client.from('service_bookings').update(updateData).eq('id', bookingId);
  }
}