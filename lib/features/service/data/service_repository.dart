import 'package:salon_and_beauty/core/data/database_helper.dart';
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

    try {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query('services');
      if (rows.isEmpty) {
        return List<ServiceModel>.unmodifiable(_services);
      }

      final mapped = rows
          .map((r) => ServiceModel.fromMap(r))
          .toList(growable: false);

      return List<ServiceModel>.unmodifiable(mapped);
    } catch (_) {
      return List<ServiceModel>.unmodifiable(_services);
    }
  }

  Future<ServiceModel?> getServiceById(String id) async {
    _initializeDummyServices();
    try {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query('services', where: 'id = ?', whereArgs: [id]);
      if (rows.isEmpty) {
        try {
          return _services.firstWhere((service) => service.id == id);
        } catch (_) {
          return null;
        }
      }

      return ServiceModel.fromMap(rows.first);
    } catch (_) {
      try {
        return _services.firstWhere((service) => service.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  Future<List<ServiceModel>> searchServices(String query) async {
    _initializeDummyServices();

    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return List<ServiceModel>.unmodifiable(_services);
    }

    try {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query('services');
      final mapped = rows
          .map((r) => ServiceModel.fromMap(r))
          .toList(growable: false);

      final filteredServices = mapped.where((service) {
        return service.name.toLowerCase().contains(normalizedQuery) ||
            service.category.toLowerCase().contains(normalizedQuery) ||
            service.description.toLowerCase().contains(normalizedQuery);
      }).toList(growable: false);

      return List<ServiceModel>.unmodifiable(filteredServices);
    } catch (_) {
      final filteredServices = _services.where((service) {
        return service.name.toLowerCase().contains(normalizedQuery) ||
            service.category.toLowerCase().contains(normalizedQuery) ||
            service.description.toLowerCase().contains(normalizedQuery);
      }).toList(growable: false);

      return List<ServiceModel>.unmodifiable(filteredServices);
    }
  }
}