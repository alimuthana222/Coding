import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/repositories/service_repository.dart';
import '../../../core/repositories/wallet_repository.dart';
import '../../../core/models/service_model.dart';
import '../../../core/models/skill_model.dart';
import 'services_state.dart';

class ServicesCubit extends Cubit<ServicesState> {
  final ServiceRepository _serviceRepository = sl<ServiceRepository>();
  final WalletRepository _walletRepository = sl<WalletRepository>();

  ServicesCubit() : super(const ServicesState()) {
    loadInitialData();
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAD INITIAL DATA
  // ══════════════════════════════════════════════════════════��════════

  Future<void> loadInitialData() async {
    emit(state.copyWith(status: ServicesStatus.loading));

    try {
      // ✅ تصحيح - تحميل البيانات بشكل منفصل
      final categories = await _serviceRepository.getCategories();
      final services = await _serviceRepository.getServices();

      emit(state.copyWith(
        status: ServicesStatus.loaded,
        categories: categories,
        services: services,
        currentPage: 1,
        hasReachedMax: services.length < 20,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ServicesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOAD MORE
  // ═══════════════════════════════════════════════════════════════════

  Future<void> loadMore() async {
    if (state.hasReachedMax || state.status == ServicesStatus.loading) return;

    try {
      final nextPage = state.currentPage + 1;
      final newServices = await _serviceRepository.getServices(
        type: state.selectedType,
        pricingType: state.selectedPricing,
        categoryId: state.selectedCategoryId,
        searchQuery: state.searchQuery,
        page: nextPage,
      );

      emit(state.copyWith(
        services: [...state.services, ...newServices],
        currentPage: nextPage,
        hasReachedMax: newServices.length < 20,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // FILTER BY TYPE (عرض/طلب)
  // ═══════════════════════════════════════════════════════════════════

  Future<void> filterByType(ServiceType? type) async {
    emit(state.copyWith(
      status: ServicesStatus.loading,
      selectedType: type,
      currentPage: 1,
      hasReachedMax: false,
    ));

    try {
      final services = await _serviceRepository.getServices(
        type: type,
        pricingType: state.selectedPricing,
        categoryId: state.selectedCategoryId,
        searchQuery: state.searchQuery,
      );

      emit(state.copyWith(
        status: ServicesStatus.loaded,
        services: services,
        hasReachedMax: services.length < 20,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ServicesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // FILTER BY PRICING (ساعات/مال)
  // ═══════════════════════════════════════════════════════════════════

  Future<void> filterByPricing(PricingType? pricing) async {
    emit(state.copyWith(
      status: ServicesStatus.loading,
      selectedPricing: pricing,
      currentPage: 1,
      hasReachedMax: false,
    ));

    try {
      final services = await _serviceRepository.getServices(
        type: state.selectedType,
        pricingType: pricing,
        categoryId: state.selectedCategoryId,
        searchQuery: state.searchQuery,
      );

      emit(state.copyWith(
        status: ServicesStatus.loaded,
        services: services,
        hasReachedMax: services.length < 20,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ServicesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // FILTER BY CATEGORY
  // ═══════════════════════════════════════════════════════════════════

  Future<void> filterByCategory(String? categoryId) async {
    emit(state.copyWith(
      status: ServicesStatus.loading,
      selectedCategoryId: categoryId,
      currentPage: 1,
      hasReachedMax: false,
    ));

    try {
      final services = await _serviceRepository.getServices(
        type: state.selectedType,
        pricingType: state.selectedPricing,
        categoryId: categoryId,
        searchQuery: state.searchQuery,
      );

      emit(state.copyWith(
        status: ServicesStatus.loaded,
        services: services,
        hasReachedMax: services.length < 20,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ServicesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // SEARCH
  // ═══════════════════════════════════════════════════════════════════

  Future<void> search(String query) async {
    emit(state.copyWith(
      status: ServicesStatus.loading,
      searchQuery: query.isEmpty ? null : query,
      currentPage: 1,
      hasReachedMax: false,
    ));

    try {
      final services = await _serviceRepository.getServices(
        type: state.selectedType,
        pricingType: state.selectedPricing,
        categoryId: state.selectedCategoryId,
        searchQuery: query.isEmpty ? null : query,
      );

      emit(state.copyWith(
        status: ServicesStatus.loaded,
        services: services,
        hasReachedMax: services.length < 20,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ServicesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // CREATE SERVICE
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> createService({
    required ServiceType serviceType,
    required String title,
    required String description,
    required PricingType pricingType,
    double? priceHours,
    double? priceMoney,
    String? categoryId,
    int? estimatedDuration,
  }) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) return false;

    emit(state.copyWith(isCreating: true));

    try {
      final service = ServiceModel(
        id: '',
        userId: userId,
        categoryId: categoryId,
        serviceType: serviceType,
        title: title,
        description: description,
        pricingType: pricingType,
        priceHours: priceHours,
        priceMoney: priceMoney,
        estimatedDuration: estimatedDuration,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final created = await _serviceRepository.createService(service);

      emit(state.copyWith(
        isCreating: false,
        services: [created, ...state.services],
      ));

      return true;
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // BOOK SERVICE
  // ═══════════════════════════════════════════════════════════════════

  Future<String?> bookService({
    required ServiceModel service,
    String? message,
  }) async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) return 'يجب تسجيل الدخول أولاً';

    // Check if user can afford
    final canAfford = await _walletRepository.canAffordService(
      userId: userId,
      isHours: service.pricingType == PricingType.hours,
      amount: service.pricingType == PricingType.hours
          ? service.priceHours ?? 0
          : service.priceMoney ?? 0,
    );

    if (!canAfford) {
      if (service.pricingType == PricingType.hours) {
        return 'ليس لديك ساعات كافية. تحتاج ${service.priceHours} ساعة';
      } else {
        return 'الرصيد غير كافي. تحتاج ${service.priceMoney} د.ع';
      }
    }

    try {
      await _serviceRepository.createBooking(
        serviceId: service.id,
        clientId: userId,
        providerId: service.userId,
        pricingType: service.pricingType,
        priceHours: service.priceHours,
        priceMoney: service.priceMoney,
        clientMessage: message,
      );

      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // REFRESH
  // ═══════════════════════════════════════════════════════════════════

  Future<void> refresh() async {
    emit(state.copyWith(currentPage: 1, hasReachedMax: false));
    await loadInitialData();
  }

  // ═══════════════════════════════════════════════════════════════════
  // CLEAR FILTERS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> clearFilters() async {
    emit(state.copyWith(
      selectedType: null,
      selectedPricing: null,
      selectedCategoryId: null,
      searchQuery: null,
    ));
    await loadInitialData();
  }
}