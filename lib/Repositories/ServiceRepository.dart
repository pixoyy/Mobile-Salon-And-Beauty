import 'package:salon_and_beauty/Models/ServiceModel.dart';
import 'package:salon_and_beauty/core/network/api_client.dart';

class ServiceRepository {
  Future<List<ServiceModel>> getAllServices({String? category}) async {
    final params = <String, dynamic>{};
    if (category != null) params['category'] = category;
    final response = await ApiClient().get('/services', params: params);
    return _parseList(response.data['data']);
  }

  Future<ServiceModel> getServiceById(String id) async {
    final response = await ApiClient().get('/services/$id');
    return ServiceModel.fromJson(response.data['data']);
  }

  Future<List<ServiceModel>> searchServices(
    String query, {
    int? minPrice,
    int? maxPrice,
  }) async {
    final params = <String, dynamic>{'q': query};
    if (minPrice != null) params['min_price'] = minPrice;
    if (maxPrice != null) params['max_price'] = maxPrice;
    final response = await ApiClient().get('/services/search', params: params);
    return _parseList(response.data['data']);
  }

  List<ServiceModel> _parseList(dynamic data) {
    return (data as List).map((j) => ServiceModel.fromJson(j)).toList();
  }
}
