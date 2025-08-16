import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_model.dart';
import '../services/services_service.dart';

final servicesServiceProvider = Provider<ServicesService>((ref) {
  return ServicesService();
});

final servicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final servicesService = ref.read(servicesServiceProvider);
  return servicesService.getServices();
});

final servicesByCategoryProvider = FutureProvider.family<List<ServiceModel>, ServiceCategory>((ref, category) async {
  final servicesService = ref.read(servicesServiceProvider);
  return servicesService.getServicesByCategory(category);
});

final serviceDetailProvider = FutureProvider.family<ServiceModel, String>((ref, serviceId) async {
  final servicesService = ref.read(servicesServiceProvider);
  return servicesService.getServiceById(serviceId);
});

final myServicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final servicesService = ref.read(servicesServiceProvider);
  return servicesService.getMyServices();
});

final servicesNotifierProvider = StateNotifierProvider<ServicesNotifier, ServicesState>((ref) {
  return ServicesNotifier(ref.read(servicesServiceProvider));
});

class ServicesNotifier extends StateNotifier<ServicesState> {
  final ServicesService _servicesService;

  ServicesNotifier(this._servicesService) : super(const ServicesInitial());

  Future<void> createService({
    required String title,
    required String description,
    required ServiceCategory category,
    required double hourlyRate,
    required List<String> tags,
    List<String>? imagePaths,
  }) async {
    state = const ServicesLoading();
    try {
      await _servicesService.createService(
        title: title,
        description: description,
        category: category,
        hourlyRate: hourlyRate,
        tags: tags,
        imagePaths: imagePaths,
      );
      state = const ServicesSuccess('Service created successfully');
    } catch (e) {
      state = ServicesError(e.toString());
    }
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
    state = const ServicesLoading();
    try {
      await _servicesService.updateService(
        serviceId: serviceId,
        title: title,
        description: description,
        category: category,
        hourlyRate: hourlyRate,
        tags: tags,
        isActive: isActive,
      );
      state = const ServicesSuccess('Service updated successfully');
    } catch (e) {
      state = ServicesError(e.toString());
    }
  }

  Future<void> deleteService(String serviceId) async {
    state = const ServicesLoading();
    try {
      await _servicesService.deleteService(serviceId);
      state = const ServicesSuccess('Service deleted successfully');
    } catch (e) {
      state = ServicesError(e.toString());
    }
  }
}

// Define the state classes
abstract class ServicesState {
  const ServicesState();
}

class ServicesInitial extends ServicesState {
  const ServicesInitial();
}

class ServicesLoading extends ServicesState {
  const ServicesLoading();
}

class ServicesSuccess extends ServicesState {
  final String message;
  const ServicesSuccess(this.message);
}

class ServicesError extends ServicesState {
  final String message;
  const ServicesError(this.message);
}