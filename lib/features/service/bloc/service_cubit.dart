import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/service_model.dart';
import '../data/service_repository.dart';

enum ServiceStatus { initial, loading, success, failure }

class ServiceListState {
  const ServiceListState({
    required this.status,
    required this.services,
    this.query = '',
    this.activeCategory,
    this.errorMessage,
  });

  const ServiceListState.initial()
      : status = ServiceStatus.initial,
        services = const <ServiceModel>[],
        query = '',
        activeCategory = null,
        errorMessage = null;

  final ServiceStatus status;
  final List<ServiceModel> services;
  final String query;
  final String? activeCategory;
  final String? errorMessage;

  ServiceListState copyWith({
    ServiceStatus? status,
    List<ServiceModel>? services,
    String? query,
    String? activeCategory,
    String? errorMessage,
    bool clearError = false,
    bool clearActiveCategory = false,
  }) {
    return ServiceListState(
      status: status ?? this.status,
      services: services ?? this.services,
      query: query ?? this.query,
      activeCategory: clearActiveCategory ? null : (activeCategory ?? this.activeCategory),
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ServiceListCubit extends Cubit<ServiceListState> {
  ServiceListCubit(this._repository) : super(const ServiceListState.initial());

  final ServiceRepository _repository;
  List<ServiceModel> _allServices = [];

  List<ServiceModel> get allServices => List<ServiceModel>.unmodifiable(_allServices);

  Future<void> loadServices({bool showLoading = true}) async {
    if (showLoading) {
      emit(state.copyWith(status: ServiceStatus.loading, clearError: true));
    }

    try {
      final services = await _repository.getAllServices();
      _allServices = services;
      emit(state.copyWith(
        status: ServiceStatus.success,
        services: services,
        query: '',
        activeCategory: null,
        clearError: true,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ServiceStatus.failure,
        errorMessage: 'Gagal memuat daftar layanan.',
      ));
    }
  }

  Future<void> searchServices(String query) async {
    final normalizedQuery = query.trim();

    try {
      List<ServiceModel> services;
      if (normalizedQuery.isEmpty && state.activeCategory == null) {
        // No search and no category filter: return all
        services = _allServices;
      } else if (state.activeCategory != null && normalizedQuery.isEmpty) {
        // Category filter only: return services in that category
        services = _allServices.where((s) => s.category == state.activeCategory).toList();
      } else if (state.activeCategory != null && normalizedQuery.isNotEmpty) {
        // Both category and search: search within the category
        final categoryServices = _allServices.where((s) => s.category == state.activeCategory).toList();
        services = categoryServices
            .where((service) =>
                service.name.toLowerCase().contains(normalizedQuery.toLowerCase()) ||
                service.description.toLowerCase().contains(normalizedQuery.toLowerCase()))
            .toList();
      } else {
        // Search query only (no category): use repository search
        services = await _repository.searchServices(normalizedQuery);
      }
      emit(state.copyWith(
        status: ServiceStatus.success,
        services: services,
        query: normalizedQuery,
        clearError: true,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ServiceStatus.failure,
        errorMessage: 'Pencarian layanan gagal. Coba lagi.',
      ));
    }
  }

  Future<void> setActiveCategory(String? category) async {
    emit(state.copyWith(
      activeCategory: category,
      clearError: true,
      clearActiveCategory: category == null,
    ));
    // Re-apply current search query with the new category
    await searchServices(state.query);
  }
}