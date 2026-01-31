import 'package:equatable/equatable.dart';
import '../../../core/models/service_model.dart';
import '../../../core/models/skill_model.dart';

enum ServicesStatus { initial, loading, loaded, error }

class ServicesState extends Equatable {
  final ServicesStatus status;
  final List<ServiceModel> services;
  final List<SkillCategoryModel> categories;
  final ServiceType? selectedType;
  final PricingType? selectedPricing;
  final String? selectedCategoryId;
  final String? searchQuery;
  final String? errorMessage;
  final bool hasReachedMax;
  final int currentPage;
  final bool isCreating;

  const ServicesState({
    this.status = ServicesStatus.initial,
    this.services = const [],
    this.categories = const [],
    this.selectedType,
    this.selectedPricing,
    this.selectedCategoryId,
    this.searchQuery,
    this.errorMessage,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.isCreating = false,
  });

  ServicesState copyWith({
    ServicesStatus? status,
    List<ServiceModel>? services,
    List<SkillCategoryModel>? categories,
    ServiceType? selectedType,
    PricingType? selectedPricing,
    String? selectedCategoryId,
    String? searchQuery,
    String? errorMessage,
    bool? hasReachedMax,
    int? currentPage,
    bool? isCreating,
  }) {
    return ServicesState(
      status: status ?? this.status,
      services: services ?? this.services,
      categories: categories ?? this.categories,
      selectedType: selectedType,
      selectedPricing: selectedPricing,
      selectedCategoryId: selectedCategoryId,
      searchQuery: searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isCreating: isCreating ?? this.isCreating,
    );
  }

  // Filtered lists
  List<ServiceModel> get offerings =>
      services.where((s) => s.serviceType == ServiceType.offering).toList();

  List<ServiceModel> get requests =>
      services.where((s) => s.serviceType == ServiceType.requesting).toList();

  @override
  List<Object?> get props => [
    status, services, categories, selectedType, selectedPricing,
    selectedCategoryId, searchQuery, errorMessage, hasReachedMax,
    currentPage, isCreating,
  ];
}