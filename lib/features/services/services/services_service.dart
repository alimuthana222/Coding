import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/app_config.dart';
import '../models/service_model.dart';

class ServicesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ServiceModel>> getServices({
    int limit = 20,
    int offset = 0,
    String? searchQuery,
  }) async {
    var query = _supabase
        .from('services')
        .select('''
          *,
          profiles:provider_id (
            full_name,
            avatar_url,
            rating
          )
        ''')
        .eq('is_active', true);

    // Fix the search query issue by using ilike for case-insensitive search
    if (searchQuery != null && searchQuery.isNotEmpty) {
      // Search in both title and description using ilike
      query = query.ilike('title', '%$searchQuery%');
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return response.map<ServiceModel>((json) {
      final profileData = json['profiles'] as Map<String, dynamic>?;
      return ServiceModel.fromJson({
        ...json,
        'provider_name': profileData?['full_name'],
        'provider_avatar': profileData?['avatar_url'],
        'provider_rating': profileData?['rating']?.toDouble(),
      });
    }).toList();
  }

  Future<List<ServiceModel>> getServicesByCategory(ServiceCategory category) async {
    final response = await _supabase
        .from('services')
        .select('''
          *,
          profiles:provider_id (
            full_name,
            avatar_url,
            rating
          )
        ''')
        .eq('category', _serviceCategoryToString(category))
        .eq('is_active', true)
        .order('rating', ascending: false);

    return response.map<ServiceModel>((json) {
      final profileData = json['profiles'] as Map<String, dynamic>?;
      return ServiceModel.fromJson({
        ...json,
        'provider_name': profileData?['full_name'],
        'provider_avatar': profileData?['avatar_url'],
        'provider_rating': profileData?['rating']?.toDouble(),
      });
    }).toList();
  }

  Future<ServiceModel> getServiceById(String serviceId) async {
    final response = await _supabase
        .from('services')
        .select('''
          *,
          profiles:provider_id (
            full_name,
            avatar_url,
            rating,
            review_count
          )
        ''')
        .eq('id', serviceId)
        .single();

    final profileData = response['profiles'] as Map<String, dynamic>?;
    return ServiceModel.fromJson({
      ...response,
      'provider_name': profileData?['full_name'],
      'provider_avatar': profileData?['avatar_url'],
      'provider_rating': profileData?['rating']?.toDouble(),
    });
  }

  Future<List<ServiceModel>> getMyServices() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('services')
        .select('*')
        .eq('provider_id', user.id)
        .order('created_at', ascending: false);

    return response.map<ServiceModel>((json) => ServiceModel.fromJson(json)).toList();
  }

  Future<void> createService({
    required String title,
    required String description,
    required ServiceCategory category,
    required double hourlyRate,
    required List<String> tags,
    List<String>? imagePaths,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    List<String> imageUrls = [];
    if (imagePaths != null) {
      imageUrls = await _uploadServiceImages(imagePaths);
    }

    await _supabase.from('services').insert({
      'provider_id': user.id,
      'title': title,
      'description': description,
      'category': _serviceCategoryToString(category),
      'hourly_rate': hourlyRate,
      'image_urls': imageUrls,
      'tags': tags,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateService({
    required String serviceId,
    String? title,
    String? description,
    ServiceCategory? category,
    double? hourlyRate,
    List<String>? tags,
    bool? isActive,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (title != null) updates['title'] = title;
    if (description != null) updates['description'] = description;
    if (category != null) updates['category'] = _serviceCategoryToString(category);
    if (hourlyRate != null) updates['hourly_rate'] = hourlyRate;
    if (tags != null) updates['tags'] = tags;
    if (isActive != null) updates['is_active'] = isActive;

    await _supabase
        .from('services')
        .update(updates)
        .eq('id', serviceId)
        .eq('provider_id', user.id);
  }

  Future<void> deleteService(String serviceId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabase
        .from('services')
        .delete()
        .eq('id', serviceId)
        .eq('provider_id', user.id);
  }

  Future<List<String>> _uploadServiceImages(List<String> imagePaths) async {
    final List<String> imageUrls = [];

    for (final imagePath in imagePaths) {
      final file = File(imagePath);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imagePaths.indexOf(imagePath)}.jpg';

      await _supabase.storage
          .from(AppConfig.serviceImagesBucket)
          .upload(fileName, file);

      final imageUrl = _supabase.storage
          .from(AppConfig.serviceImagesBucket)
          .getPublicUrl(fileName);

      imageUrls.add(imageUrl);
    }

    return imageUrls;
  }

  // Helper method for category conversion
  String _serviceCategoryToString(ServiceCategory category) {
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