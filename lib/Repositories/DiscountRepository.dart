import 'package:dio/dio.dart';
import 'package:salon_and_beauty/Models/DiscountModel.dart';
import 'package:salon_and_beauty/core/network/api_client.dart';

class DiscountRepository {
  Future<List<Discount>> getAllDiscounts() async {
    final response = await ApiClient().get('/discounts/active');
    return _parseList(response.data['data']);
  }

  Future<Discount?> validateDiscount(String code, int subtotal) async {
    try {
      final response = await ApiClient().post('/discounts/validate', data: {
        'code': code,
        'subtotal': subtotal,
      });
      return Discount.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) return null;
      rethrow;
    }
  }

  List<Discount> _parseList(dynamic data) {
    return (data as List).map((j) => Discount.fromJson(j)).toList();
  }
}
