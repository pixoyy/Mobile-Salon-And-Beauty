import 'package:salon_and_beauty/Models/StylistModel.dart';
import 'package:salon_and_beauty/core/network/api_client.dart';

class StylistRepository {
  Future<List<StylistModel>> getAllStylists({String? specialization}) async {
    final params = <String, dynamic>{};
    if (specialization != null) params['specialization'] = specialization;
    final response = await ApiClient().get('/stylists', params: params);
    return _parseList(response.data['data']);
  }

  Future<StylistModel> getStylistById(String id) async {
    final response = await ApiClient().get('/stylists/$id');
    return StylistModel.fromJson(response.data['data']);
  }

  Future<List<StylistModel>> searchStylists(
    String query, {
    double? minRating,
  }) async {
    final params = <String, dynamic>{'q': query};
    if (minRating != null) params['min_rating'] = minRating;
    final response = await ApiClient().get('/stylists/search', params: params);
    return _parseList(response.data['data']);
  }

  List<StylistModel> _parseList(dynamic data) {
    return (data as List).map((j) => StylistModel.fromJson(j)).toList();
  }
}
