import 'dummy_services.dart';
import 'service_model.dart';

class ServiceRepository {
  static final ServiceRepository _instance = ServiceRepository._internal();

  factory ServiceRepository() {
    return _instance;
  }

  ServiceRepository._internal() {
    _initializeDummyServices();
  }

  final List<ServiceModel> _services = [];
  bool _isInitialized = false;

  void _initializeDummyServices() {
    if (_isInitialized) {
      return;
    }

    _services.addAll(DummyServices.data);
    _isInitialized = true;
  }

  Future<List<ServiceModel>> getAllServices() async {
    _initializeDummyServices();
    return List<ServiceModel>.unmodifiable(_services);
  }

  Future<ServiceModel?> getServiceById(String id) async {
    _initializeDummyServices();
    try {
      return _services.firstWhere((service) => service.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<ServiceModel>> searchServices(String query) async {
    _initializeDummyServices();

    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return List<ServiceModel>.unmodifiable(_services);
    }

    final filteredServices = _services.where((service) {
      return service.name.toLowerCase().contains(normalizedQuery) ||
          service.category.toLowerCase().contains(normalizedQuery) ||
          service.description.toLowerCase().contains(normalizedQuery);
    }).toList(growable: false);

    return List<ServiceModel>.unmodifiable(filteredServices);
  }
}